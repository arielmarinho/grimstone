extends CharacterBody2D
## Player — classes estilo Rucoy (arma define classe), SKILLS Q/E + R/G (city2),
## regen estilo Tibia (mana sempre, HP fora de combate), cura fora de combate 5%/2s.

signal stats_changed
signal died

const EQUIPS = preload("res://scripts/data/equips.gd")
const TEXHELPER = preload("res://scripts/ui/tex_helper.gd")
const ITEMS_DB = preload("res://scripts/data/items_db.gd")

const SPEED := 170.0
const ATTACK_RANGE := 46.0
const ARROW_RANGE := 260.0

# Classes (arma define a classe — estilo Rucoy)
const CLASSES = {
	"sword": {"name": "Guerreiro", "color": Color(0.85, 0.75, 0.55)},
	"axe": {"name": "Bárbaro", "color": Color(0.8, 0.5, 0.3)},
	"bow": {"name": "Arqueiro", "color": Color(0.5, 0.8, 0.5)},
	"staff": {"name": "Mago", "color": Color(0.5, 0.6, 0.9)},
}

var player_name := "Herói"
var char_class := "sword"
var level := 1
var xp := 0
var hp := 100.0
var mana := 50.0
var coins := 0
var moving := false
var target := Vector2.ZERO
var attack_target: Node = null
var dead := false
var in_combat := false
var combat_timer := 0.0

# Equipamento
var weapon := "sword"
var armor := "none"
var shield := "none"
var helmet := "none"

# Skills
var skill_points := 0
var skills := {}  # id -> level
var skill_cooldowns := {}

# Touch (Android)
var touch_mode := false

@onready var sprite: Node2D = $Sprite
@onready var attack_timer: Timer = $AttackTimer

func _ready() -> void:
	add_to_group("player")
	touch_mode = DisplayServer.is_touchscreen_available()
	_build_body()
	_play("idle_down")
	GameManager.player = self

func _build_body() -> void:
	# corpo procedural estilo Rucoy: cabeça + cabelo + túnica + calça + arma embutida
	for c in sprite.get_children():
		c.queue_free()
	var skin = Color(0.9, 0.75, 0.6)
	var hair = Color(0.35, 0.22, 0.12)
	var tunic = Color(0.45, 0.35, 0.25)
	var pants = Color(0.3, 0.3, 0.4)
	# calça
	var legs = ColorRect.new()
	legs.size = Vector2(10, 8)
	legs.position = Vector2(-5, 4)
	legs.color = pants
	legs.z_index = -1
	sprite.add_child(legs)
	# túnica
	var body = ColorRect.new()
	body.size = Vector2(12, 12)
	body.position = Vector2(-6, -6)
	body.color = tunic
	sprite.add_child(body)
	# cabeça
	var head = ColorRect.new()
	head.size = Vector2(10, 9)
	head.position = Vector2(-5, -14)
	head.color = skin
	sprite.add_child(head)
	# cabelo
	var hair_r = ColorRect.new()
	hair_r.size = Vector2(10, 4)
	hair_r.position = Vector2(-5, -16)
	hair_r.color = hair
	sprite.add_child(hair_r)
	# arma embutida (define a classe)
	var wpn = ColorRect.new()
	wpn.size = Vector2(3, 14)
	wpn.position = Vector2(7, -4)
	wpn.color = EQUIPS.WEAPONS[weapon]["color"]
	wpn.rotation_degrees = 35
	sprite.add_child(wpn)

func _physics_process(delta: float) -> void:
	if dead:
		return
	_regen(delta)
	_combat_tick(delta)
	_handle_input()
	_handle_skills()
	move_and_slide()

func _handle_input() -> void:
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		moving = true
		target = global_position + Vector2(0, -100)
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		moving = true
		target = global_position + Vector2(0, 100)
	elif Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		moving = true
		target = global_position + Vector2(-100, 0)
	elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		moving = true
		target = global_position + Vector2(100, 0)
	else:
		moving = false

func _regen(delta: float) -> void:
	# mana regen SEMPRE (estilo Tibia), escala com level
	mana = minf(mana + (0.5 + level * 0.1) * delta, max_mana())
	# HP regen só FORA de combate
	if not in_combat:
		hp = minf(hp + max_hp() * 0.05 * (delta / 2.0), max_hp())

func _combat_tick(delta: float) -> void:
	if in_combat:
		combat_timer -= delta
		if combat_timer <= 0.0:
			in_combat = false

func enter_combat() -> void:
	in_combat = true
	combat_timer = 6.0

func max_hp() -> int:
	return GameManager.max_hp_for_level(level)

func max_mana() -> int:
	return GameManager.max_mana_for_level(level)

func _play(anim: String) -> void:
	if sprite.has_method("play_anim"):
		sprite.play_anim(anim)

func _unhandled_input(event: InputEvent) -> void:
	if dead:
		return
	if event is InputEventMouseButton and event.pressed:
		target = get_global_mouse_position()
		moving = true
	# skills Q/E/R/G
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_Q: use_skill("Q")
			KEY_E: use_skill("E")
			KEY_R: use_skill("R")
			KEY_G: use_skill("G")
			KEY_F: _try_open_shop()
			KEY_B: _toggle_bag()
			KEY_K: _toggle_skills()

func _try_open_shop() -> void:
	var shops = get_tree().get_nodes_in_group("shop")
	for s in shops:
		if global_position.distance_to(s.global_position) < 120.0:
			s.open()
			return

func _toggle_bag() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("toggle_bag"):
		hud.toggle_bag()

func _toggle_skills() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("toggle_skills"):
		hud.toggle_skills()

func use_skill(slot: String) -> void:
	if dead:
		return
	var sid = char_class + "_" + slot
	var sk = SKILLS_DB.get_skill(sid)
	if sk == null:
		return
	if not GameManager.skill_unlocked(sid):
		return
	if skill_cooldowns.get(sid, 0.0) > 0.0:
		return
	if mana < sk["mana"]:
		return
	mana -= sk["mana"]
	skill_cooldowns[sid] = sk["cooldown"]
	SKILLS_DB.cast(sid, self)

func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_for_next():
		xp -= xp_for_next()
		level += 1
		_on_level_up()

func xp_for_next() -> int:
	return level * 50

func _on_level_up() -> void:
	# estilo Tibia: em combate NÃO enche (só +30 HP/+15 mana); fora enche tudo
	if in_combat:
		hp = minf(hp + 30.0, max_hp())
		mana = minf(mana + 15.0, max_mana())
	else:
		hp = max_hp()
		mana = max_mana()
	skill_points += 1
	AudioManager.play_sfx("level_up")
	stats_changed.emit()

func gain_skill_xp(amount: int) -> void:
	var sid = char_class + "_weapon"
	var cur = skills.get(sid, 10)
	var need = (cur * cur) * 5
	skills[sid] = cur + float(amount) / need * 100.0 / 100.0 * 0.0 + amount / float(need) * 100.0
	if skills[sid] >= 100.0:
		skills[sid] = 0.0
		skills[sid + "_lvl"] = skills.get(sid + "_lvl", 10) + 1

func take_damage(amount: float) -> void:
	if dead:
		return
	enter_combat()
	hp -= amount
	AudioManager.play_sfx("player_hurt")
	_flash_damage()
	stats_changed.emit()
	if hp <= 0.0:
		_die()

func _flash_damage() -> void:
	sprite.modulate = Color(1, 0.3, 0.3)
	var t = get_tree().create_timer(0.15)
	t.timeout.connect(func():
		if is_instance_valid(sprite):
			sprite.modulate = Color.WHITE)

func heal(amount: float) -> void:
	hp = minf(hp + amount, max_hp())
	stats_changed.emit()

func restore_mana(amount: float) -> void:
	mana = minf(mana + amount, max_mana())
	stats_changed.emit()

func _die() -> void:
	dead = true
	hp = 0.0
	velocity = Vector2.ZERO
	_play("death")
	AudioManager.play_sfx("player_death")
	print("player morreu")

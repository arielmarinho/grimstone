extends CharacterBody2D
## Mob base — IA wander/aggro/attack, HP bar flutuante, respawn, loot
## Timers como FILHOS do mob (morrem com ele — sem await solto)
## Strip de magenta em runtime: fundo rosa nunca aparece

const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")
const LOOT = preload("res://scripts/entities/loot_table.gd")

const WANDER_RADIUS = 120.0
const AGGRO_RANGE = 140.0
const ATTACK_RANGE = 46.0
const WANDER_SPEED = 45.0
const CHASE_SPEED = 70.0

var max_hp: int = 40
var hp: int = 40
var damage: int = 8
var xp_reward: int = 20

var dead: bool = false
var dying: bool = false
var home: Vector2
var wander_target: Vector2
var state: String = "wander"
var attack_cooldown: float = 0.0
var respawn_time: float = 8.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hp_bar: ProgressBar = $HpBar

func _ready() -> void:
	add_to_group("mobs")
	home = global_position
	wander_target = global_position
	max_hp = max_hp + randi() % 5 - 2
	hp = max_hp
	var atk := Timer.new()
	atk.one_shot = true
	atk.name = "AtkTimer"
	add_child(atk)
	atk.timeout.connect(_do_attack_hit)
	var rsp := Timer.new()
	rsp.one_shot = true
	rsp.name = "RespawnTimer"
	add_child(rsp)
	rsp.timeout.connect(_do_respawn)
	_build_frames()

const ANIMS = {
	"idle": "res://assets/sprites/animation/enemy/rat/idle/down/rat_idle_down.png",
	"walk": "res://assets/sprites/animation/enemy/rat/walk/down/rat_walk_down.png",
	"attack": "res://assets/sprites/animation/enemy/rat/attack/down/rat_attack_down.png",
	"death": "res://assets/sprites/animation/enemy/rat/death/down/rat_death_down.png",
}

func _build_frames() -> void:
	var sf = SpriteFrames.new()
	sf.remove_animation("default")
	for anim in ANIMS:
		var texs = TEXHELPER.load_sheet(ANIMS[anim])
		if texs.is_empty():
			continue
		sf.add_animation(anim)
		sf.set_animation_speed(anim, 8.0)
		sf.set_animation_loop(anim, anim == "idle" or anim == "walk")
		for t in texs:
			sf.add_frame(anim, _strip_tex(t))
	sprite.sprite_frames = sf
	sprite.play("idle")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _strip_tex(t: Texture2D) -> Texture2D:
	var im = t.get_image()
	if im == null:
		return t
	im.convert(Image.FORMAT_RGBA8)
	for y in range(im.get_height()):
		for x in range(im.get_width()):
			var c = im.get_pixel(x, y)
			if c.a > 0.0 and c.r > 0.65 and c.b > 0.65 and c.g < 0.55 and absf(c.r - c.b) < 0.3:
				im.set_pixel(x, y, Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(im)

func _physics_process(delta: float) -> void:
	if dying or dead:
		return
	var player = _get_player()
	if player == null:
		return

	var d = global_position.distance_to(player.global_position)
	if d <= ATTACK_RANGE:
		state = "attack"
	elif d <= AGGRO_RANGE:
		state = "chase"
	else:
		state = "wander"

	match state:
		"wander":
			if global_position.distance_to(wander_target) < 8.0:
				var ang = randf() * TAU
				wander_target = home + Vector2(cos(ang), sin(ang)) * (randf() * WANDER_RADIUS)
			_move(wander_target, WANDER_SPEED)
		"chase":
			if player.dead:
				state = "wander"
				return
			_move(player.global_position, CHASE_SPEED)
		"attack":
			velocity = Vector2.ZERO
			attack_cooldown -= delta
			if attack_cooldown <= 0.0 and not player.dead:
				attack_cooldown = 1.2
				sprite.play("attack")
				$AtkTimer.start(0.3)

	hp_bar.value = float(hp) / float(max_hp) * 100.0

func _do_attack_hit() -> void:
	if dying or dead:
		return
	var player = _get_player()
	if player != null and not player.dead:
		player.take_damage(damage)

func _move(dest: Vector2, speed: float) -> void:
	var dir = (dest - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	sprite.flip_h = dir.x > 0
	if sprite.animation != "walk":
		sprite.play("walk")

func _get_player():
	var nodes = get_tree().get_nodes_in_group("player")
	return nodes[0] if nodes.size() > 0 else null

func take_damage(amount: int) -> void:
	if dead or dying:
		return
	hp -= amount
	hp_bar.value = float(hp) / float(max_hp) * 100.0
	if hp <= 0:
		die()

func die() -> void:
	dying = true
	dead = true
	hp = 0
	velocity = Vector2.ZERO
	hp_bar.value = 0
	sprite.play("death")
	GameManager.add_xp(xp_reward)
	LOOT.roll_drop(global_position, get_parent())
	$RespawnTimer.start(respawn_time)

func _do_respawn() -> void:
	dead = false
	dying = false
	hp = max_hp
	global_position = home
	sprite.play("idle")
	hp_bar.value = 100

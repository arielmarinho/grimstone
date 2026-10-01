extends CharacterBody2D
## Mob base — IA wander/aggro/attack, 4 direcoes, timers filhos, strip magenta
## Subclasses definem: tipo (sprite), stats, loot

const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")

const WANDER_RADIUS = 240.0
const AGGRO_RANGE = 280.0
const ATTACK_RANGE = 80.0
const WANDER_SPEED = 90.0
const CHASE_SPEED = 140.0

# tipo do monstro — muda sprite/stats/loot
var mob_type: String = "rat"

# stats por tipo (Tibia-style: progressao de dificuldade)
const TYPES = {
	"rat": {"hp": 40, "dano": 8, "xp": 20, "vel": 1.0, "skill": "espada"},
	"slime": {"hp": 60, "dano": 10, "xp": 30, "vel": 0.7, "skill": "espada"},
	"bat": {"hp": 30, "dano": 6, "xp": 25, "vel": 1.6, "skill": "distancia"},
	"spider": {"hp": 90, "dano": 14, "xp": 55, "vel": 1.2, "skill": "espada"},
	"wolf": {"hp": 130, "dano": 20, "xp": 90, "vel": 1.4, "skill": "espada"},
}

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
var respawn_time: float = 10.0
var facing: String = "down"

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hp_bar: ProgressBar = $HpBar

func _ready() -> void:
	add_to_group("mobs")
	_apply_type()
	home = global_position
	wander_target = global_position
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

func _apply_type() -> void:
	var t = TYPES.get(mob_type, TYPES["rat"])
	max_hp = t["hp"] + randi() % 11 - 5
	hp = max_hp
	damage = t["dano"]
	xp_reward = t["xp"]

const ANIMS = {
	"idle_down": "res://assets/sprites/animation/enemy/rat/idle/down/rat_idle_down.png",
	"idle_up": "res://assets/sprites/animation/enemy/rat/idle/up/rat_idle_up.png",
	"idle_side": "res://assets/sprites/animation/enemy/rat/idle/side/rat_idle_side.png",
	"walk_down": "res://assets/sprites/animation/enemy/rat/walk/down/rat_walk_down.png",
	"walk_up": "res://assets/sprites/animation/enemy/rat/walk/up/rat_walk_up.png",
	"walk_side": "res://assets/sprites/animation/enemy/rat/walk/side/rat_walk_side.png",
	"attack_down": "res://assets/sprites/animation/enemy/rat/attack/down/rat_attack_down.png",
	"attack_up": "res://assets/sprites/animation/enemy/rat/attack/up/rat_attack_up.png",
	"attack_side": "res://assets/sprites/animation/enemy/rat/attack/side/rat_attack_side.png",
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
		sf.set_animation_loop(anim, anim.begins_with("idle") or anim.begins_with("walk"))
		for t in texs:
			sf.add_frame(anim, _strip_tex(t))
	sprite.sprite_frames = sf
	sprite.play("idle_down")
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

	var t = TYPES.get(mob_type, TYPES["rat"])
	var wspeed = WANDER_SPEED * t["vel"]
	var cspeed = CHASE_SPEED * t["vel"]

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
			_move(wander_target, wspeed)
		"chase":
			if player.dead:
				state = "wander"
				return
			_move(player.global_position, cspeed)
		"attack":
			velocity = Vector2.ZERO
			attack_cooldown -= delta
			if attack_cooldown <= 0.0 and not player.dead:
				attack_cooldown = 1.2
				_play_dir("attack")
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
	if abs(dir.x) > abs(dir.y):
		facing = "left" if dir.x < 0 else "right"
	else:
		facing = "up" if dir.y < 0 else "down"
	_play_dir("walk")

func _play_dir(base: String) -> void:
	var anim := base + "_down"
	if facing == "up":
		anim = base + "_up"
		sprite.flip_h = false
	elif facing == "left" or facing == "right":
		anim = base + "_side"
		sprite.flip_h = facing == "left"
	else:
		sprite.flip_h = false
	if sprite.animation != anim:
		sprite.play(anim)

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
	_play_dir("death")
	GameManager.add_xp(xp_reward)
	LootTable.roll_drop(mob_type, global_position, get_parent())
	$RespawnTimer.start(respawn_time)

func _do_respawn() -> void:
	dead = false
	dying = false
	hp = max_hp
	global_position = home
	_play_dir("idle")
	hp_bar.value = 100

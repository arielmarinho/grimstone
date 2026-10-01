extends CharacterBody2D
## Player — clique/tap para mover, ataque automático por proximidade

const SPEED = 140.0

@onready var sprite: AnimatedSprite2D = $Sprite

var target: Vector2 = Vector2.ZERO
var moving: bool = false
var attacking: bool = false
var dead: bool = false
var facing: String = "down"
var attack_cooldown: float = 0.0

func _ready() -> void:
	target = global_position
	_build_frames()

const ANIMS = {
	"idle": "res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png",
	"walk": "res://assets/sprites/animation/player/knight/walk/down/knight_walk_down_base.png",
	"attack": "res://assets/sprites/animation/player/knight/attack/down/knight_attack_down_base.png",
	"death": "res://assets/sprites/animation/player/knight/death/down/knight_death_down_base.png",
}

func _build_frames() -> void:
	var sf = SpriteFrames.new()
	sf.remove_animation("default")
	for anim in ANIMS:
		var tex: Texture2D = _load_tex(ANIMS[anim])
		if tex == null:
			continue
		sf.add_animation(anim)
		sf.set_animation_speed(anim, 8.0)
		sf.set_animation_loop(anim, anim == "idle" or anim == "walk")
		sf.add_frame(anim, tex)
	sprite.sprite_frames = sf
	sprite.play("idle")

func _load_tex(path: String) -> Texture2D:
	var img = Image.load_from_file(ProjectSettings.globalize_path(path))
	if img == null:
		push_error("nao achei textura: " + path)
		return null
	return ImageTexture.create_from_image(img)

func _unhandled_input(event: InputEvent) -> void:
	if dead:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		target = get_global_mouse_position()
		moving = true

func _physics_process(delta: float) -> void:
	if dead:
		return
	attack_cooldown = max(0.0, attack_cooldown - delta)
	if attacking:
		if not sprite.is_playing() or sprite.animation != "attack":
			attacking = false
		return

	var dist = global_position.distance_to(target)
	if moving and dist > 6.0:
		var dir = (target - global_position).normalized()
		velocity = dir * SPEED
		move_and_slide()
		_update_facing(dir)
		_play("walk")
		var mob = _mob_in_range()
		if mob and attack_cooldown <= 0.0:
			_attack(mob)
	else:
		moving = false
		velocity = Vector2.ZERO
		_play("idle")
		var mob = _mob_in_range()
		if mob and attack_cooldown <= 0.0:
			_attack(mob)

func _mob_in_range():
	var best = null
	var best_d = 60.0
	for mob in get_tree().get_nodes_in_group("mobs"):
		if mob.dead:
			continue
		var d = global_position.distance_to(mob.global_position)
		if d < best_d:
			best_d = d
			best = mob
	return best

func _update_facing(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		facing = "left" if dir.x < 0 else "right"
	else:
		facing = "up" if dir.y < 0 else "down"

func _play(anim: String) -> void:
	if sprite.animation != anim:
		sprite.play(anim)

func _attack(mob) -> void:
	attacking = true
	attack_cooldown = 0.8
	_play("attack")
	await get_tree().create_timer(0.3).timeout
	if not dead and is_instance_valid(mob) and not mob.dead:
		mob.take_damage(15)
		GameManager.add_skill_xp("espada", 4)
		print("dano no rato")

func take_damage(amount: int) -> void:
	if dead:
		return
	GameManager.hp = max(0, GameManager.hp - amount)
	GameManager.add_skill_xp("defesa", 2)
	print("player tomou dano: ", amount, " hp=", GameManager.hp)
	if GameManager.hp <= 0:
		die()

func die() -> void:
	dead = true
	velocity = Vector2.ZERO
	_play("death")
	print("player morreu")

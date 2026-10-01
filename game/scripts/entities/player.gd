extends CharacterBody2D
## Player — clique para andar, classes estilo Rucoy (arma define classe),
## troca de arma com teclas 1-4, customização cabelo (Y) e túnica (T)

const SPEED = 140.0

@onready var sprite: AnimatedSprite2D = $Sprite

var target: Vector2 = Vector2.ZERO
var moving: bool = false
var attacking: bool = false
var dead: bool = false
var facing: String = "down"
var attack_cooldown: float = 0.0

var weapon: String = "sword"
var hair_color: String = "castanho"
var tunic_color: String = "castanho"

const ANIMS = {
	"idle": "res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png",
	"walk": "res://assets/sprites/animation/player/knight/walk/down/knight_walk_down_base.png",
	"attack": "res://assets/sprites/animation/player/knight/attack/down/knight_attack_down_base.png",
	"death": "res://assets/sprites/animation/player/knight/death/down/knight_death_down_base.png",
}

func _ready() -> void:
	target = global_position
	_build_frames()

func _build_frames() -> void:
	var sf = SpriteFrames.new()
	sf.remove_animation("default")
	for anim in ANIMS:
		var texs = TexHelper.load_sheet_custom(ANIMS[anim], weapon, hair_color, tunic_color)
		if texs.is_empty():
			continue
		sf.add_animation(anim)
		sf.set_animation_speed(anim, 8.0)
		sf.set_animation_loop(anim, anim == "idle" or anim == "walk")
		for t in texs:
			sf.add_frame(anim, t)
	sprite.sprite_frames = sf
	sprite.play("idle")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _unhandled_input(event: InputEvent) -> void:
	if dead:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var weapons = ["sword", "axe", "bow", "staff"]
		if event.keycode >= KEY_1 and event.keycode <= KEY_4:
			var idx = event.keycode - KEY_1
			if idx < weapons.size() and weapons[idx] != weapon:
				weapon = weapons[idx]
				_build_frames()
				print("arma: ", Equips.WEAPONS[weapon]["nome"], " (", Equips.WEAPONS[weapon]["classe"], ")")
		if event.keycode == KEY_T:
			var cores = Equips.CLOTHES_COLORS.keys()
			var i = cores.find(tunic_color)
			tunic_color = cores[(i + 1) % cores.size()]
			_build_frames()
			print("tunica: ", tunic_color)
		if event.keycode == KEY_Y:
			var cores = Equips.CLOTHES_COLORS.keys()
			var i = cores.find(hair_color)
			hair_color = cores[(i + 1) % cores.size()]
			_build_frames()
			print("cabelo: ", hair_color)
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos = get_global_mouse_position()
		target = world_pos
		moving = true
		var mobs = get_tree().get_nodes_in_group("mobs")
		for mob in mobs:
			if not mob.dead and mob.global_position.distance_to(world_pos) < 40.0:
				target = mob.global_position
				moving = true
				break

func _physics_process(delta: float) -> void:
	if dead:
		return
	attack_cooldown = max(0.0, attack_cooldown - delta)
	if attacking:
		if not sprite.is_playing() or sprite.animation != "attack":
			attacking = false
		return

	var w = Equips.WEAPONS[weapon]
	var dist = global_position.distance_to(target)
	if moving and dist > 6.0:
		var dir = (target - global_position).normalized()
		velocity = dir * SPEED
		move_and_slide()
		_update_facing(dir)
		_play("walk")
		var mob = _mob_in_range(w["alcance"])
		if mob and attack_cooldown <= 0.0:
			_attack(mob)
	else:
		moving = false
		velocity = Vector2.ZERO
		_play("idle")
		var mob = _mob_in_range(w["alcance"])
		if mob and attack_cooldown <= 0.0:
			_attack(mob)

func _mob_in_range(max_d: float):
	var best = null
	var best_d = max_d
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
	var w = Equips.WEAPONS[weapon]
	_update_facing(mob.global_position - global_position)
	attacking = true
	attack_cooldown = w["cooldown"]
	_play("attack")
	var dano: int = w["dano"] + randi() % 5 - 2
	if w["tipo"] == "melee":
		await get_tree().create_timer(0.3).timeout
		if not dead and is_instance_valid(mob) and not mob.dead:
			GameManager.add_skill_xp(w["skill"], 4)
			mob.take_damage(dano)
			_spawn_damage_number(mob.global_position, dano)
	else:
		await get_tree().create_timer(0.25).timeout
		if dead:
			return
		var proj = preload("res://scripts/entities/projectile.gd").new()
		proj.setup(global_position, mob.global_position, dano, "bow" if weapon == "bow" else "staff")
		get_parent().add_child(proj)
		GameManager.add_skill_xp(w["skill"], 4)

func _spawn_damage_number(pos: Vector2, amount: int) -> void:
	var lbl = Label.new()
	lbl.text = str(amount)
	lbl.position = pos + Vector2(-8, -50)
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	get_parent().add_child(lbl)
	var tw = lbl.create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 30, 0.6)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.6)
	tw.tween_callback(lbl.queue_free)

func take_damage(amount: int) -> void:
	if dead:
		return
	GameManager.hp = max(0, GameManager.hp - amount)
	GameManager.add_skill_xp("defesa", 2)
	if GameManager.hp <= 0:
		die()

func die() -> void:
	dead = true
	velocity = Vector2.ZERO
	_play("death")
	print("player morreu")

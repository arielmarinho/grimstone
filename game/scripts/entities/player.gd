extends CharacterBody2D

signal died

const SPEED := 110.0
const ATTACK_RANGE := 46.0
const ATTACK_COOLDOWN := 0.55
const SKILL_COOLDOWN := 1.2

var ANIMS := {
	"idle_down": "res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png",
	"idle_up": "res://assets/sprites/animation/player/knight/idle/up/knight_idle_up_base.png",
	"idle_side": "res://assets/sprites/animation/player/knight/idle/side/knight_idle_side_base.png",
	"walk_down": "res://assets/sprites/animation/player/knight/walk/down/knight_walk_down_base.png",
	"walk_up": "res://assets/sprites/animation/player/knight/walk/up/knight_walk_up_base.png",
	"walk_side": "res://assets/sprites/animation/player/knight/walk/side/knight_walk_side_base.png",
	"attack_down": "res://assets/sprites/animation/player/knight/attack/down/knight_attack_down_base.png",
	"attack_up": "res://assets/sprites/animation/player/knight/attack/up/knight_attack_up_base.png",
	"attack_side": "res://assets/sprites/animation/player/knight/attack/side/knight_attack_side_base.png",
	"death": "res://assets/sprites/animation/player/knight/death/down/knight_death_down_base.png",
}

var facing := "down"
var attack_timer := 0.0
var skill_timer := 0.0
var dead := false
var hair_color := "castanho"
var tunic_color := "castanho"
var pants_color := "marrom"
var net_peer_id := 0
var target: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $Anim

func _ready() -> void:
	GameManager.register_player(self)
	_build_frames()
	apply_recolor()
	sprite.play("idle_down")

func _build_frames() -> void:
	var sf := SpriteFrames.new()
	for anim_name in ANIMS:
		var texs: Array[Texture2D]
		if "_down" in anim_name or anim_name == "death":
			# down/death: ARTE REAL (a aprovada — pixel art com rosto/expressao)
			texs = TEXHELPER.load_sheet_custom(ANIMS[anim_name], GameManager.weapon_base(), hair_color, tunic_color, pants_color)
		else:
			# up/side: ARTE REAL NAS 4 DIRECOES (PNGs gerados por IA no estilo da
			# referencia, quantizados pra paleta do down) — fim do procedural
			texs = TEXHELPER.load_sheet_custom(ANIMS[anim_name], GameManager.weapon_base(), hair_color, tunic_color, pants_color)
		if texs.is_empty():
			continue
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, 6.0)
		for t in texs:
			sf.add_frame(anim_name, t)
	anim.sprite_frames = sf

func apply_recolor() -> void:
	# recolore do PNG real pra customizacao (tecla T/Y): troca cor da túnica/cabelo
	pass

func _physics_process(delta: float) -> void:
	if dead:
		return
	attack_timer = maxf(0.0, attack_timer - delta)
	skill_timer = maxf(0.0, skill_timer - delta)

	var dir := Vector2.ZERO
	if net_peer_id == 0:
		# input local (teclado + touch)
		dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if TouchControls.joy_vec.length() > 0.2:
			# touch: movimento continuo na direcao do joystick
			dir = TouchControls.joy_vec
		if dir != Vector2.ZERO:
			target = null
		# tap em qualquer lugar = mover/atacar (estilo Rucoy)
		if TouchControls.tap_pos != Vector2.INF:
			var tp := TouchControls.tap_pos
			TouchControls.tap_pos = Vector2.INF
			var to_tap := tp - global_position
			if to_tap.length() > 8.0:
				dir = to_tap.normalized()
				target = null
			else:
				_try_attack()
		# teclado: espaco = atacar
		if Input.is_key_pressed(KEY_SPACE):
			_try_attack()
	else:
		# player remoto: interpolacao da posicao recebida
		var dist := (net_target_pos - global_position).length()
		if dist > 300.0:
			global_position = net_target_pos
		else:
			global_position = global_position.lerp(net_target_pos, 0.25)

	if dir != Vector2.ZERO:
		velocity = dir * SPEED
		move_and_slide()
		_update_facing(dir)
		_play_anim("walk")
	else:
		velocity = Vector2.ZERO
		_play_anim("idle")
	# clamp de seguranca: nunca sair do mapa
	global_position.x = clampf(global_position.x, 40.0, 2008.0)
	global_position.y = clampf(global_position.y, 40.0, 2008.0)

func _update_facing(dir: Vector2) -> void:
	if absf(dir.x) > absf(dir.y):
		facing = "side"
		sprite.flip_h = dir.x < 0.0
	else:
		facing = "up" if dir.y < 0.0 else "down"
		sprite.flip_h = false

func _play_anim(kind: String) -> void:
	var name := kind + "_" + facing
	if not anim.has_animation(name):
		name = kind + "_down"
	if sprite.animation != name or not anim.is_playing():
		sprite.play(name)

func _try_attack() -> void:
	if attack_timer > 0.0 or dead:
		return
	attack_timer = ATTACK_COOLDOWN
	_play_anim("attack")
	# som por arma
	var w := GameManager.weapon_base()
	if w == "bow":
		AUDIOMANAGER.play_sfx("shoot")
	elif w == "staff":
		AUDIOMANAGER.play_sfx("cast")
	else:
		AUDIOMANAGER.play_sfx("hit")
	# alvo: mob mais proximo no range
	var best: Node2D = null
	var best_d := ATTACK_RANGE
	for m in get_tree().get_nodes_in_group("mobs"):
		if not is_instance_valid(m) or m.dead:
			continue
		var d := global_position.distance_to(m.global_position)
		if d < best_d:
			best_d = d
			best = m
	if best != null:
		var dmg := int(GameManager.weapon_dano_mult() * GameManager.dano_base())
		best.take_damage(dmg, multiplayer.get_unique_id() if multiplayer.multiplayer_peer != null else 0)
		FX.float_text(best.global_position, str(dmg), Color(1, 0.9, 0.3))

func _use_skill(id: String) -> void:
	if skill_timer > 0.0 or dead:
		return
	var sk = SKILLS_DB.get_skill(id)
	if sk == null:
		return
	if not GameManager.skill_available(id):
		FX.float_text(global_position, "Skill indisponivel", Color(1, 0.4, 0.4))
		return
	skill_timer = SKILL_COOLDOWN
	SKILLS_DB.use_skill(id, self)

func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack"):
		_play_anim("idle")

func _flash_hurt() -> void:
	# flash VERMELHO ao tomar dano (v0.6.7) + som
	var tw := create_tween()
	sprite.modulate = Color(1, 0.3, 0.3)
	tw.tween_property(sprite, "modulate", Color(1, 1, 1), 0.18)
	AUDIOMANAGER.play_sfx("player_hurt")

func take_damage(dmg: int, from_peer: int = 0) -> void:
	if dead:
		return
	GameManager.hp -= dmg
	_flash_hurt()
	# tremida curta de camera (v0.6.7)
	if camera_shake_available():
		do_camera_shake()
	if GameManager.hp <= 0:
		GameManager.hp = 0
		dead = true
		sprite.play("death")
		AUDIOMANAGER.play_sfx("player_death")
		died.emit()
		GameManager.on_player_died()

func camera_shake_available() -> bool:
	return has_node("../Camera2D") or has_node("Camera2D")

func do_camera_shake() -> void:
	var cam: Camera2D = null
	if has_node("../Camera2D"):
		cam = get_node("../Camera2D")
	elif has_node("Camera2D"):
		cam = get_node("Camera2D")
	if cam == null:
		return
	var orig := cam.offset
	var tw := create_tween()
	tw.tween_property(cam, "offset", orig + Vector2(6, 4), 0.05)
	tw.tween_property(cam, "offset", orig + Vector2(-5, -3), 0.05)
	tw.tween_property(cam, "offset", orig, 0.03)

func heal(amount: int) -> void:
	GameManager.hp = mini(GameManager.hp + amount, GameManager.max_hp())
	FX.float_text(global_position, "+" + str(amount), Color(0.3, 1, 0.4))

func _on_died_signal() -> void:
	pass

extends CharacterBody2D

signal died

const SPEED := 110.0
const ANIMS = {
	"idle_down": "res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png",
	"idle_up": "res://assets/sprites/animation/player/knight/idle/up/knight_idle_up_base.png",
	"idle_side": "res://assets/sprites/animation/player/knight/idle/side/knight_idle_side_base.png",
	"walk_down": "res://assets/sprites/animation/player/knight/walk/down/knight_walk_down_base.png",
	"walk_up": "res://assets/sprites/animation/player/knight/walk/up/knight_walk_up_base.png",
	"walk_side": "res://assets/sprites/animation/player/knight/walk/side/knight_walk_side_base.png",
	"attack_down": "res://assets/sprites/animation/player/knight/attack/down/knight_attack_down_base.png",
	"attack_up": "res://assets/sprites/animation/player/knight/attack/up/knight_attack_up_base.png",
	"attack_side": "res://assets/sprites/animation/player/knight/attack/side/knight_attack_side_base.png",
	"death": "res://assets/sprites/animation/player/knight/death/down/knight_death_base.png",
}

var hp: int
var mana: int
var xp: int = 0
var level: int = 1
var skill_xp := {"espada": 0, "machado": 0, "arco": 0, "magia": 0, "defesa": 0}
var facing := "down"
var attacking := false
var attack_cd := 0.0
var dead := false
var hair_color := "castanho"
var tunic_color := "castanho"
var pants_color := "castanho"
var in_combat := false
var combat_timer := 0.0
var well_fed_time := 0.0
var regen_accum := 0.0
var mana_accum := 0.0
var hurt_flash := 0.0
var cam_shake := 0.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var cam: Camera2D = $Cam

func _ready() -> void:
	_build_frames()
	sprite.play("idle_down")
	hp = GameManager.max_hp_for_level(level)
	mana = GameManager.max_mana_for_level(level)
	FX.bind_player(self)

func _build_frames() -> void:
	TEXHELPER.CURRENT_PANTS = pants_color
	var sf = SpriteFrames.new()
	sf.remove_animation("default")
	for anim in ANIMS:
		# HIBRIDO CRITERIOSO: down/death usam a ARTE REAL aprovada (pixel art com
		# rosto/expressao); up usa a ARTE REAL editada (rosto vira cabelo = costas
		# de verdade); side usa o PERFIL DE VERDADE (orelha/olho/tronco estreito/
		# espada na frente, cores exatas da arte real). Flip da arte de frente
		# para o lado é PROIBIDO (silhueta larga = boneco feio).
		var texs: Array
		if "_down" in anim or anim == "death":
			# down/death: ARTE REAL (a aprovada — pixel art com rosto/expressao)
			texs = TEXHELPER.load_sheet_custom(ANIMS[anim], GameManager.weapon_base(), hair_color, tunic_color, pants_color)
		elif "_up" in anim:
			# up: ARTE REAL editada (rosto vira cabelo = costas de verdade, mesma arte)
			texs = TEXHELPER.load_sheet_up_real(ANIMS[anim].replace("/up/", "/down/"), hair_color, tunic_color)
		else:
			# side: PERFIL DE VERDADE (orelha/olho/tronco estreito/espada na frente,
			# cores exatas da arte real) — flip da arte de frente é proibido
			texs = TEXHELPER.load_sheet_procedural_custom(ANIMS[anim], GameManager.weapon_base(), hair_color, tunic_color, pants_color)
		if texs.is_empty():
			continue
		sf.add_animation(anim)
		sf.set_animation_speed(anim, 8.0)
		sf.set_animation_loop(anim, anim.begins_with("idle") or anim.begins_with("walk"))
		for t in texs:
			sf.add_frame(anim, _strip_tex(t))
	sprite.sprite_frames = sf

func _strip_tex(t: Texture2D) -> Texture2D:
	return t

func _physics_process(delta: float) -> void:
	if dead:
		return
	attack_cd = maxf(0.0, attack_cd - delta)
	if in_combat:
		combat_timer -= delta
		if combat_timer <= 0.0:
			in_combat = false
	var input_vec := Vector2.ZERO
	if TouchControls.joy_vec.length() > 0.2:
		input_vec = TouchControls.joy_vec
	else:
		input_vec = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_vec * SPEED
	move_and_slide()
	# clamp de seguranca: nunca sair do mapa
	position.x = clampf(position.x, 40.0, 2008.0)
	position.y = clampf(position.y, 40.0, 2008.0)
	if input_vec.length() > 0.1:
		if absf(input_vec.x) > absf(input_vec.y):
			facing = "side"
			sprite.flip_h = input_vec.x < 0
		else:
			facing = "down" if input_vec.y > 0 else "up"
			sprite.flip_h = false
	# regen estilo Tibia: mana sempre (lenta), HP so fora de combate
	mana_accum += delta
	regen_accum += delta
	var fed_mult := 2.0 if well_fed_time > 0.0 else 1.0
	if well_fed_time > 0.0:
		well_fed_time -= delta
	if mana_accum >= 2.0:
		mana_accum = 0.0
		if mana < GameManager.max_mana_for_level(level):
			mana = mini(GameManager.max_mana_for_level(level), mana + int(1 + level * 0.2 * fed_mult))
			FX.mana_gain(self, 1 + int(level * 0.2 * fed_mult))
	if not in_combat and regen_accum >= 2.0:
		regen_accum = 0.0
		if hp < GameManager.max_hp_for_level(level):
			hp = mini(GameManager.max_hp_for_level(level), hp + maxi(1, int(GameManager.max_hp_for_level(level) * 0.05 * fed_mult)))
			FX.heal_gain(self, maxi(1, int(GameManager.max_hp_for_level(level) * 0.05 * fed_mult)))
	# animacao
	var anim := ""
	if attacking:
		anim = "attack_" + facing
	elif input_vec.length() > 0.1:
		anim = "walk_" + facing
	else:
		anim = "idle_" + facing
	if sprite.animation != anim:
		sprite.play(anim)
	# flash de dano + shake
	if hurt_flash > 0.0:
		hurt_flash -= delta
		sprite.modulate = Color(1, 0.3, 0.3)
	else:
		sprite.modulate = Color(1, 1, 1)
	if cam_shake > 0.0:
		cam_shake -= delta
		cam.offset = Vector2(randf_range(-3, 3), randf_range(-3, 3))
	else:
		cam.offset = Vector2.ZERO
	# skills Q/E/R/G + runas Z/X
	if Input.is_action_just_pressed("skill_q") or TouchControls.btn_q:
		_use_skill("q")
	elif Input.is_action_just_pressed("skill_e") or TouchControls.btn_e:
		_use_skill("e")
	elif Input.is_action_just_pressed("skill_r") or TouchControls.btn_r:
		_use_skill("r")
	elif Input.is_action_just_pressed("skill_g") or TouchControls.btn_g:
		_use_skill("g")
	elif Input.is_key_pressed(KEY_Z):
		_use_rune("z")
	elif Input.is_key_pressed(KEY_X):
		_use_rune("x")

func _use_skill(key: String) -> void:
	if attacking or attack_cd > 0.0:
		return
	var sk = SkillsDB.get_skill(GameManager.weapon_base(), key)
	if sk.is_empty():
		return
	if mana < int(sk.get("mana", 0)):
		return
	mana -= int(sk.get("mana", 0))
	attacking = true
	attack_cd = float(sk.get("cd", 0.8))
	sprite.play("attack_" + facing)
	AudioManager.play_sfx("cast")
	await sprite.animation_finished
	attacking = false
	_deal_skill_damage(sk)

func _deal_skill_damage(sk: Dictionary) -> void:
	var base_dmg := GameManager.weapon_dano_mult() * float(sk.get("dano", 10))
	for mob in get_tree().get_nodes_in_group("mobs"):
		if mob.has_method("take_damage") and position.distance_to(mob.position) < float(sk.get("alcance", 90)):
			mob.take_damage(int(base_dmg), get_instance_id())

func _use_rune(slot: String) -> void:
	var rune = GameManager.belt_get(slot)
	if rune == "":
		return
	var nearest = null
	var best := 99999.0
	for mob in get_tree().get_nodes_in_group("mobs"):
		var d = position.distance_to(mob.position)
		if d < 260.0 and d < best:
			best = d
			nearest = mob
	if nearest == null:
		return
	GameManager.belt_use(slot)
	var rname = rune.split("#")[0]
	if rname == "runa_cura":
		var heal := int(GameManager.max_hp_for_level(level) * 0.4)
		hp = mini(GameManager.max_hp_for_level(level), hp + heal)
		FX.heal_gain(self, heal)
		AudioManager.play_sfx("cast")
		return
	var dmg := int(GameManager.weapon_dano_mult() * {"runa_fogo": 60.0, "runa_gelo": 35.0, "runa_trovoada": 45.0}[rname] * (1.0 + skill_xp.get("magia", 0) * 0.0))
	var proj = preload("res://scripts/entities/projectile.gd").new()
	proj.setup(position, nearest.position, dmg, rname)
	get_parent().add_child(proj)
	AudioManager.play_sfx("cast")

func attack() -> void:
	if attacking or attack_cd > 0.0:
		return
	attacking = true
	attack_cd = 0.45
	sprite.play("attack_" + facing)
	AudioManager.play_sfx("hit")
	await sprite.animation_finished
	attacking = false

func take_damage(dmg: int, from_id: int = 0) -> void:
	if dead:
		return
	hp -= dmg
	hurt_flash = 0.18
	cam_shake = 0.13
	in_combat = true
	combat_timer = 6.0
	AudioManager.play_sfx("player_hurt")
	FX.hurt_text(self, dmg)
	if hp <= 0:
		hp = 0
		dead = true
		sprite.play("death")
		AudioManager.play_sfx("player_death")
		died.emit()

func add_xp(n: int) -> void:
	xp += n
	FX.xp_gain(self, n)
	while xp >= GameManager.xp_need(level):
		xp -= GameManager.xp_need(level)
		level += 1
		# level up estilo Tibia: NAO enche em combate (+30 hp/+15 mana)
		if in_combat:
			hp = mini(GameManager.max_hp_for_level(level), hp + 30)
			mana = mini(GameManager.max_mana_for_level(level), mana + 15)
		else:
			hp = GameManager.max_hp_for_level(level)
			mana = GameManager.max_mana_for_level(level)
		AudioManager.play_sfx("level_up")
		FX.level_up(self, level)

func add_skill_xp(skill: String, n: int) -> void:
	if not skill_xp.has(skill):
		return
	var before := skill_xp[skill]
	skill_xp[skill] += n
	if skill_xp[skill] / 5 != before / 5:
		FX.skill_up(self, skill, skill_xp[skill] / 5)

extends CharacterBody2D
## Player — classes estilo Rucoy (arma define classe), SKILLS Q/E + R/G (city2),
## flechas, critico, customizacao T/Y/U (tunica/cabelo/calca), LEVEL UP com efeito
## ANIMACOES: 4 direcoes REAIS (up/side/down) via procedural — idle/walk/attack/death

const EQUIPS = preload("res://scripts/autoload/equips.gd")
const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")
const SKILLS = preload("res://scripts/autoload/skills_db.gd")

signal feedback(msg: String)

const SPEED = 260.0

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
var pants_color: String = "marrom"

# skills ativas (estilo Rucoy) — Q/E basicas, R/G avancadas (desbloqueia na city2)
var skill_ready := {"Q": true, "E": true, "R": true, "G": true}
var skill_cd := {"Q": 0.0, "E": 0.0, "R": 0.0, "G": 0.0}
var buff_golpe: int = 0
var buff_furia_time: float = 0.0
var buff_certeiro: bool = false
var buff_duplo: int = 0
var buff_bersek_time: float = 0.0
var buff_precisao: int = 0
var buff_escudo_time: float = 0.0
var buff_grito_time: float = 0.0
var buff_perfurante: bool = false

var _last_level: int = 1
var _regen_timer: float = 0.0

# ANIMS com paths up/side REAIS — o procedural desenha cada direcao
# (usar o PNG down pra tudo fazia o player andar so pra baixo — bug do usuario)
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
	"death": "res://assets/sprites/animation/player/knight/death/down/knight_death_down_base.png",
}

func _ready() -> void:
	target = global_position
	_last_level = GameManager.level
	_build_frames()

func _notify_level_up() -> void:
	# efeito visual: anel dourado expandindo + texto LEVEL UP!
	var l = Label.new()
	l.text = "LEVEL UP!"
	l.position = global_position + Vector2(-35, -80)
	l.add_theme_font_size_override("font_size", 18)
	l.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 5)
	l.z_index = 50
	get_parent().add_child(l)
	var tw = l.create_tween()
	tw.tween_property(l, "position:y", l.position.y - 30.0, 1.0)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 1.0)
	tw.tween_callback(l.queue_free)
	# anel: sprite circular dourado que expande e some
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for a in range(64):
		var ang = a * TAU / 64.0
		var px = 32 + cos(ang) * 28.0
		var py = 32 + sin(ang) * 28.0
		img.set_pixel(int(px), int(py), Color(1.0, 0.85, 0.25))
	var ring = Sprite2D.new()
	ring.texture = ImageTexture.create_from_image(img)
	ring.position = global_position
	ring.z_index = 40
	get_parent().add_child(ring)
	var tw2 = ring.create_tween()
	tw2.tween_property(ring, "scale", Vector2(2.2, 2.2), 0.6)
	tw2.parallel().tween_property(ring, "modulate:a", 0.0, 0.6)
	tw2.tween_callback(ring.queue_free)

func _build_frames() -> void:
	TEXHELPER.CURRENT_PANTS = pants_color
	var sf = SpriteFrames.new()
	sf.remove_animation("default")
	for anim in ANIMS:
		# HIBRIDO CRITERIOSO: down usa a ARTE REAL (a que o usuario aprovou — pixel
		# art com rosto/expressao); up usa a ARTE REAL editada (rosto vira cabelo =
		# costas de verdade); side usa o PERFIL DE VERDADE (orelha/olho/tronco
		# estreito/espada na frente, cores exatas da arte real). Flip da arte de
		# frente pro lado é PROIBIDO (silhueta larga = boneco feio).
		var texs: Array
		if "_down" in anim or anim == "death":
			# down/death: ARTE REAL (a aprovada — pixel art com rosto/expressao)
			texs = TEXHELPER.load_sheet_custom(ANIMS[anim], GameManager.weapon_base(), hair_color, tunic_color, pants_color)
		else:
			# up/side: ARTE REAL NAS 4 DIRECOES (b64 proprio) se existir no pacote;
			# SEM o b64 (repo/pacote antigo), cai no fallback v0.6.19 validado
			# (up = arte real editada rosto->cabelo, side = perfil procedural) —
			# o jogo NUNCA fica sem animacao, em nenhum estado
			texs = TEXHELPER.load_sheet_custom(ANIMS[anim], GameManager.weapon_base(), hair_color, tunic_color, pants_color)
			if texs.is_empty():
				if "_up" in anim:
					texs = TEXHELPER.load_sheet_up_real(ANIMS[anim].replace("/up/", "/down/"), hair_color, tunic_color)
				else:
					texs = TEXHELPER.load_sheet_procedural_custom(ANIMS[anim], GameManager.weapon_base(), hair_color, tunic_color, pants_color)
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
			if c.a > 0.0 and c.r > 0.47 and c.b > 0.39 and c.g < 0.43 and absf(c.r - c.b) < 0.31:
				im.set_pixel(x, y, Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(im)

func _unhandled_input(event: InputEvent) -> void:
	if dead:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var weapons = ["sword", "axe", "bow", "staff"]
		if event.keycode >= KEY_1 and event.keycode <= KEY_4:
			var idx = event.keycode - KEY_1
			var base = GameManager.weapon_base()
			if idx < weapons.size() and weapons[idx] != base:
				# troca de arma: perde o tier (tier vem do item dropado, teclas 1-4 = arma comum)
				weapon = weapons[idx]
				GameManager.weapon = weapon
				_build_frames()
				print("arma: ", EQUIPS.WEAPONS[GameManager.weapon_base()]["nome"], " (", EQUIPS.WEAPONS[GameManager.weapon_base()]["classe"], ")")
		if event.keycode == KEY_T:
			var cores = EQUIPS.CLOTHES_COLORS.keys()
			var i = cores.find(tunic_color)
			tunic_color = cores[(i + 1) % cores.size()]
			_build_frames()
		if event.keycode == KEY_Y:
			var cores = EQUIPS.CLOTHES_COLORS.keys()
			var i = cores.find(hair_color)
			hair_color = cores[(i + 1) % cores.size()]
			_build_frames()
		if event.keycode == KEY_U:
			var cores = EQUIPS.PANTS_COLORS.keys()
			var i = cores.find(pants_color)
			pants_color = cores[(i + 1) % cores.size()]
			_build_frames()
		if event.keycode == KEY_Q:
			_use_skill("Q")
		if event.keycode == KEY_E:
			_use_skill("E")
		if event.keycode == KEY_R:
			_use_skill("R")
		if event.keycode == KEY_G:
			_use_skill("G")
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos = get_global_mouse_position()
		target = world_pos
		moving = true
		var mobs = get_tree().get_nodes_in_group("mobs")
		for mob in mobs:
			if not mob.dead and mob.global_position.distance_to(world_pos) < 80.0:
				target = mob.global_position
				moving = true
				break

# ---------- SKILLS (estilo Rucoy) ----------
func _skill_for_slot(slot: String) -> Dictionary:
	var list = SKILLS.SKILLS.get(weapon, [])
	for sk in list:
		if sk["tecla"] == slot:
			return sk
	return {}

func _use_skill(slot: String) -> void:
	if dead or not skill_ready[slot]:
		return
	var sk = _skill_for_slot(slot)
	if sk.is_empty():
		return
	if not SKILLS.skill_unlocked(sk):
		_show_feedback("%s desbloqueia ao chegar na VILA (city2)!" % sk["nome"])
		return
	if GameManager.mana < sk["mana"]:
		_show_feedback("Mana insuficiente para %s (%d)" % [sk["nome"], sk["mana"]])
		return
	GameManager.mana -= sk["mana"]
	skill_ready[slot] = false
	skill_cd[slot] = sk["cd"]
	AudioManager.play_sfx("cast")
	match sk["id"]:
		"golpe":
			buff_golpe = 3
			print("GOLPE PODEROSO armado!")
		"rodopio":
			_skill_aoe(2.0)
		"furia":
			buff_furia_time = 8.0
			print("FURIA! +80% dano por 8s")
		"atordoar":
			var mob = _mob_in_range(EQUIPS.WEAPONS[GameManager.weapon_base()]["alcance"])
			if mob != null:
				mob.stunned = 3.0
				mob.take_damage(EQUIPS.WEAPONS[GameManager.weapon_base()]["dano"] * GameManager.weapon_dano_mult() * 2)
				print("ATORDOADO!")
		"certeiro":
			buff_certeiro = true
			print("TIRO CERTEIRO armado!")
		"chuva":
			GameManager.arrows = max(0, GameManager.arrows - 5)
			_skill_aoe(1.5)
		"fogo":
			var mob = _mob_in_range(EQUIPS.WEAPONS[GameManager.weapon_base()]["alcance"])
			if mob != null:
				var proj = preload("res://scripts/entities/projectile.gd").new()
				var dmg = int(EQUIPS.WEAPONS[GameManager.weapon_base()]["dano"] * GameManager.weapon_dano_mult() * 3 * (1.0 + GameManager.skills.get("magia", {"level": 10})["level"] * 0.02))
				proj.setup(global_position, mob.global_position, dmg, "staff", false, true)
				get_parent().add_child(proj)
		"cura":
			var cura = int(GameManager.hp_max * 0.4)
			GameManager.hp = min(GameManager.hp_max, GameManager.hp + cura)
			print("CURA! +", cura, " HP")
		# ----- skills avancadas (city2) -----
		"investida":
			var mob = _mob_in_range(EQUIPS.WEAPONS[GameManager.weapon_base()]["alcance"] * 1.5)
			if mob != null:
				var dir = (mob.global_position - global_position).normalized()
				global_position = mob.global_position - dir * 60.0
				_update_facing(dir)
				mob.take_damage(int(EQUIPS.WEAPONS[GameManager.weapon_base()]["dano"] * GameManager.weapon_dano_mult() * 2.5))
				print("INVESTIDA!")
			else:
				print("nenhum alvo para a investida")
		"terremoto":
			_skill_aoe_stun(2.5, 2.0)
		"golpe_duplo":
			buff_duplo = 2
			print("GOLPE DUPLO armado!")
		"bersek":
			buff_bersek_time = 10.0
			print("BERSERK! +150% dano por 10s")
		"precisao":
			buff_precisao = 3
			print("PRECISAO! proximas 3 flechas sao criticas")
		"tiro_multi":
			var mob = _mob_in_range(EQUIPS.WEAPONS[GameManager.weapon_base()]["alcance"])
			if mob != null:
				if GameManager.arrows < 2:
					print("sem flechas!")
					skill_ready[slot] = true
					skill_cd[slot] = 0.0
					GameManager.mana += sk["mana"]
					return
				GameManager.arrows -= 2
				var proj = preload("res://scripts/entities/projectile.gd").new()
				var dmg = int(EQUIPS.WEAPONS[GameManager.weapon_base()]["dano"] * GameManager.weapon_dano_mult() * 2.5)
				proj.setup(global_position, mob.global_position, dmg, "bow", false)
				get_parent().add_child(proj)
				# explosao de flechas: 3 projeteis em leque
				for spread in [-0.25, 0.25]:
					var proj2 = preload("res://scripts/entities/projectile.gd").new()
					var target2 = mob.global_position + Vector2(cos(spread), sin(spread)) * 100.0
					proj2.setup(global_position, target2, int(dmg * 0.5), "bow", false)
					get_parent().add_child(proj2)
				print("TIRO MULTIPLo!")
		"nevasca":
			_skill_aoe(3.0)
			# efeito visual: anel de gelo
			var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
			img.fill(Color(0, 0, 0, 0))
			for a in range(64):
				var ang = a * TAU / 64.0
				img.set_pixel(int(32 + cos(ang) * 28.0), int(32 + sin(ang) * 28.0), Color(0.6, 0.85, 1.0))
			var ring = Sprite2D.new()
			ring.texture = ImageTexture.create_from_image(img)
			ring.position = global_position
			ring.z_index = 40
			get_parent().add_child(ring)
			var tw2 = ring.create_tween()
			tw2.tween_property(ring, "scale", Vector2(3.0, 3.0), 0.7)
			tw2.parallel().tween_property(ring, "modulate:a", 0.0, 0.7)
			tw2.tween_callback(ring.queue_free)
			print("NEVASCA!")
		"escudo":
			buff_escudo_time = 8.0
			print("ESCUDO SAGRADO! -50% dano por 8s")
		"grito":
			buff_grito_time = 10.0
			print("GRITO DE GUERRA! +30% dano por 10s")
		"perfurante":
			buff_perfurante = true
			print("FLECHA PERFURANTE armada!")
		"meteoro":
			var mob = _mob_in_range(EQUIPS.WEAPONS[GameManager.weapon_base()]["alcance"])
			if mob != null:
				var proj = preload("res://scripts/entities/projectile.gd").new()
				var dmg = int(EQUIPS.WEAPONS[GameManager.weapon_base()]["dano"] * GameManager.weapon_dano_mult() * 4)
				proj.setup(global_position, mob.global_position, dmg, "staff", true, true)
				get_parent().add_child(proj)
				print("METEORO!")
	GameManager.save_game()

func _skill_aoe(mult: float) -> void:
	var w = EQUIPS.WEAPONS[GameManager.weapon_base()]
	var dmg_base = int(w["dano"] * GameManager.weapon_dano_mult() * mult)
	for mob in get_tree().get_nodes_in_group("mobs"):
		if not mob.dead and mob.global_position.distance_to(global_position) < 220.0:
			var crit = randf() < SKILLS.crit_chance(GameManager.skills.get(w["skill"], {"level": 10})["level"])
			var dmg = dmg_base * (2 if crit else 1)
			mob.take_damage(dmg)
			if crit:
				_spawn_crit_text(mob.global_position)

func _skill_aoe_stun(mult: float, stun_time: float) -> void:
	var w = EQUIPS.WEAPONS[GameManager.weapon_base()]
	var dmg_base = int(w["dano"] * GameManager.weapon_dano_mult() * mult)
	for mob in get_tree().get_nodes_in_group("mobs"):
		if not mob.dead and mob.global_position.distance_to(global_position) < 220.0:
			mob.stunned = stun_time
			mob.take_damage(dmg_base)
	# efeito visual: anel de choque
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for a in range(64):
		var ang = a * TAU / 64.0
		img.set_pixel(int(32 + cos(ang) * 28.0), int(32 + sin(ang) * 28.0), Color(0.9, 0.7, 0.3))
	var ring = Sprite2D.new()
	ring.texture = ImageTexture.create_from_image(img)
	ring.position = global_position
	ring.z_index = 40
	get_parent().add_child(ring)
	var tw2 = ring.create_tween()
	tw2.tween_property(ring, "scale", Vector2(3.0, 3.0), 0.7)
	tw2.parallel().tween_property(ring, "modulate:a", 0.0, 0.7)
	tw2.tween_callback(ring.queue_free)

func _spawn_crit_text(pos: Vector2) -> void:
	var l = Label.new()
	l.text = "CRIT!"
	l.position = pos + Vector2(-20, -50)
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 4)
	get_parent().add_child(l)
	var tw = l.create_tween()
	tw.tween_property(l, "position:y", l.position.y - 24.0, 0.6)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.6)
	tw.tween_callback(l.queue_free)

func _show_feedback(msg: String) -> void:
	feedback.emit(msg)

func _physics_process(delta: float) -> void:
	if dead:
		return
	if GameManager.level > _last_level:
		_last_level = GameManager.level
		AudioManager.play_sfx("level_up")
		_notify_level_up()
	attack_cooldown = max(0.0, attack_cooldown - delta)
	for slot in skill_cd:
		if not skill_ready[slot]:
			skill_cd[slot] = max(0.0, skill_cd[slot] - delta)
			if skill_cd[slot] <= 0.0:
				skill_ready[slot] = true
	if buff_furia_time > 0.0:
		buff_furia_time -= delta
	if buff_bersek_time > 0.0:
		buff_bersek_time -= delta
	if buff_escudo_time > 0.0:
		buff_escudo_time -= delta
	if buff_grito_time > 0.0:
		buff_grito_time -= delta
	# regen estilo Tibia: mana sempre, HP fora de combate
	_regen_timer += delta
	if _regen_timer >= 2.0:
		_regen_timer = 0.0
		var mult := 2.0 if GameManager.well_fed_time > 0.0 else 1.0
		GameManager.mana = min(GameManager.mana_max, GameManager.mana + int(2 * mult))
		var in_combat := false
		for m in get_tree().get_nodes_in_group("mobs"):
			if is_instance_valid(m) and not m.dead and not m.dying and m.state == "attack":
				in_combat = true
				break
		if not in_combat:
			GameManager.hp = min(GameManager.hp_max, GameManager.hp + int(GameManager.hp_max * 0.05 * mult))
	if GameManager.well_fed_time > 0.0:
		GameManager.well_fed_time = max(0.0, GameManager.well_fed_time - delta)
	if attacking:
		if not sprite.is_playing() or not sprite.animation.begins_with("attack"):
			attacking = false
		return

	var w = EQUIPS.WEAPONS[GameManager.weapon_base()]
	# touch (Android): joystick virtual define direcao continua (estilo Rucoy)
	if TouchControls.joy_vec.length() > 0.2:
		moving = true
		target = global_position + TouchControls.joy_vec * 100.0
	var dist = global_position.distance_to(target)
	if moving and dist > 6.0:
		var dir = (target - global_position).normalized()
		velocity = dir * SPEED
		move_and_slide()
		# cinto de seguranca: player NUNCA sai do mapa (2048x2048), mesmo se um
		# colisor falhar — centro clampado em 40..2008
		global_position = global_position.clamp(Vector2(40, 40), Vector2(2008, 2008))
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

func _play(base: String) -> void:
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

func _attack(mob) -> void:
	var w = EQUIPS.WEAPONS[GameManager.weapon_base()]
	# arco gasta flechas
	if GameManager.weapon_base() == "bow":
		if GameManager.arrows <= 0:
			# cooldown curto pra nao spammar o feedback a cada frame
			attack_cooldown = 0.6
			_show_feedback("Sem flechas! Compre na loja.")
			return
		GameManager.arrows -= 1
	_update_facing(mob.global_position - global_position)
	attacking = true
	attack_cooldown = w["cooldown"]
	_play("attack")
	var dmg: int = int(w["dano"] * GameManager.weapon_dano_mult()) + randi() % 5 - 2
	if buff_furia_time > 0.0:
		dmg = int(dmg * 1.8)
	if buff_bersek_time > 0.0:
		dmg = int(dmg * 2.5)
	if buff_grito_time > 0.0:
		dmg = int(dmg * 1.3)
	var skill_lv = GameManager.skills.get(w["skill"], {"level": 10})["level"]
	var crit := false
	if (buff_certeiro or buff_precisao > 0) and GameManager.weapon_base() == "bow":
		crit = true
		buff_certeiro = false
		if buff_precisao > 0:
			buff_precisao -= 1
	else:
		crit = randf() < SKILLS.crit_chance(skill_lv)
	if buff_golpe > 0:
		dmg *= buff_golpe
		buff_golpe = 0
	if crit:
		dmg *= 2
	if w["tipo"] == "melee":
		AudioManager.play_sfx("hit")
		await get_tree().create_timer(0.3).timeout
		if not dead and is_instance_valid(mob) and not mob.dead:
			GameManager.add_skill_xp(w["skill"], 4)
			mob.take_damage(dmg)
			if crit:
				_spawn_crit_text(mob.global_position)
			if buff_duplo > 0:
				buff_duplo -= 1
				mob.take_damage(int(dmg * 0.5))
	else:
		AudioManager.play_sfx("shoot" if GameManager.weapon_base() == "bow" else "cast")
		await get_tree().create_timer(0.25).timeout
		if dead:
			return
		var proj = preload("res://scripts/entities/projectile.gd").new()
		proj.setup(global_position, mob.global_position, dmg, "bow" if GameManager.weapon_base() == "bow" else "staff", crit)
		get_parent().add_child(proj)
		GameManager.add_skill_xp(w["skill"], 4)

func take_damage(amount: int) -> void:
	if dead:
		return
	var final_dmg := amount
	if buff_escudo_time > 0.0:
		final_dmg = int(amount * 0.5)
	GameManager.hp = max(0, GameManager.hp - final_dmg)
	AudioManager.play_sfx("player_hurt")
	_flash_hurt()
	GameManager.add_skill_xp("defesa", 2)
	if GameManager.hp <= 0:
		die()

func _flash_hurt() -> void:
	# flash vermelho no player + tremida curta na camera (feedback de dano)
	sprite.modulate = Color(2.5, 0.6, 0.6)
	var tw = create_tween()
	tw.tween_property(sprite, "modulate", Color(1, 1, 1), 0.18)
	var cam = get_node_or_null("Camera")
	if cam:
		var tw2 = create_tween()
		tw2.tween_property(cam, "offset", Vector2(4, -3), 0.04)
		tw2.tween_property(cam, "offset", Vector2(-4, 2), 0.04)
		tw2.tween_property(cam, "offset", Vector2.ZERO, 0.05)

func die() -> void:
	dead = true
	velocity = Vector2.ZERO
	_play("death")
	AudioManager.play_sfx("player_death")
	print("player morreu")
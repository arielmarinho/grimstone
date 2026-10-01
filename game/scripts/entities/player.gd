extends CharacterBody2D
## Player — classes estilo Rucoy (arma define classe), SKILLS Q/E + R/G (city2),
## flechas, critico, customizacao T/Y/U (tunica/cabelo/calca), LEVEL UP com efeito

const EQUIPS = preload("res://scripts/autoload/equips.gd")
const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")
const SKILLS = preload("res://scripts/autoload/skills_db.gd")

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

var _last_level: int = 1

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
		var texs = TEXHELPER.load_sheet_custom(ANIMS[anim], weapon, hair_color, tunic_color, pants_color)
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
			if idx < weapons.size() and weapons[idx] != weapon:
				weapon = weapons[idx]
				_build_frames()
				print("arma: ", EQUIPS.WEAPONS[weapon]["nome"], " (", EQUIPS.WEAPONS[weapon]["classe"], ")")
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
		print(sk["nome"], " desbloqueia ao chegar na VILA (city2)!")
		return
	if GameManager.mana < sk["mana"]:
		print("mana insuficiente para ", sk["nome"])
		return
	GameManager.mana -= sk["mana"]
	skill_ready[slot] = false
	skill_cd[slot] = sk["cd"]
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
			var mob = _mob_in_range(EQUIPS.WEAPONS[weapon]["alcance"])
			if mob != null:
				mob.stunned = 3.0
				mob.take_damage(EQUIPS.WEAPONS[weapon]["dano"] * 2)
				print("ATORDOADO!")
		"certeiro":
			buff_certeiro = true
			print("TIRO CERTEIRO armado!")
		"chuva":
			GameManager.arrows = max(0, GameManager.arrows - 5)
			_skill_aoe(1.5)
		"fogo":
			var mob = _mob_in_range(EQUIPS.WEAPONS[weapon]["alcance"])
			if mob != null:
				var proj = preload("res://scripts/entities/projectile.gd").new()
				var dmg = int(EQUIPS.WEAPONS[weapon]["dano"] * 3 * (1.0 + GameManager.skills.get("magia", {"level": 10})["level"] * 0.02))
				proj.setup(global_position, mob.global_position, dmg, "staff", false, true)
				get_parent().add_child(proj)
		"cura":
			var cura = int(GameManager.hp_max * 0.4)
			GameManager.hp = min(GameManager.hp_max, GameManager.hp + cura)
			print("CURA! +", cura, " HP")
		# ----- skills avancadas (city2) -----
		"investida":
			var mob = _mob_in_range(EQUIPS.WEAPONS[weapon]["alcance"] * 1.5)
			if mob != null:
				var dir = (mob.global_position - global_position).normalized()
				global_position = mob.global_position - dir * 60.0
				_update_facing(dir)
				mob.take_damage(int(EQUIPS.WEAPONS[weapon]["dano"] * 2.5))
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
			var mob = _mob_in_range(EQUIPS.WEAPONS[weapon]["alcance"])
			if mob != null:
				if GameManager.arrows < 2:
					print("sem flechas!")
					skill_ready[slot] = true
					skill_cd[slot] = 0.0
					GameManager.mana += sk["mana"]
					return
				GameManager.arrows -= 2
				var proj = preload("res://scripts/entities/projectile.gd").new()
				var dmg = int(EQUIPS.WEAPONS[weapon]["dano"] * 2.5)
				proj.setup(global_position, mob.global_position, dmg, "bow", false)
				get_parent().add_child(proj)
				_multi_target = mob
				print("TIRO MULTIPLO!")
			else:
				print("nenhum alvo")
		"escudo":
			buff_escudo_time = 10.0
			print("ESCUDO ARCANO! -50% dano por 10s")
		"nevasca":
			_skill_aoe_stun(2.2, 1.5, 2.0)
	GameManager.add_skill_xp(EQUIPS.WEAPONS[weapon]["skill"], 10)

var _multi_target = null

func _skill_aoe_stun(mult: float, stun_time: float, dmg_mult: float = 1.0) -> void:
	var w = EQUIPS.WEAPONS[weapon]
	var dmg_base = int(w["dano"] * mult * dmg_mult)
	var hit_any := false
	for mob in get_tree().get_nodes_in_group("mobs"):
		if not mob.dead and mob.global_position.distance_to(global_position) < 220.0:
			mob.stunned = stun_time
			mob.take_damage(dmg_base)
			hit_any = true
	if hit_any:
		print("AREA! dano x%.1f + atordoados %.0fs" % [mult * dmg_mult, stun_time])

func _skill_aoe(mult: float) -> void:
	var w = EQUIPS.WEAPONS[weapon]
	var dmg_base = int(w["dano"] * mult)
	for mob in get_tree().get_nodes_in_group("mobs"):
		if not mob.dead and mob.global_position.distance_to(global_position) < 200.0:
			var crit = randf() < SKILLS.crit_chance(GameManager.skills.get(w["skill"], {"level": 10})["level"])
			var dmg = dmg_base * (2 if crit else 1)
			mob.take_damage(dmg)
			if crit:
				_spawn_crit_text(mob.global_position)

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

func _physics_process(delta: float) -> void:
	if dead:
		return
	if GameManager.level > _last_level:
		_last_level = GameManager.level
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
	if attacking:
		if not sprite.is_playing() or not sprite.animation.begins_with("attack"):
			attacking = false
		return

	var w = EQUIPS.WEAPONS[weapon]
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
	var w = EQUIPS.WEAPONS[weapon]
	# arco gasta flechas
	if weapon == "bow":
		if GameManager.arrows <= 0:
			print("sem flechas! compre na loja")
			return
		GameManager.arrows -= 1
	_update_facing(mob.global_position - global_position)
	attacking = true
	attack_cooldown = w["cooldown"]
	_play("attack")
	var dmg: int = w["dano"] + randi() % 5 - 2
	if buff_furia_time > 0.0:
		dmg = int(dmg * 1.8)
	if buff_bersek_time > 0.0:
		dmg = int(dmg * 2.5)
	var skill_lv = GameManager.skills.get(w["skill"], {"level": 10})["level"]
	var crit := false
	if buff_certeiro and weapon == "bow":
		crit = true
		buff_certeiro = false
	elif buff_precisao > 0 and weapon == "bow":
		crit = true
		buff_precisao -= 1
	else:
		crit = randf() < SKILLS.crit_chance(skill_lv)
	if buff_golpe > 0:
		dmg *= buff_golpe
		buff_golpe = 0
	if crit:
		dmg *= 2
	var hits := 1
	if buff_duplo > 0 and w["tipo"] == "melee":
		hits = 2
		buff_duplo -= 1
	for h in range(hits):
		if w["tipo"] == "melee":
			await get_tree().create_timer(0.3).timeout
			if dead:
				return
			if is_instance_valid(mob) and not mob.dead:
				GameManager.add_skill_xp(w["skill"], 4)
				mob.take_damage(dmg)
				if crit:
					_spawn_crit_text(mob.global_position)
		else:
			await get_tree().create_timer(0.25).timeout
			if dead:
				return
			var tgt = mob.global_position if is_instance_valid(mob) else global_position
			var proj = preload("res://scripts/entities/projectile.gd").new()
			proj.setup(global_position, tgt, dmg, "bow" if weapon == "bow" else "staff", crit)
			get_parent().add_child(proj)
			GameManager.add_skill_xp(w["skill"], 4)
			# tiro multiplo: explosao em area ao redor do alvo
			if _multi_target != null and is_instance_valid(_multi_target) and not _multi_target.dead:
				for m2 in get_tree().get_nodes_in_group("mobs"):
					if m2 != _multi_target and not m2.dead and m2.global_position.distance_to(_multi_target.global_position) < 150.0:
						m2.take_damage(int(dmg * 0.6))
			_multi_target = null

func take_damage(amount: int) -> void:
	if dead:
		return
	if buff_escudo_time > 0.0:
		amount = int(amount * 0.5)
	GameManager.hp = max(0, GameManager.hp - amount)
	GameManager.add_skill_xp("defesa", 2)
	if GameManager.hp <= 0:
		die()

func die() -> void:
	dead = true
	velocity = Vector2.ZERO
	_play("death")
	print("player morreu")

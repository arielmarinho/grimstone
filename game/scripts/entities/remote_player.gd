extends CharacterBody2D
## RemotePlayer — representação VISUAL de outro player online (não autoritativo)
## O servidor manda posição 15Hz; aqui só interpola e anima

const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")

var peer_id: int = 0
var display_name: String = "???"
var map_name: String = "city1"
var target_pos: Vector2 = Vector2.ZERO
var base_anim: String = "idle"
var facing: String = "down"

var weapon: String = "sword"
var hair_color: String = "castanho"
var tunic_color: String = "castanho"
var pants_color: String = "marrom"

var sprite: AnimatedSprite2D

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
}

func _ready() -> void:
	# RemotePlayer e criado POR CODIGO (nao tem .tscn) — o Sprite precisa existir antes de _build_frames
	sprite = AnimatedSprite2D.new()
	sprite.scale = Vector2(1.15, 1.15)
	add_child(sprite)
	_build_frames()
	_build_name_label()

func setup(id: int, info: Dictionary) -> void:
	peer_id = id
	display_name = str(info.get("name", "???"))
	map_name = str(info.get("map", "city1"))
	var app: Dictionary = info.get("app", {})
	weapon = str(app.get("weapon", "sword"))
	hair_color = str(app.get("hair", "castanho"))
	tunic_color = str(app.get("tunic", "castanho"))
	pants_color = str(app.get("pants", "marrom"))
	if info.has("pos"):
		var p = info["pos"]
		global_position = Vector2(p.x, p.y)
	target_pos = global_position
	_build_frames()
	_build_name_label()

func _build_name_label() -> void:
	var l = Label.new()
	l.name = "NameLabel"
	l.text = display_name
	l.position = Vector2(-50, -66)
	l.size = Vector2(100, 16)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", Color(0.55, 0.85, 1.0))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 3)
	l.z_index = 45
	add_child(l)

func _sprite_sheet_path(anim: String) -> String:
	var class_dir: String = ""
	match weapon.split("#")[0]:
		"spear":
			class_dir = "paladin"
		"staff":
			class_dir = "mage"
		"druid_staff":
			class_dir = "druid"
	if class_dir.is_empty():
		return ANIMS[anim]
	var parts := anim.split("_")
	var action: String = parts[0]
	var direction: String = "down" if action == "death" else parts[1]
	return "res://assets/sprites/animation/player/%s/%s/%s/%s_%s_%s.png" % [class_dir, action, direction, class_dir, action, direction]

func _build_frames() -> void:
	TEXHELPER.CURRENT_PANTS = pants_color
	var sf = SpriteFrames.new()
	sf.remove_animation("default")
	for anim in ANIMS:
		var sheet_path: String = _sprite_sheet_path(anim)
		var texs = TEXHELPER.load_sheet_custom(sheet_path, weapon, hair_color, tunic_color, pants_color)
		if texs.is_empty():
			continue
		sf.add_animation(anim)
		var anim_speed: float = 12.0 if weapon.split("#")[0] == "druid_staff" and anim.begins_with("attack") else 8.0
		sf.set_animation_speed(anim, anim_speed)
		var is_idle: bool = anim.begins_with("idle")
		sf.set_animation_loop(anim, anim.begins_with("walk"))
		if is_idle:
			sf.add_frame(anim, _strip_tex(texs[0]))
		else:
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

func apply_state(pos: Vector2, map: String, anim: String) -> void:
	target_pos = pos
	map_name = map
	# anim vem como "base:facing" (ex: "walk:left")
	var parts = anim.split(":")
	base_anim = parts[0] if parts.size() > 0 else "idle"
	facing = parts[1] if parts.size() > 1 else "down"

func _physics_process(_delta: float) -> void:
	# interpolação suave em direção ao último snapshot (15Hz do servidor)
	var dist = global_position.distance_to(target_pos)
	if dist > 300.0:
		global_position = target_pos  # teleport (troca de mapa etc)
	elif dist > 2.0:
		global_position = global_position.lerp(target_pos, 0.25)
		_play(base_anim if base_anim in ["walk", "idle", "attack"] else "walk")
	else:
		_play("attack" if base_anim == "attack" else "idle")

func _play(base: String) -> void:
	var anim := base + "_down"
	if facing == "up":
		anim = base + "_up"
		sprite.flip_h = false
	elif facing == "left" or facing == "right":
		anim = base + "_side"
		var weapon_base: String = weapon.split("#")[0]
		var native_faces_right: bool = weapon_base not in ["spear", "druid_staff"]
		sprite.flip_h = facing == "left" if native_faces_right else facing == "right"
	else:
		sprite.flip_h = false
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(anim):
		if sprite.animation != anim:
			sprite.play(anim)
		elif base != "idle" and not sprite.is_playing():
			sprite.play(anim)

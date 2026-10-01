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
		_play("idle")

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
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(anim):
		if sprite.animation != anim:
			sprite.play(anim)

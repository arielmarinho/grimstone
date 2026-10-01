class_name TexHelper
extends Object
## TexHelper — carrega sprite real do disco (com strip de magenta); se nao existir,
## gera grafico procedural com 4 DIRECOES e arma por classe
## CURRENT_MOB: roteia o sprite procedural do monstro (setado pelo mob.gd)

const KNIGHT_IDLE := "res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png"

static var CURRENT_MOB: String = "rat"
static var CURRENT_PANTS: String = "marrom"

static func load_sheet_procedural(path: String, frame_count: int = 4) -> Array[Texture2D]:
	# pula o PNG do disco e vai DIRETO pro procedural (roteado por CURRENT_MOB)
	return _procedural(path)

static func load_sheet(path: String, frame_count: int = 4) -> Array[Texture2D]:
	var img := _load_image(path)
	if img != null:
		var out: Array[Texture2D] = []
		var fw = img.get_width() / frame_count
		for i in range(frame_count):
			var fr = img.get_region(Rect2i(i * fw, 0, fw, img.get_height()))
			out.append(ImageTexture.create_from_image(fr))
		return out
	return _procedural(path)

static func load_sheet_custom(path: String, weapon: String, hair: String, tunic: String, pants: String = "marrom") -> Array[Texture2D]:
	var img := _load_image(path)
	if img != null:
		var out: Array[Texture2D] = []
		var fw = img.get_width() / 4
		for i in range(4):
			var fr = img.get_region(Rect2i(i * fw, 0, fw, img.get_height()))
			out.append(ImageTexture.create_from_image(fr))
		return out
	CURRENT_PANTS = pants
	return _procedural(path, weapon, hair, tunic)

static func _strip_magenta(img: Image) -> Image:
	img.convert(Image.FORMAT_RGBA8)
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c = img.get_pixel(x, y)
			if c.a > 0.0 and c.r > 0.47 and c.b > 0.39 and c.g < 0.43 and absf(c.r - c.b) < 0.31:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	return img

static func _load_image(path: String) -> Image:
	var override_path = path.replace("res://assets/", "res://assets_override/")
	var img = Image.load_from_file(ProjectSettings.globalize_path(override_path))
	if img != null:
		return _strip_magenta(img)
	img = Image.load_from_file(ProjectSettings.globalize_path(path))
	if img != null:
		return _strip_magenta(img)
	var f = FileAccess.open(path + ".b64", FileAccess.READ)
	if f == null:
		return null
	var b64 = f.get_as_text().strip_edges()
	if b64.is_empty():
		return null
	var buf = Marshalls.base64_to_raw(b64)
	var dec = Image.new()
	if dec.load_png_from_buffer(buf) != OK:
		push_error("falha ao decodificar: " + path)
		return null
	return _strip_magenta(dec)

static func _dir_from_path(path: String) -> String:
	if "/up/" in path:
		return "up"
	if "/side/" in path:
		return "side"
	return "down"

static func _procedural(path: String, weapon: String = "sword", hair: String = "castanho", tunic: String = "castanho") -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	var is_attack := "attack" in path
	var is_death := "death" in path
	var is_walk := "walk" in path
	var dir := _dir_from_path(path)
	for f in range(4):
		var img = Image.create(96, 96, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		if "enemy" in path:
			preload("res://scripts/entities/mob_sprites.gd").draw_mob(img, CURRENT_MOB, f, is_attack, is_death, is_walk, dir)
		else:
			_draw_knight(img, f, is_attack, is_death, is_walk, weapon, hair, tunic, dir)
		frames.append(ImageTexture.create_from_image(img))
	return frames

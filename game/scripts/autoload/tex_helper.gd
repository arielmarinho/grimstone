class_name TexHelper
extends Object
## TexHelper — carrega sprite real do disco (PNG ou .b64); se nao existir, gera arte procedural

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

static func _load_image(path: String) -> Image:
	var img = Image.load_from_file(ProjectSettings.globalize_path(path))
	if img != null:
		return img
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
	return dec

static func _procedural(path: String) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	var is_rat := "rat" in path
	var is_attack := "attack" in path
	var is_death := "death" in path
	var is_walk := "walk" in path
	for f in range(4):
		var img = Image.create(96, 96, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		if is_rat:
			_draw_rat(img, f, is_attack, is_death, is_walk)
		else:
			_draw_knight(img, f, is_attack, is_death, is_walk)
		frames.append(ImageTexture.create_from_image(img))
	return frames

# ---------- KNIGHT (cabelo castanho, tunica marrom, espada) ----------
static func _draw_knight(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 48
	var bob := 0
	var leg_l := 0
	var leg_r := 0
	if is_walk:
		leg_l = [3, 0, -3, 0][f]
		leg_r = -leg_l
		bob = [0, 1, 0, 1][f]
	elif not is_attack and not is_death:
		bob = [0, 1, 1, 0][f]
	var hair := Color(0.42, 0.28, 0.14)
	var skin := Color(0.87, 0.7, 0.55)
	var tunic := Color(0.55, 0.38, 0.2)
	var belt := Color(0.3, 0.2, 0.1)
	var pants := Color(0.25, 0.2, 0.16)
	var boots := Color(0.35, 0.24, 0.14)
	var steel := Color(0.78, 0.8, 0.84)
	if is_death:
		_draw_rect(img, cx - 16, 78, 32, 8, tunic)
		_draw_rect(img, cx - 22, 78, 8, 8, skin)
		_draw_rect(img, cx - 23, 77, 8, 4, hair)
		_draw_rect(img, cx + 14, 74, 3, 16, steel)
		return
	_draw_rect(img, cx - 8, 64 + leg_l, 6, 12, pants)
	_draw_rect(img, cx + 2, 64 + leg_r, 6, 12, pants)
	_draw_rect(img, cx - 8, 74 + leg_l, 6, 5, boots)
	_draw_rect(img, cx + 2, 74 + leg_r, 6, 5, boots)
	_draw_rect(img, cx - 11, 40 + bob, 22, 24, tunic)
	_draw_rect(img, cx - 11, 60 + bob, 22, 4, belt)
	_draw_rect(img, cx - 8, 26 + bob, 16, 14, skin)
	_draw_rect(img, cx - 9, 23 + bob, 18, 6, hair)
	_draw_rect(img, cx - 9, 27 + bob, 3, 5, hair)
	_draw_rect(img, cx + 6, 27 + bob, 3, 5, hair)
	_draw_rect(img, cx - 5, 32 + bob, 3, 3, Color(0.1, 0.1, 0.15))
	_draw_rect(img, cx + 2, 32 + bob, 3, 3, Color(0.1, 0.1, 0.15))
	var sy := 34 + bob
	if is_attack:
		if f <= 1:
			_draw_rect(img, cx + 12, sy - 8, 4, 16, steel)
		else:
			_draw_rect(img, cx + 10, sy + 4, 14, 4, steel)
			_draw_rect(img, cx + 6, sy + 2, 6, 8, Color(0.9, 0.92, 0.95, 0.6))
	else:
		_draw_rect(img, cx + 14, sy, 4, 22, steel)
	_draw_rect(img, cx + 13, sy + 20, 6, 3, belt)

# ---------- RATO (marrom, olhos vermelhos, orelhas rosas) ----------
static func _draw_rat(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 48
	var fur := Color(0.45, 0.32, 0.18)
	var fur2 := Color(0.55, 0.42, 0.25)
	var ear := Color(0.85, 0.62, 0.65)
	var eye := Color(0.9, 0.12, 0.12)
	var bob := [0, 1, 0, 1][f]
	if is_death:
		_draw_rect(img, cx - 18, 82, 36, 6, fur)
		_draw_rect(img, cx + 16, 80, 10, 4, ear)
		return
	_draw_rect(img, cx - 16, 62 + bob, 30, 16, fur)
	_draw_rect(img, cx - 14, 70 + bob, 26, 8, fur2)
	_draw_rect(img, cx + 10, 58 + bob, 16, 14, fur)
	_draw_rect(img, cx + 24, 64 + bob, 4, 6, fur2)
	_draw_rect(img, cx + 10, 52 + bob, 5, 6, ear)
	_draw_rect(img, cx + 19, 52 + bob, 5, 6, ear)
	_draw_rect(img, cx + 17, 61 + bob, 3, 3, eye)
	var step := 0
	if is_walk:
		step = [2, 0, -2, 0][f]
	_draw_rect(img, cx - 12, 76 + step, 4, 5, fur)
	_draw_rect(img, cx + 2, 76 - step, 4, 5, fur)
	_draw_rect(img, cx - 24, 66 + bob, 8, 3, ear)
	if is_attack and f >= 2:
		_draw_rect(img, cx + 22, 66 + bob, 8, 4, Color(0.75, 0.3, 0.3))
		_draw_rect(img, cx + 24, 66 + bob, 2, 2, Color(0.95, 0.95, 0.9))

static func _draw_rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for j in range(h):
		for i in range(w):
			var px = x + i
			var py = y + j
			if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
				img.set_pixel(px, py, c)

static func load_map(path: String) -> Texture2D:
	var img := _load_image(path)
	if img != null:
		return ImageTexture.create_from_image(img)
	if "rat_cave" in path:
		return _map_cave()
	return _map_city()

# ---------- CIDADE 1 (muralha, fonte central, lojas, lago, portao sul, bueiro) ----------
static func _map_city() -> Texture2D:
	var W := 1024
	var H := 1024
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.42, 0.65, 0.32))
	for i in range(2400):
		var x = randi() % W
		var y = randi() % H
		img.set_pixel(x, y, Color(0.38, 0.6, 0.28))
	var dirt := Color(0.76, 0.65, 0.48)
	for y in range(200, 900):
		for x in range(W / 2 - 30, W / 2 + 30):
			img.set_pixel(x, y, dirt)
	for x in range(200, 900):
		for y in range(H / 2 - 30, H / 2 + 30):
			img.set_pixel(x, y, dirt)
	for y in range(H / 2 - 90, H / 2 + 90):
		for x in range(W / 2 - 90, W / 2 + 90):
			img.set_pixel(x, y, Color(0.62, 0.6, 0.56))
	for y in range(H / 2 - 40, H / 2 + 40):
		for x in range(W / 2 - 40, W / 2 + 40):
			img.set_pixel(x, y, Color(0.55, 0.53, 0.5))
	for y in range(H / 2 - 26, H / 2 + 26):
		for x in range(W / 2 - 26, W / 2 + 26):
			img.set_pixel(x, y, Color(0.3, 0.55, 0.85))
	_draw_rect(img, W / 2 - 6, H / 2 - 14, 12, 28, Color(0.7, 0.68, 0.64))
	_draw_rect(img, W / 2 - 14, H / 2 - 6, 28, 12, Color(0.7, 0.68, 0.64))
	var wall := Color(0.58, 0.56, 0.52)
	var wall_dark := Color(0.48, 0.46, 0.43)
	for i in range(W):
		_draw_rect(img, i, 130, 1, 26, wall)
		_draw_rect(img, i, 130, 1, 4, wall_dark)
		_draw_rect(img, i, 868, 1, 26, wall)
	for j in range(130, 894):
		_draw_rect(img, 130, j, 26, 1, wall)
		_draw_rect(img, 868, j, 26, 1, wall)
	for i in range(140, 860, 40):
		_draw_rect(img, i, 118, 20, 12, wall)
		_draw_rect(img, i, 868, 20, 12, wall)
	for y in range(868, 1024):
		for x in range(W / 2 - 50, W / 2 + 50):
			img.set_pixel(x, y, dirt)
	_draw_rect(img, W / 2 - 56, 850, 12, 60, Color(0.45, 0.3, 0.18))
	_draw_rect(img, W / 2 + 44, 850, 12, 60, Color(0.45, 0.3, 0.18))
	_draw_building(img, 220, 220, 150, 110, Color(0.25, 0.4, 0.75))
	_draw_building(img, 650, 220, 150, 110, Color(0.55, 0.3, 0.7))
	_draw_building(img, 220, 640, 150, 110, Color(0.85, 0.7, 0.25))
	for y in range(600, 820):
		for x in range(640, 840):
			if Vector2(x - 740, y - 710).length() < 95:
				img.set_pixel(x, y, Color(0.28, 0.5, 0.8))
	for x in range(600, 720):
		_draw_rect(img, x, 700, 1, 14, Color(0.55, 0.4, 0.25))
	for pos in [[360, 300], [560, 300], [360, 560], [170, 420], [850, 420], [500, 760]]:
		_draw_tree(img, pos[0], pos[1])
	_draw_rect(img, W / 2 - 24, 780, 48, 40, Color(0.35, 0.35, 0.38))
	_draw_rect(img, W / 2 - 18, 786, 36, 28, Color(0.2, 0.2, 0.22))
	for i in range(5):
		_draw_rect(img, W / 2 - 18, 790 + i * 6, 36, 2, Color(0.5, 0.5, 0.55))
	return ImageTexture.create_from_image(img)

static func _draw_building(img: Image, x: int, y: int, w: int, h: int, roof: Color) -> void:
	for j in range(h / 2, h):
		for i in range(w):
			img.set_pixel(x + i, y + j, Color(0.82, 0.74, 0.6))
	for j in range(0, h / 2):
		for i in range(w - j * 2, j * 2 + 2):
			img.set_pixel(x + i, y + j, roof)
	_draw_rect(img, x + w / 2 - 10, y + h - 26, 20, 26, Color(0.45, 0.3, 0.18))

static func _draw_tree(img: Image, x: int, y: int) -> void:
	_draw_rect(img, x - 4, y, 8, 14, Color(0.45, 0.32, 0.18))
	_draw_rect(img, x - 14, y - 18, 28, 20, Color(0.25, 0.5, 0.22))
	_draw_rect(img, x - 9, y - 24, 18, 8, Color(0.3, 0.55, 0.26))

# ---------- CAVERNA DOS RATOS (pedra escura, grade de saida, caixas, cristais) ----------
static func _map_cave() -> Texture2D:
	var W := 1024
	var H := 1024
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.16, 0.13, 0.11))
	for y in range(60, H - 60):
		for x in range(60, W - 60):
			img.set_pixel(x, y, Color(0.38, 0.33, 0.28))
	for i in range(1600):
		var x = 60 + randi() % (W - 120)
		var y = 60 + randi() % (H - 120)
		img.set_pixel(x, y, Color(0.33, 0.29, 0.24))
	var rock := Color(0.22, 0.19, 0.16)
	for i in range(60):
		var rx = randi() % W
		var ry = randi() % H
		var edge = min(min(rx, W - rx), min(ry, H - ry))
		if edge < 60:
			_draw_rect(img, rx, ry, 6, 6, rock)
	_draw_rect(img, W / 2 - 24, 70, 48, 40, Color(0.35, 0.35, 0.38))
	_draw_rect(img, W / 2 - 18, 76, 36, 28, Color(0.12, 0.12, 0.13))
	for i in range(5):
		_draw_rect(img, W / 2 - 18, 80 + i * 6, 36, 2, Color(0.5, 0.5, 0.55))
	for pos in [[200, 300], [240, 320], [800, 500], [300, 700]]:
		_draw_rect(img, pos[0], pos[1], 40, 40, Color(0.5, 0.36, 0.2))
		_draw_rect(img, pos[0], pos[1], 40, 6, Color(0.6, 0.45, 0.26))
	for pos in [[100, 200], [900, 300], [150, 800], [880, 760]]:
		_draw_rect(img, pos[0], pos[1], 8, 12, Color(0.5, 0.75, 0.9))
	return ImageTexture.create_from_image(img)

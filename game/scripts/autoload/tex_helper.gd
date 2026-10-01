class_name TexHelper
extends Object
## TexHelper — carrega sprite real do disco (com strip de magenta); se nao existir,
## gera grafico procedural com 4 DIRECOES (down/up/side) e arma por classe

const KNIGHT_IDLE := "res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png"

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

static func load_sheet_custom(path: String, weapon: String, hair: String, tunic: String) -> Array[Texture2D]:
	var img := _load_image(path)
	if img != null:
		var out: Array[Texture2D] = []
		var fw = img.get_width() / 4
		for i in range(4):
			var fr = img.get_region(Rect2i(i * fw, 0, fw, img.get_height()))
			out.append(ImageTexture.create_from_image(fr))
		return out
	return _procedural(path, weapon, hair, tunic)

static func _strip_magenta(img: Image) -> Image:
	# remove fundo magenta/rosa de QUALQUER textura na fonte (Tibia-style chroma)
	img.convert(Image.FORMAT_RGBA8)
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c = img.get_pixel(x, y)
			if c.a > 0.0 and c.r > 0.6 and c.b > 0.6 and c.g < 0.5 and absf(c.r - c.b) < 0.35:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	return img

static func _load_image(path: String) -> Image:
	# 1) override local (assets_override/) — instalado pelo usuario, sem tocar no git
	var override_path = path.replace("res://assets/", "res://assets_override/")
	var img = Image.load_from_file(ProjectSettings.globalize_path(override_path))
	if img != null:
		return _strip_magenta(img)
	# 2) PNG normal do projeto
	img = Image.load_from_file(ProjectSettings.globalize_path(path))
	if img != null:
		return _strip_magenta(img)
	# 3) versao .b64 (sprites vao ao git em base64 e sao decodificados em runtime)
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
	var is_rat := "rat" in path
	var is_attack := "attack" in path
	var is_death := "death" in path
	var is_walk := "walk" in path
	var dir := _dir_from_path(path)
	for f in range(4):
		var img = Image.create(96, 96, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		if is_rat:
			_draw_rat(img, f, is_attack, is_death, is_walk)
		else:
			_draw_knight(img, f, is_attack, is_death, is_walk, weapon, hair, tunic, dir)
		frames.append(ImageTexture.create_from_image(img))
	return frames

static var DEFAULT_HAIR := "castanho"
static var DEFAULT_TUNIC := "castanho"

# ---------- KNIGHT 4 DIRECOES (down=frente, up=costas, side=perfil) ----------
static func _draw_knight(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool, weapon: String = "sword", hair_color: String = "castanho", tunic_color: String = "castanho", dir: String = "down") -> void:
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
	if hair_color != "castanho" and Equips.CLOTHES_COLORS.has(hair_color):
		hair = Equips.CLOTHES_COLORS[hair_color]
	var skin := Color(0.88, 0.72, 0.58)
	var skin_sh := Color(0.78, 0.6, 0.46)
	var tunic := Color(0.58, 0.4, 0.22)
	var tunic_d := Color(0.48, 0.32, 0.17)
	if tunic_color != "castanho" and Equips.CLOTHES_COLORS.has(tunic_color):
		tunic = Equips.CLOTHES_COLORS[tunic_color]
		tunic_d = tunic.darkened(0.2)
	var pants := Color(0.28, 0.23, 0.19)
	var boots := Color(0.38, 0.26, 0.15)
	if is_death:
		_draw_ellipse(img, cx + 2, 84, 16, 5, tunic)
		_draw_circle(img, cx - 18, 84, 6, skin)
		_draw_ellipse(img, cx - 20, 82, 6, 3, hair)
		_draw_ellipse(img, cx + 18, 86, 8, 3, pants)
		_draw_rect(img, cx + 14, 90, 14, 2, Color(0.8, 0.82, 0.86))
		return
	_draw_ellipse(img, cx, 88, 11, 3.5, Color(0, 0, 0, 0.25))
	if dir == "up":
		_draw_ellipse(img, cx - 5, 70 + leg_l, 3.5, 8, pants)
		_draw_ellipse(img, cx + 5, 70 + leg_r, 3.5, 8, pants)
		_draw_ellipse(img, cx - 5, 80 + leg_l, 4, 3, boots)
		_draw_ellipse(img, cx + 5, 80 + leg_r, 4, 3, boots)
		_draw_ellipse(img, cx, 52 + bob, 12, 13, tunic)
		_draw_ellipse(img, cx - 4, 56 + bob, 7, 9, tunic_d)
		_draw_rect(img, cx - 10, 62 + bob, 20, 3, Color(0.25, 0.17, 0.1))
		_draw_circle(img, cx, 63.5 + bob, 1.5, Color(0.8, 0.65, 0.3))
		_draw_ellipse(img, cx + 11, 50 + bob, 3, 7, tunic)
		_draw_circle(img, cx + 11, 58 + bob, 2.5, skin)
		if Equips.WEAPONS.has(weapon):
			Equips.draw_weapon(img, weapon, cx - 11, 52 + bob, f, is_attack)
		_draw_circle(img, cx, 32 + bob, 8.5, skin)
		_draw_ellipse(img, cx, 30 + bob, 8.5, 7, hair)
		_draw_ellipse(img, cx - 7, 34 + bob, 3, 5, hair)
		_draw_ellipse(img, cx + 7, 34 + bob, 3, 5, hair)
	elif dir == "side":
		var step := 0
		if is_walk:
			step = [4, 0, -4, 0][f]
		_draw_ellipse(img, cx - 3 + step, 72, 3.5, 8, pants)
		_draw_ellipse(img, cx + 3 - step, 72, 3.5, 8, pants)
		_draw_ellipse(img, cx - 3 + step, 81, 4, 3, boots)
		_draw_ellipse(img, cx + 3 - step, 81, 4, 3, boots)
		_draw_ellipse(img, cx, 52 + bob, 10, 12, tunic)
		_draw_ellipse(img, cx + 2, 56 + bob, 6, 8, tunic_d)
		_draw_rect(img, cx - 8, 62 + bob, 16, 3, Color(0.25, 0.17, 0.1))
		_draw_ellipse(img, cx - 6, 52 + bob, 3, 6, tunic)
		_draw_circle(img, cx + 2, 32 + bob, 8, skin)
		_draw_ellipse(img, cx + 9, 34 + bob, 3, 2.5, skin)
		_draw_ellipse(img, cx - 2, 28 + bob, 7, 5, hair)
		_draw_ellipse(img, cx + 4, 26 + bob, 6, 4, hair)
		_draw_circle(img, cx + 6, 32 + bob, 1.3, Color(0.12, 0.1, 0.14))
		_draw_ellipse(img, cx + 8, 50 + bob, 6, 3, tunic)
		_draw_circle(img, cx + 14, 50 + bob, 2.5, skin)
		var w = Equips.WEAPONS.get(weapon, null)
		if w != null:
			var steel: Color = w.get("cor", Color(0.8, 0.82, 0.86))
			var by := 50 + bob
			var reach := 10
			if is_attack and f >= 2:
				reach = 18
			if weapon == "bow":
				for i in range(10):
					var ang := -1.1 + i * (2.2 / 9.0)
					_draw_circle(img, cx + 16 + cos(ang) * 3.0, by + sin(ang) * 9.0, 1.4, w["cor"])
				_draw_rect(img, cx + 19, by - 9, 1, 18, w["cor_cabo"])
				if is_attack and f >= 2:
					_draw_rect(img, cx + 24, by - 1, 10, 2, Color(0.9, 0.85, 0.7))
			elif weapon == "staff":
				_draw_rect(img, cx + 13, by - 12, 2, 24, w["cor"])
				var orb: Color = w["cor_orb"]
				if is_attack and f >= 2:
					orb = Color(0.75, 0.9, 1.0)
				_draw_circle(img, cx + 14, by - 13, 3, orb)
			else:
				_draw_rect(img, cx + 15, by - 1, reach + 6, 3, steel)
				_draw_rect(img, cx + 13, by - 3, 3, 7, Color(0.55, 0.42, 0.2))
				if weapon == "axe":
					_draw_ellipse(img, cx + 21 + reach, by, 4, 5, steel)
	else:
		_draw_ellipse(img, cx - 5, 70 + leg_l, 3.5, 8, pants)
		_draw_ellipse(img, cx + 5, 70 + leg_r, 3.5, 8, pants)
		_draw_ellipse(img, cx - 5, 80 + leg_l, 4, 3, boots)
		_draw_ellipse(img, cx + 5, 80 + leg_r, 4, 3, boots)
		_draw_ellipse(img, cx, 52 + bob, 12, 13, tunic)
		_draw_ellipse(img, cx + 4, 56 + bob, 7, 9, tunic_d)
		_draw_rect(img, cx - 10, 62 + bob, 20, 3, Color(0.25, 0.17, 0.1))
		_draw_circle(img, cx, 63.5 + bob, 1.5, Color(0.8, 0.65, 0.3))
		_draw_ellipse(img, cx - 11, 50 + bob, 3, 7, tunic)
		_draw_circle(img, cx - 11, 58 + bob, 2.5, skin)
		_draw_circle(img, cx, 32 + bob, 8.5, skin)
		_draw_ellipse(img, cx, 36 + bob, 6, 3, skin_sh)
		_draw_ellipse(img, cx, 27 + bob, 8.5, 5.5, hair)
		_draw_ellipse(img, cx - 7, 31 + bob, 2.5, 4, hair)
		_draw_ellipse(img, cx + 7, 31 + bob, 2.5, 4, hair)
		_draw_circle(img, cx - 3.5, 33 + bob, 1.3, Color(0.12, 0.1, 0.14))
		_draw_circle(img, cx + 3.5, 33 + bob, 1.3, Color(0.12, 0.1, 0.14))
		_draw_circle(img, cx - 3.5, 33.5 + bob, 0.5, Color(0.9, 0.9, 0.9))
		_draw_circle(img, cx + 3.5, 33.5 + bob, 0.5, Color(0.9, 0.9, 0.9))
		if Equips.WEAPONS.has(weapon):
			Equips.draw_weapon(img, weapon, cx + 11, 52 + bob, f, is_attack)

# ---------- RATO ----------
static func _draw_rat(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 44
	var fur := Color(0.48, 0.34, 0.19)
	var fur_d := Color(0.38, 0.27, 0.15)
	var belly := Color(0.72, 0.62, 0.5)
	var ear := Color(0.82, 0.58, 0.6)
	var eye := Color(0.85, 0.1, 0.1)
	var bob: int = [0, 1, 0, 1][f]
	if is_death:
		_draw_ellipse(img, cx, 86, 17, 5, fur)
		_draw_circle(img, cx + 18, 84, 6, fur)
		_draw_circle(img, cx + 15, 80, 3, ear)
		_draw_circle(img, cx + 21, 81, 3, ear)
		_draw_ellipse(img, cx - 8, 78, 2, 5, Color(0.7, 0.5, 0.5))
		_draw_ellipse(img, cx - 2, 77, 2, 5, Color(0.7, 0.5, 0.5))
		return
	_draw_ellipse(img, cx, 88, 15, 3.5, Color(0, 0, 0, 0.25))
	_draw_ellipse(img, cx - 20, 80 - bob * 2, 6, 2.5, ear)
	_draw_ellipse(img, cx - 26, 76 - bob * 3, 5, 2, ear)
	_draw_ellipse(img, cx, 74 + bob, 16, 9, fur)
	_draw_ellipse(img, cx - 2, 78 + bob, 11, 5, belly)
	_draw_circle(img, cx + 16, 66 + bob, 7.5, fur)
	_draw_ellipse(img, cx + 20, 69 + bob, 5, 3, fur_d)
	_draw_circle(img, cx + 24, 68 + bob, 1.5, Color(0.75, 0.5, 0.5))
	_draw_circle(img, cx + 12, 59 + bob, 3.5, ear)
	_draw_circle(img, cx + 20, 58 + bob, 3.5, ear)
	_draw_circle(img, cx + 12, 59 + bob, 1.8, Color(0.7, 0.45, 0.5))
	_draw_circle(img, cx + 20, 58 + bob, 1.8, Color(0.7, 0.45, 0.5))
	_draw_circle(img, cx + 18, 65 + bob, 1.8, eye)
	_draw_circle(img, cx + 18.5, 64.5 + bob, 0.6, Color(1.0, 0.6, 0.6))
	_draw_rect(img, cx + 22, 71 + bob, 1.5, 2.5, Color(0.95, 0.95, 0.9))
	_draw_rect(img, cx + 24, 71 + bob, 1.5, 2.5, Color(0.95, 0.95, 0.9))
	var step := 0
	if is_walk:
		step = [2, 0, -2, 0][f]
	_draw_ellipse(img, cx - 8, 84 + step, 2.5, 2, fur_d)
	_draw_ellipse(img, cx + 2, 84 - step, 2.5, 2, fur_d)
	if is_attack and f >= 2:
		_draw_ellipse(img, cx + 22, 71 + bob, 4, 2.5, Color(0.7, 0.25, 0.25))
		_draw_circle(img, cx + 21, 69.5 + bob, 1, Color(0.95, 0.95, 0.9))

static func _draw_ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, c: Color) -> void:
	for j in range(int(cy - ry) - 1, int(cy + ry) + 2):
		for i in range(int(cx - rx) - 1, int(cx + rx) + 2):
			if i < 0 or j < 0 or i >= img.get_width() or j >= img.get_height():
				continue
			var dx = (i - cx) / max(rx, 0.1)
			var dy = (j - cy) / max(ry, 0.1)
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(i, j, c)

static func _draw_circle(img: Image, cx: float, cy: float, r: float, c: Color) -> void:
	_draw_ellipse(img, cx, cy, r, r, c)

static func _draw_circle_ring(img: Image, cx: float, cy: float, r: float, c: Color) -> void:
	for a in range(72):
		var ang = a * TAU / 72.0
		var px = cx + cos(ang) * r
		var py = cy + sin(ang) * r
		if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
			img.set_pixel(px, py, c)

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

# ---------- CIDADE 1 (muralha, fonte, lojas, lago, portao sul, BUEIRO COM ESCADA) ----------
static func _map_city() -> Texture2D:
	var W := 1024
	var H := 1024
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.45, 0.68, 0.33))
	for i in range(9000):
		var x = randi() % W
		var y = randi() % H
		var shade = 0.4 + randf() * 0.15
		img.set_pixel(x, y, Color(shade, shade + 0.22, shade * 0.7))
	for i in range(140):
		var x = 20 + randi() % (W - 40)
		var y = 20 + randi() % (H - 40)
		_draw_ellipse(img, x, y, 2 + randf() * 3, 1.5 + randf() * 2, Color(0.38, 0.58, 0.28, 0.5))
	var dirt := Color(0.78, 0.66, 0.48)
	var dirt_d := Color(0.7, 0.58, 0.42)
	for y in range(180, 920):
		var wobble = sin(y * 0.05) * 6
		for x in range(W / 2 - 26 + wobble, W / 2 + 26 + wobble):
			var c = dirt if (x + y) % 7 != 0 else dirt_d
			img.set_pixel(x, y, c)
	for x in range(180, 920):
		var wobble = cos(x * 0.05) * 6
		for y in range(H / 2 - 26 + wobble, H / 2 + 26 + wobble):
			var c = dirt if (x + y) % 7 != 0 else dirt_d
			img.set_pixel(x, y, c)
	_draw_circle(img, W / 2, H / 2, 105, Color(0.63, 0.61, 0.57))
	for i in range(400):
		var ang = randf() * TAU
		var r = randf() * 100
		var px = W / 2 + cos(ang) * r
		var py = H / 2 + sin(ang) * r
		img.set_pixel(px, py, Color(0.58, 0.56, 0.52))
	_draw_circle(img, W / 2, H / 2, 45, Color(0.58, 0.56, 0.53))
	_draw_circle(img, W / 2, H / 2, 34, Color(0.3, 0.55, 0.85))
	_draw_circle(img, W / 2, H / 2, 30, Color(0.35, 0.62, 0.9))
	_draw_circle(img, W / 2, H / 2, 12, Color(0.62, 0.6, 0.56))
	_draw_circle(img, W / 2, H / 2, 6, Color(0.7, 0.68, 0.64))
	for i in range(3):
		_draw_ellipse(img, W / 2 + 18 - i * 8, H / 2 + 10 - i * 12, 6 - i, 2 - i * 0.5, Color(0.5, 0.72, 0.95, 0.6))
	var wall := Color(0.6, 0.58, 0.54)
	var wall_d := Color(0.5, 0.48, 0.45)
	for i in range(0, W, 2):
		var wv = sin(i * 0.08) * 2
		_draw_ellipse(img, i, 143 + wv, 2.2, 14, wall)
		if i % 8 == 0:
			_draw_ellipse(img, i + 1, 143 + wv, 1.8, 14, wall_d)
		_draw_ellipse(img, i, 881 + wv, 2.2, 14, wall)
		if i % 8 == 0:
			_draw_ellipse(img, i + 1, 881 + wv, 1.8, 14, wall_d)
	for j in range(143, 895, 2):
		var wv = cos(j * 0.08) * 2
		_draw_ellipse(img, 143 + wv, j, 14, 2.2, wall)
		if j % 8 == 0:
			_draw_ellipse(img, 143 + wv, j + 1, 14, 1.8, wall_d)
		_draw_ellipse(img, 881 + wv, j, 14, 2.2, wall)
		if j % 8 == 0:
			_draw_ellipse(img, 881 + wv, j + 1, 14, 1.8, wall_d)
	for i in range(150, 860, 42):
		_draw_circle(img, i, 124, 8, wall)
		_draw_circle(img, i, 900, 8, wall)
	for j in range(150, 860, 42):
		_draw_circle(img, 124, j, 8, wall)
		_draw_circle(img, 900, j, 8, wall)
	for pos in [[143, 143], [881, 143], [143, 881], [881, 881]]:
		_draw_circle(img, pos[0], pos[1], 22, Color(0.66, 0.64, 0.6))
		_draw_circle(img, pos[0], pos[1], 14, Color(0.72, 0.7, 0.66))
		_draw_circle(img, pos[0], pos[1], 5, Color(0.35, 0.33, 0.3))
	for y in range(881, 1024):
		for x in range(W / 2 - 46, W / 2 + 46):
			img.set_pixel(x, y, dirt)
	_draw_rect(img, W / 2 - 52, 860, 14, 70, Color(0.45, 0.3, 0.18))
	_draw_rect(img, W / 2 + 38, 860, 14, 70, Color(0.45, 0.3, 0.18))
	_draw_circle(img, W / 2 - 45, 855, 10, Color(0.5, 0.34, 0.2))
	_draw_circle(img, W / 2 + 45, 855, 10, Color(0.5, 0.34, 0.2))
	_draw_building(img, 210, 220, 160, 115, Color(0.3, 0.45, 0.8))
	_draw_building(img, 640, 220, 160, 115, Color(0.6, 0.35, 0.75))
	_draw_building(img, 210, 640, 160, 115, Color(0.88, 0.72, 0.3))
	_draw_ellipse(img, 745, 715, 100, 85, Color(0.28, 0.5, 0.8))
	_draw_ellipse(img, 745, 715, 92, 77, Color(0.33, 0.56, 0.85))
	_draw_ellipse(img, 760, 700, 40, 30, Color(0.4, 0.62, 0.9, 0.5))
	for pos in [[700, 750], [780, 680], [730, 660]]:
		_draw_circle(img, pos[0], pos[1], 7, Color(0.35, 0.65, 0.35))
		_draw_circle(img, pos[0], pos[1], 3, Color(0.45, 0.75, 0.45))
	for i in range(5):
		_draw_rect(img, 610 + i * 22, 695, 16, 26, Color(0.52, 0.38, 0.22))
		_draw_rect(img, 610 + i * 22, 695, 16, 5, Color(0.62, 0.46, 0.28))
	for pos in [[360, 320], [560, 320], [360, 560], [170, 430], [850, 430], [500, 770], [920, 580], [100, 580]]:
		_draw_tree(img, pos[0], pos[1])
	for i in range(40):
		var fx = 20 + randi() % (W - 40)
		var fy = 20 + randi() % (H - 40)
		if img.get_pixel(fx, fy).g > 0.5:
			var fc = [Color(0.9, 0.8, 0.3), Color(0.9, 0.5, 0.6), Color(0.8, 0.8, 0.95)][randi() % 3]
			_draw_circle(img, fx, fy, 1.5, fc)
	# ===== BUEIRO COM ESCADA (entrada da caverna) =====
	var bx := W / 2
	var by := 800
	_draw_circle(img, bx, by, 30, Color(0.32, 0.32, 0.35))
	_draw_circle(img, bx, by, 25, Color(0.06, 0.06, 0.08))
	_draw_rect(img, bx - 18, by - 2, 36, 5, Color(0.42, 0.4, 0.38))
	_draw_rect(img, bx - 14, by + 4, 28, 5, Color(0.34, 0.32, 0.3))
	_draw_rect(img, bx - 10, by + 10, 20, 5, Color(0.26, 0.24, 0.22))
	_draw_rect(img, bx - 34, by - 8, 3, 20, Color(0.45, 0.45, 0.5))
	_draw_rect(img, bx + 31, by - 8, 3, 20, Color(0.45, 0.45, 0.5))
	_draw_circle_ring(img, bx, by, 30, Color(0.5, 0.48, 0.45))
	return ImageTexture.create_from_image(img)

static func _draw_building(img: Image, x: int, y: int, w: int, h: int, roof: Color) -> void:
	var roof_d := roof.darkened(0.25)
	_draw_ellipse(img, x + w / 2, y + h * 0.72, w / 2 - 4, h * 0.36, Color(0.84, 0.76, 0.62))
	_draw_ellipse(img, x + w / 2 - 20, y + h * 0.78, w / 3, h * 0.28, Color(0.78, 0.7, 0.56))
	_draw_rect(img, x + 8, y + h * 0.5, 6, h * 0.5, Color(0.5, 0.36, 0.22))
	_draw_rect(img, x + w - 14, y + h * 0.5, 6, h * 0.5, Color(0.5, 0.36, 0.22))
	for i in range(int(h * 0.52)):
		var t = float(i) / (h * 0.52)
		var rw = w / 2 * (1 - t * 0.85) + 8
		_draw_ellipse(img, x + w / 2, y + h * 0.52 - i, rw, 4, roof if i % 6 != 0 else roof_d)
	_draw_ellipse(img, x + w / 2, y + h * 0.54, w / 2 - 2, 6, roof.darkened(0.35))
	_draw_ellipse(img, x + w / 2, y + h - 16, 11, 17, Color(0.45, 0.3, 0.18))
	_draw_circle(img, x + w / 2 + 5, y + h - 16, 1.5, Color(0.8, 0.65, 0.3))
	_draw_rect(img, x + w / 2 - 20, y + h * 0.6, 1.5, 10, Color(0.4, 0.3, 0.2))
	_draw_circle(img, x + w / 2 - 20, y + h * 0.6 + 14, 7, roof)
	_draw_circle(img, x + w / 2 - 20, y + h * 0.6 + 14, 4, Color(1, 1, 1, 0.85))

static func _draw_tree(img: Image, x: int, y: int) -> void:
	_draw_ellipse(img, x, y + 2, 4.5, 10, Color(0.48, 0.34, 0.2))
	_draw_ellipse(img, x - 1, y + 2, 2, 8, Color(0.4, 0.28, 0.16))
	_draw_ellipse(img, x - 5, y + 10, 3, 2, Color(0.44, 0.31, 0.18))
	_draw_ellipse(img, x + 5, y + 10, 3, 2, Color(0.44, 0.31, 0.18))
	_draw_circle(img, x, y - 14, 17, Color(0.24, 0.48, 0.2))
	_draw_circle(img, x - 9, y - 8, 11, Color(0.24, 0.48, 0.2))
	_draw_circle(img, x + 9, y - 8, 11, Color(0.24, 0.48, 0.2))
	_draw_circle(img, x - 4, y - 18, 10, Color(0.3, 0.55, 0.26))
	_draw_circle(img, x + 6, y - 16, 9, Color(0.3, 0.55, 0.26))
	_draw_circle(img, x, y - 22, 8, Color(0.35, 0.6, 0.3))
	_draw_circle(img, x - 6, y - 12, 1.5, Color(0.8, 0.4, 0.4))
	_draw_circle(img, x + 7, y - 18, 1.5, Color(0.8, 0.4, 0.4))

# ---------- CAVERNA (pedra escura, ESCADA de saida, caixas, cristais) ----------
static func _map_cave() -> Texture2D:
	var W := 1024
	var H := 1024
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.14, 0.11, 0.09))
	for y in range(70, H - 70):
		for x in range(70, W - 70):
			var n = sin(x * 0.05) * cos(y * 0.05) * 0.03 + randf() * 0.04
			img.set_pixel(x, y, Color(0.4 + n, 0.35 + n, 0.3 + n))
	for i in range(60):
		var mx = 90 + randi() % (W - 180)
		var my = 90 + randi() % (H - 180)
		_draw_ellipse(img, mx, my, 4 + randf() * 8, 3 + randf() * 6, Color(0.3, 0.42, 0.25, 0.4))
	for i in range(120):
		var rx = randi() % W
		var ry = randi() % H
		var edge = min(min(rx, W - rx), min(ry, H - ry))
		if edge < 90:
			_draw_circle(img, rx, ry, 4 + randf() * 10, Color(0.2, 0.17, 0.14))
	# ===== SAIDA COM ESCADA DE MADEIRA (sobe pra cidade) =====
	var sx := W / 2
	var sy := 95
	_draw_circle(img, sx, sy, 30, Color(0.32, 0.32, 0.35))
	_draw_circle(img, sx, sy, 24, Color(0.55, 0.75, 0.95))
	_draw_rect(img, sx - 12, sy - 14, 3, 30, Color(0.52, 0.38, 0.22))
	_draw_rect(img, sx + 9, sy - 14, 3, 30, Color(0.52, 0.38, 0.22))
	for i in range(5):
		_draw_rect(img, sx - 12, sy - 12 + i * 6, 24, 3, Color(0.62, 0.46, 0.28))
	for pos in [[200, 300], [248, 325], [800, 500], [300, 700], [700, 250]]:
		_draw_rect(img, pos[0] - 19, pos[1] - 19, 38, 38, Color(0.52, 0.38, 0.22))
		_draw_rect(img, pos[0] - 19, pos[1] - 19, 38, 7, Color(0.62, 0.46, 0.28))
		_draw_rect(img, pos[0] - 19, pos[1] - 12, 38, 3, Color(0.42, 0.3, 0.18))
		_draw_ellipse(img, pos[0], pos[1] + 22, 20, 4, Color(0, 0, 0, 0.25))
	for pos in [[830, 620], [180, 550]]:
		_draw_ellipse(img, pos[0], pos[1], 14, 17, Color(0.55, 0.4, 0.24))
		_draw_ellipse(img, pos[0], pos[1], 14, 5, Color(0.68, 0.52, 0.32))
		_draw_rect(img, pos[0] - 14, pos[1] - 4, 28, 3, Color(0.35, 0.28, 0.2))
	for pos in [[110, 210], [905, 300], [150, 800], [880, 760], [500, 950]]:
		_draw_circle(img, pos[0], pos[1], 6, Color(0.45, 0.7, 0.88))
		_draw_circle(img, pos[0] - 1, pos[1] - 2, 3, Color(0.7, 0.88, 0.98))
		_draw_circle(img, pos[0], pos[1] + 10, 8, Color(0.45, 0.7, 0.88, 0.15))
	for i in range(30):
		var px = 100 + randi() % (W - 200)
		var py = 100 + randi() % (H - 200)
		_draw_ellipse(img, px, py, 2 + randf() * 4, 1.5 + randf() * 3, Color(0.33, 0.29, 0.25))
	return ImageTexture.create_from_image(img)

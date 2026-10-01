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

static func load_sheet_up_real(path: String, hair: String = "castanho", tunic: String = "castanho") -> Array[Texture2D]:
	# UP = ARTE REAL editada (rosto vira cabelo) — identidade visual 100% mantida
	var img := _load_image(path)
	if img == null:
		return _procedural(path.replace("/down/", "/up/"), "sword", hair, tunic)
	if tunic != "castanho" or hair != "castanho":
		img = _recolor_real(img, hair, tunic)
	img = _make_up_from_real(img)
	var out: Array[Texture2D] = []
	var fw = img.get_width() / 4
	for i in range(4):
		var fr = img.get_region(Rect2i(i * fw, 0, fw, img.get_height()))
		out.append(ImageTexture.create_from_image(fr))
	return out

static func load_sheet_procedural_custom(path: String, weapon: String, hair: String, tunic: String, pants: String = "marrom") -> Array[Texture2D]:
	# pula o PNG do disco e vai DIRETO pro procedural com 4 DIRECOES reais
	# (o PNG so existe pra "down" — usar ele fazia o player andar so pra baixo)
	CURRENT_PANTS = pants
	return _procedural(path, weapon, hair, tunic)

static func load_sheet_custom(path: String, weapon: String, hair: String, tunic: String, pants: String = "marrom") -> Array[Texture2D]:
	var img := _load_image(path)
	if img != null:
		# recolore o PNG real se a cor escolhida nao e a base (tunica/cabelo)
		if tunic != "castanho" or hair != "castanho":
			img = _recolor_real(img, hair, tunic)
		var out: Array[Texture2D] = []
		var fw = img.get_width() / 4
		for i in range(4):
			var fr = img.get_region(Rect2i(i * fw, 0, fw, img.get_height()))
			out.append(ImageTexture.create_from_image(fr))
		return out
	CURRENT_PANTS = pants
	return _procedural(path, weapon, hair, tunic)

# recolore a arte REAL do knight: troca os pixels da tunica/cabelo pela cor escolhida
static func _recolor_real(img: Image, hair: String, tunic: String) -> Image:
	var base_tunic := [Color(0.6, 0.36, 0.2), Color(0.47, 0.26, 0.14), Color(0.53, 0.31, 0.18)]
	var base_hair := Color(0.29, 0.17, 0.14)
	var new_tunic := Color(0.6, 0.36, 0.2)
	if Equips.CLOTHES_COLORS.has(tunic):
		new_tunic = Equips.CLOTHES_COLORS[tunic]
	var new_hair := base_hair
	if hair != "castanho" and Equips.CLOTHES_COLORS.has(hair):
		new_hair = Equips.CLOTHES_COLORS[hair]
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c = img.get_pixel(x, y)
			if c.a < 0.1:
				continue
			# tunica: tons de marrom medio/escuro na faixa do tronco
			for bt in base_tunic:
				if absf(c.r - bt.r) < 0.09 and absf(c.g - bt.g) < 0.09 and absf(c.b - bt.b) < 0.09:
					var shade: float = c.r / maxf(bt.r, 0.01)
					img.set_pixel(x, y, Color(new_tunic.r * shade, new_tunic.g * shade, new_tunic.b * shade, c.a))
					break
			# cabelo: tons castanho escuro no topo
			if absf(c.r - base_hair.r) < 0.07 and absf(c.g - base_hair.g) < 0.07 and absf(c.b - base_hair.b) < 0.07:
				var shade2: float = c.r / maxf(base_hair.r, 0.01)
				img.set_pixel(x, y, Color(new_hair.r * shade2, new_hair.g * shade2, new_hair.b * shade2, c.a))
	return img

# UP a partir da ARTE REAL: cobre o ROSTO INTEIRO com cabelo — costas de verdade,
# mantendo 100% a identidade visual do knight aprovado
static func _make_up_from_real(img: Image) -> Image:
	var hair := Color(0.29, 0.17, 0.14)
	var out := img.duplicate()
	out.convert(Image.FORMAT_RGBA8)
	for y in range(out.get_height()):
		for x in range(out.get_width()):
			var c = out.get_pixel(x, y)
			if c.a < 0.1:
				continue
			# REGIAO DO ROSTO (y 24-50, x 38-72): tudo vira cabelo — pele clara,
			# pele sombreada, olhos e contorno. Costas = cabeca coberta de cabelo.
			var in_face: bool = y >= 24 and y <= 50 and x >= 38 and x <= 72
			if in_face and c.a > 0.1:
				# rosto vira cabelo (costas): tom principal, com sombra nas bordas
				var shade := 1.0 if (x + y) % 5 != 0 else 0.8
				out.set_pixel(x, y, Color(hair.r * shade, hair.g * shade, hair.b * shade, c.a))
	return out

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

# ---------- KNIGHT 4 DIRECOES (com calca colorida) ----------
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
	# CORES DA ARTE REAL (extraidas do knight_idle_down_base.png — identidade visual)
	var hair := Color(0.29, 0.17, 0.14)  # castanho escuro do cabelo real
	if hair_color != "castanho" and Equips.CLOTHES_COLORS.has(hair_color):
		hair = Equips.CLOTHES_COLORS[hair_color]
	var skin := Color(0.98, 0.73, 0.53)  # pele da arte real
	var skin_sh := Color(0.85, 0.6, 0.42)
	var tunic := Color(0.6, 0.36, 0.2)   # tunica marrom da arte real
	var tunic_d := Color(0.47, 0.26, 0.14)
	if tunic_color != "castanho" and Equips.CLOTHES_COLORS.has(tunic_color):
		tunic = Equips.CLOTHES_COLORS[tunic_color]
		tunic_d = tunic.darkened(0.2)
	var pants := Color(0.28, 0.23, 0.19)
	if Equips.PANTS_COLORS.has(CURRENT_PANTS):
		pants = Equips.PANTS_COLORS[CURRENT_PANTS]
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

static func _tri(img: Image, cx: float, cy: float, w: float, h: float, c: Color) -> void:
	for y in range(int(h)):
		var t = float(y) / maxf(h, 1.0)
		var rw = w * (1.0 - t) / 2.0
		for x in range(int(-rw), int(rw) + 1):
			var px = int(cx) + x
			var py = int(cy) + y - int(h / 2.0)
			if px >= 0 and px < img.get_width() and py >= 0 and py < img.get_height():
				img.set_pixel(px, py, c)

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
	for j in range(int(h)):
		for i in range(int(w)):
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
	if "city2" in path:
		return _map_city2()
	if "forest" in path:
		return _map_forest()
	return _map_city()

# ---------- CIDADE 1 (muralha, fonte, lojas, lago, portao sul, bueiro) ----------
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
	# bueiro com escada (saida sul pro bueiro/caverna)
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
	# placa de madeira "BUEIRO" acima da entrada (bem visivel)
	_draw_rect(img, bx - 40, by - 60, 80, 22, Color(0.45, 0.3, 0.18))
	_draw_rect(img, bx - 40, by - 60, 80, 4, Color(0.55, 0.4, 0.24))
	_draw_rect(img, bx - 2, by - 38, 4, 24, Color(0.4, 0.28, 0.16))
	for i in range(7):
		_draw_rect(img, bx - 32 + i * 10, by - 52, 6, 10, Color(0.85, 0.8, 0.7))
	# portao LESTE (saida pra floresta)
	for y in range(H / 2 - 46, H / 2 + 46):
		for x in range(W - 130, W):
			img.set_pixel(x, y, dirt)
	_draw_rect(img, W - 90, H / 2 - 52, 70, 14, Color(0.45, 0.3, 0.18))
	_draw_rect(img, W - 90, H / 2 + 38, 70, 14, Color(0.45, 0.3, 0.18))
	return ImageTexture.create_from_image(img)

# ---------- CIDADE 2 (portao LESTE da city1 — vila de pedra, estilo anao) ----------
static func _map_city2() -> Texture2D:
	var W := 1024
	var H := 1024
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.5, 0.52, 0.38))
	for i in range(8000):
		var x = randi() % W
		var y = randi() % H
		var shade = 0.42 + randf() * 0.12
		img.set_pixel(x, y, Color(shade + 0.05, shade + 0.08, shade * 0.6))
	# estradas de pedra (cruz central + anel)
	var stone := Color(0.55, 0.53, 0.5)
	var stone_d := Color(0.48, 0.46, 0.44)
	for y in range(160, 940):
		for x in range(W / 2 - 30, W / 2 + 30):
			var c = stone if (x + y) % 9 != 0 else stone_d
			img.set_pixel(x, y, c)
	for x in range(160, 940):
		for y in range(H / 2 - 30, H / 2 + 30):
			var c = stone if (x + y) % 9 != 0 else stone_d
			img.set_pixel(x, y, c)
	# praca central com estatua
	_draw_circle(img, W / 2, H / 2, 90, Color(0.6, 0.58, 0.55))
	_draw_circle(img, W / 2, H / 2 - 10, 16, Color(0.7, 0.68, 0.64))
	_draw_rect(img, W / 2 - 6, H / 2 - 10, 12, 40, Color(0.65, 0.63, 0.6))
	_draw_circle(img, W / 2, H / 2 + 34, 22, Color(0.62, 0.6, 0.57))
	# muralha de pedra com portao OESTE (volta pra city1) e SUL (floresta)
	var wall := Color(0.52, 0.5, 0.47)
	var wall_d := Color(0.42, 0.4, 0.38)
	for i in range(0, W, 3):
		_draw_rect(img, i, 140, 3, 16, wall if i % 12 != 0 else wall_d)
		_draw_rect(img, i, 890, 3, 16, wall if i % 12 != 0 else wall_d)
	for j in range(140, 906, 3):
		_draw_rect(img, 140, j, 16, 3, wall if j % 12 != 0 else wall_d)
		_draw_rect(img, 890, j, 16, 3, wall if j % 12 != 0 else wall_d)
	for pos in [[140, 140], [890, 140], [140, 890], [890, 890]]:
		_draw_circle(img, pos[0], pos[1], 20, Color(0.58, 0.56, 0.53))
	# portao oeste
	for y in range(H / 2 - 46, H / 2 + 46):
		for x in range(0, 130):
			img.set_pixel(x, y, stone)
	# casas de pedra (estilo anao, telhados de cobre)
	_draw_building(img, 220, 230, 150, 110, Color(0.72, 0.45, 0.2))
	_draw_building(img, 630, 230, 150, 110, Color(0.72, 0.45, 0.2))
	_draw_building(img, 220, 640, 150, 110, Color(0.6, 0.5, 0.25))
	_draw_building(img, 630, 640, 150, 110, Color(0.72, 0.45, 0.2))
	# forja acesa (canto sudeste)
	_draw_circle(img, 780, 780, 26, Color(0.35, 0.33, 0.3))
	_draw_circle(img, 780, 780, 18, Color(0.95, 0.45, 0.1))
	_draw_circle(img, 780, 780, 10, Color(1.0, 0.75, 0.25))
	for i in range(6):
		var fx = 770 + randi() % 20
		var fy = 750 + randi() % 20
		_draw_circle(img, fx, fy, 2, Color(1.0, 0.85, 0.4, 0.7))
	# arvores esparsas
	for pos in [[90, 300], [930, 320], [90, 700], [500, 100], [500, 950]]:
		_draw_tree(img, pos[0], pos[1])
	# portao sul (saida pra floresta)
	var dirt := Color(0.6, 0.52, 0.4)
	for y in range(890, H):
		for x in range(W / 2 - 46, W / 2 + 46):
			img.set_pixel(x, y, dirt)
	return ImageTexture.create_from_image(img)

# ---------- FLORESTA (sul da city2 — lobos, aranhas, goblins) ----------
static func _map_forest() -> Texture2D:
	var W := 1024
	var H := 1024
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.22, 0.42, 0.2))
	for i in range(12000):
		var x = randi() % W
		var y = randi() % H
		var shade = 0.18 + randf() * 0.14
		img.set_pixel(x, y, Color(shade * 0.8, shade + 0.2, shade * 0.7))
	# clareira central (spawn)
	_draw_ellipse(img, W / 2, H / 2, 130, 100, Color(0.4, 0.58, 0.28))
	_draw_ellipse(img, W / 2, H / 2, 110, 82, Color(0.45, 0.62, 0.3))
	# trilha norte (entrada da city2)
	var dirt := Color(0.6, 0.52, 0.38)
	for y in range(0, H / 2):
		var wobble = sin(y * 0.06) * 10
		for x in range(W / 2 - 22 + wobble, W / 2 + 22 + wobble):
			var c = dirt if (x + y) % 7 != 0 else dirt.darkened(0.1)
			img.set_pixel(x, y, c)
	# lago pequeno
	_draw_ellipse(img, 250, 700, 80, 60, Color(0.25, 0.45, 0.7))
	_draw_ellipse(img, 250, 700, 70, 52, Color(0.3, 0.52, 0.78))
	# FLORESTA DENSA: muitas arvores em anel, deixando corredores
	var tree_positions := []
	for i in range(46):
		var ang = randf() * TAU
		var r = 180 + randf() * 300
		var tx = W / 2 + cos(ang) * r
		var ty = H / 2 + sin(ang) * r * 0.9
		if tx > 60 and tx < W - 60 and ty > 80 and ty < H - 60:
			tree_positions.append([int(tx), int(ty)])
	for pos in tree_positions:
		_draw_tree(img, pos[0], pos[1])
	# cogumelos e flores
	for i in range(30):
		var fx = 100 + randi() % (W - 200)
		var fy = 100 + randi() % (H - 200)
		var fc = [Color(0.9, 0.3, 0.3), Color(0.9, 0.8, 0.3), Color(0.8, 0.6, 0.95)][randi() % 3]
		_draw_circle(img, fx, fy, 2.5, fc)
		_draw_circle(img, fx, fy + 3, 1.5, Color(0.95, 0.92, 0.85))
	# pedras
	for pos in [[150, 250], [850, 300], [800, 800], [400, 900]]:
		_draw_circle(img, pos[0], pos[1], 14, Color(0.5, 0.48, 0.45))
		_draw_circle(img, pos[0] - 3, pos[1] - 4, 8, Color(0.6, 0.58, 0.55))
	# entrada norte (trilha continua)
	for y in range(0, 40):
		for x in range(W / 2 - 30, W / 2 + 30):
			img.set_pixel(x, y, dirt)
	return ImageTexture.create_from_image(img)

# ---------- CAVERNA (pedra escura, escada de saida, caixas, cristais) ----------
static func _map_cave() -> Texture2D:
	# CAVERNA DOS RATOS — escura, umida, com tochas, cristais e teias (estilo Tibia)
	var W := 1024
	var H := 1024
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	# fundo: rocha escura com veios
	img.fill(Color(0.09, 0.08, 0.1))
	for y in range(60, H - 60):
		for x in range(60, W - 60):
			var n = sin(x * 0.045) * cos(y * 0.038) * 0.05 + randf() * 0.05
			var v = 0.30 + n
			img.set_pixel(x, y, Color(v * 0.95, v * 0.88, v * 0.8))
	# veios de rocha (linhas sinuosas escuras)
	for k in range(14):
		var vx = randi() % W
		var vy = randi() % H
		var ang = randf() * TAU
		for step in range(60 + randi() % 80):
			vx += cos(ang) * 3.0
			vy += sin(ang) * 3.0
			ang += (randf() - 0.5) * 0.4
			if vx < 70 or vx > W - 70 or vy < 70 or vy > H - 70:
				break
			_draw_circle(img, int(vx), int(vy), 2 + randf() * 2, Color(0.16, 0.14, 0.13, 0.7))
	# borda de rocha irregular (paredao da caverna)
	for i in range(260):
		var edge = randi() % 4
		var t = randi() % W
		var px = 0
		var py = 0
		if edge == 0:
			px = t; py = 20 + randi() % 55
		elif edge == 1:
			px = t; py = H - 20 - randi() % 55
		elif edge == 2:
			px = 20 + randi() % 55; py = t
		else:
			px = W - 20 - randi() % 55; py = t
		_draw_circle(img, px, py, 6 + randf() * 14, Color(0.13, 0.11, 0.12))
	# pocas d'agua (reflexo azul escuro com brilho)
	for pos in [[280, 640], [760, 380], [520, 820]]:
		_draw_ellipse(img, pos[0], pos[1], 46 + randf() * 20, 26 + randf() * 10, Color(0.1, 0.16, 0.24))
		_draw_ellipse(img, pos[0], pos[1], 40, 22, Color(0.13, 0.22, 0.32))
		_draw_ellipse(img, pos[0] - 8, pos[1] - 4, 14, 5, Color(0.3, 0.45, 0.6, 0.6))
		_draw_ellipse(img, pos[0] + 14, pos[1] + 6, 8, 3, Color(0.3, 0.45, 0.6, 0.4))
	# cristais brilhantes (azuis e roxos, com glow)
	for pos in [[180, 240], [840, 700], [640, 180], [350, 880], [900, 250]]:
		var cc = Color(0.35, 0.6, 0.95) if randf() > 0.5 else Color(0.7, 0.4, 0.9)
		_draw_circle(img, pos[0], pos[1], 14, Color(cc.r, cc.g, cc.b, 0.12))
		_draw_circle(img, pos[0], pos[1], 9, Color(cc.r, cc.g, cc.b, 0.25))
		_tri(img, pos[0] - 6, pos[1] + 5, 12, 14, cc)
		_tri(img, pos[0] + 2, pos[1] + 3, 8, 9, cc.lightened(0.3))
		_tri(img, pos[0] - 2, pos[1] - 4, 5, 7, Color(1, 1, 1, 0.5))
	# tochas na parede (luz quente — 4 cantos + centro)
	for pos in [[120, 120], [904, 120], [120, 904], [904, 904], [512, 90]]:
		_draw_circle(img, pos[0], pos[1], 40, Color(1.0, 0.6, 0.25, 0.1))
		_draw_circle(img, pos[0], pos[1], 26, Color(1.0, 0.65, 0.3, 0.16))
		_draw_rect(img, pos[0] - 3, pos[1] - 6, 6, 16, Color(0.4, 0.28, 0.16))
		_draw_circle(img, pos[0], pos[1] - 10, 7, Color(1.0, 0.75, 0.3))
		_draw_circle(img, pos[0], pos[1] - 12, 4, Color(1.0, 0.95, 0.6))
	# teias de aranha nos cantos
	for pos in [[90, 90], [934, 90], [90, 934], [934, 934]]:
		for r in range(4):
			_draw_circle(img, pos[0], pos[1], 8 + r * 7, Color(1, 1, 1, 0.12))
		for a in range(6):
			var ang = a * TAU / 6.0
			for r in range(30):
				img.set_pixel(int(pos[0] + cos(ang) * r), int(pos[1] + sin(ang) * r), Color(1, 1, 1, 0.14))
	# pedras grandes espalhadas
	for pos in [[400, 300], [700, 550], [250, 450], [850, 850], [600, 700]]:
		_draw_ellipse(img, pos[0], pos[1], 18 + randf() * 8, 12 + randf() * 6, Color(0.24, 0.22, 0.24))
		_draw_ellipse(img, pos[0] - 4, pos[1] - 4, 10, 6, Color(0.34, 0.32, 0.34))
	# ossos no chao (clima de masmorra)
	for pos in [[320, 520], [780, 620], [500, 260], [680, 900]]:
		_draw_rect(img, pos[0] - 10, pos[1], 20, 3, Color(0.75, 0.72, 0.62))
		_draw_circle(img, pos[0] - 12, pos[1] + 1, 3, Color(0.78, 0.75, 0.65))
		_draw_circle(img, pos[0] + 12, pos[1] - 1, 3, Color(0.78, 0.75, 0.65))
	# entrada: bueiro de grade no topo (casando com o portao norte)
	var sx := W / 2
	_draw_circle(img, sx, 95, 34, Color(0.2, 0.18, 0.2))
	_draw_circle(img, sx, 95, 28, Color(0.5, 0.55, 0.6))
	for i in range(5):
		_draw_rect(img, sx - 26, 75 + i * 10, 52, 4, Color(0.3, 0.28, 0.3))
	_draw_rect(img, sx - 3, 68, 6, 56, Color(0.3, 0.28, 0.3))
	return ImageTexture.create_from_image(img)

static func _draw_building(img: Image, x: int, y: int, w: int, h: int, roof: Color) -> void:
	# CASA RETANGULAR estilo Tibia: parede de pedra/tinta, telhado de duas aguas, porta, janela
	var wall := Color(0.82, 0.74, 0.6)
	var wall_d := Color(0.7, 0.62, 0.48)
	var roof_d := roof.darkened(0.3)
	var roof_l := roof.lightened(0.15)
	var hy := y + int(h * 0.45)  # topo da parede
	# sombra no chao
	_draw_ellipse(img, x + w / 2, y + h - 6, w / 2 + 6, 8, Color(0, 0, 0, 0.22))
	# parede
	_draw_rect(img, x + 6, hy, w - 12, h - int(h * 0.45) - 4, wall)
	_draw_rect(img, x + 6, hy, w - 12, 4, wall_d)
	# textura de pedra na parede
	for yy in range(hy + 8, y + h - 6, 10):
		for xx in range(x + 8, x + w - 10, 16):
			_draw_rect(img, xx, yy, 14, 7, wall_d if (xx / 16 + yy / 10) % 2 == 0 else wall)
	# telhado de duas aguas (triangulo largo com beiral)
	var peak := y + 6
	for i in range(hy - peak + 6):
		var t = float(i) / maxf(hy - peak + 6, 1)
		var rw = int(w / 2 * (1.0 - t) + 10)
		var c = roof if i % 7 != 0 else roof_d
		_draw_rect(img, x + w / 2 - rw, peak + i, rw * 2, 1, c)
	# linha do beiral
	_draw_rect(img, x + 2, hy - 2, w - 4, 4, roof_d)
	# cumeeira
	_draw_rect(img, x + w / 2 - 3, peak - 2, 6, 4, roof_l)
	# porta (arco de madeira)
	var dx := x + w / 2 - 9
	_draw_rect(img, dx, y + h - 26, 18, 24, Color(0.45, 0.3, 0.16))
	_draw_circle(img, x + w / 2, y + h - 26, 9, Color(0.45, 0.3, 0.16))
	_draw_circle(img, x + w / 2 + 5, y + h - 14, 1.5, Color(0.85, 0.7, 0.3))
	# janelas com moldura
	for wx in [x + 16, x + w - 26]:
		if abs(wx + 5 - (x + w / 2)) > 16:
			_draw_rect(img, wx, hy + 10, 10, 10, Color(0.35, 0.5, 0.65))
			_draw_rect(img, wx - 2, hy + 8, 14, 3, Color(0.5, 0.36, 0.22))
			_draw_rect(img, wx - 2, hy + 8, 3, 14, Color(0.5, 0.36, 0.22))
			_draw_rect(img, wx + 9, hy + 8, 3, 14, Color(0.5, 0.36, 0.22))
			_draw_rect(img, wx, hy + 14, 10, 2, Color(0.5, 0.36, 0.22))

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

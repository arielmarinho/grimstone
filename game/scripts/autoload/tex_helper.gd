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

# recolore a arte REAL do knight: troca os pixels da túnica/cabelo pela cor escolhida
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
			# túnica: tons de marrom médio/escuro na faixa do tronco
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

# UP a partir da ARTE REAL: substitui o rosto (pele) por cabelo — costas de verdade,
# mantendo 100% a identidade visual do knight aprovado
static func _make_up_from_real(img: Image) -> Image:
	var hair := Color(0.29, 0.17, 0.14)
	var hair_d := Color(0.22, 0.13, 0.11)
	var out := img.duplicate()
	out.convert(Image.FORMAT_RGBA8)
	for y in range(out.get_height()):
		for x in range(out.get_width()):
			var c = out.get_pixel(x, y)
			if c.a < 0.1:
				continue
			# pele da arte real (rosto): (0.98, 0.73, 0.53) e sombra (0.85, 0.6, 0.42)
			# pele: qualquer tom claro/avermelhado na regiao da cabeca (y<56)
			var is_skin: bool = c.r > 0.6 and c.g > 0.4 and c.b < c.r * 0.75 and c.g < c.r * 0.85
			if is_skin and y < 56:
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
	var tunic := Color(0.6, 0.36, 0.2)   # túnica marrom da arte real
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
			if px >= 0 and px >= 0 and px < img.get_width() and py < img.get_height():
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

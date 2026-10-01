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
	# b64 pode ter whitespace interno (push MCP insere espacos) — remover TUDO
	var b64 = f.get_as_text().replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "").strip_edges()
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
		# COSTAS (arte real refeita): cabelo espinhado cobrindo a cabeca, sem rosto,
		# cinto com fivela, cabo da espada aparecendo atras do ombro direito
		_draw_ellipse(img, cx - 5, 70 + leg_l, 4, 8, Color(0.278, 0.231, 0.192))
		_draw_ellipse(img, cx + 5, 70 + leg_r, 4, 8, Color(0.278, 0.231, 0.192))
		_draw_ellipse(img, cx - 5, 80 + leg_l, 4, 3, Color(0.357, 0.216, 0.122))
		_draw_ellipse(img, cx + 5, 80 + leg_r, 4, 3, Color(0.357, 0.216, 0.122))
		# cabo da espada atras do ombro direito
		_draw_rect(img, cx + 10, 40 + bob, 3, 14, Color(0.420, 0.220, 0.114))
		_draw_rect(img, cx + 8, 38 + bob, 7, 3, Color(0.800, 0.651, 0.302))
		# tronco de tras (tunica com cinto)
		_draw_ellipse(img, cx, 52 + bob, 12, 14, Color(0.600, 0.357, 0.196))
		_draw_ellipse(img, cx - 4, 56 + bob, 7, 9, Color(0.475, 0.275, 0.153))
		_draw_rect(img, cx - 10, 62 + bob, 20, 3, Color(0.231, 0.149, 0.078))
		_draw_rect(img, cx - 2, 62 + bob, 4, 3, Color(0.800, 0.651, 0.302))
		# ombros e bracos
		_draw_ellipse(img, cx - 11, 50 + bob, 3, 7, Color(0.600, 0.357, 0.196))
		_draw_ellipse(img, cx + 11, 50 + bob, 3, 7, Color(0.600, 0.357, 0.196))
		_draw_ellipse(img, cx - 12, 56 + bob, 3, 7, Color(0.475, 0.275, 0.153))
		_draw_ellipse(img, cx + 12, 56 + bob, 3, 7, Color(0.475, 0.275, 0.153))
		_draw_circle(img, cx - 12, 63 + bob, 2.5, Color(0.984, 0.725, 0.529))
		_draw_circle(img, cx + 12, 63 + bob, 2.5, Color(0.984, 0.725, 0.529))
		# CABECA: cabelo inteiro (costas), tufos espinhados no topo
		_draw_circle(img, cx, 32 + bob, 8.5, Color(0.984, 0.725, 0.529))
		_draw_ellipse(img, cx, 27 + bob, 9, 8, Color(0.529, 0.282, 0.145))
		_draw_ellipse(img, cx - 7, 31 + bob, 3, 5, Color(0.529, 0.282, 0.145))
		_draw_ellipse(img, cx + 7, 31 + bob, 3, 5, Color(0.529, 0.282, 0.145))
		for i in range(5):
			var dx: int = -6 + i * 3
			_draw_ellipse(img, cx + dx, 18 + bob + abs(dx) / 2, 2, 3, Color(0.529, 0.282, 0.145) if i % 2 == 0 else Color(0.420, 0.220, 0.114))
		# nuca
		_draw_ellipse(img, cx, 34 + bob, 8, 3, Color(0.420, 0.220, 0.114))
	elif dir == "side":
		# PERFIL (arte real refeita): rosto de lado com orelha/olho/sobrancelha,
		# tronco estreito, espada na frente apontando pra direita
		var step := 0
		if is_walk:
			step = [4, 0, -4, 0][f]
		_draw_ellipse(img, cx - 3 + step, 72, 3.5, 8, Color(0.278, 0.231, 0.192))
		_draw_ellipse(img, cx + 3 - step, 72, 3.5, 8, Color(0.278, 0.231, 0.192))
		_draw_ellipse(img, cx - 3 + step, 81, 4, 3, Color(0.357, 0.216, 0.122))
		_draw_ellipse(img, cx + 3 - step, 81, 4, 3, Color(0.357, 0.216, 0.122))
		# tronco de perfil (estreito)
		_draw_ellipse(img, cx, 52 + bob, 8, 13, Color(0.600, 0.357, 0.196))
		_draw_ellipse(img, cx + 2, 56 + bob, 5, 9, Color(0.475, 0.275, 0.153))
		_draw_rect(img, cx - 7, 62 + bob, 14, 3, Color(0.231, 0.149, 0.078))
		_draw_rect(img, cx + 4, 62 + bob, 3, 3, Color(0.800, 0.651, 0.302))
		# braco de perfil
		_draw_ellipse(img, cx + 4, 52 + bob, 3, 7, Color(0.475, 0.275, 0.153))
		_draw_circle(img, cx + 5, 60 + bob, 2.5, Color(0.984, 0.725, 0.529))
		# ESPADA na frente
		_draw_rect(img, cx + 8, 50 + bob, 16, 3, Color(0.784, 0.804, 0.831))
		_draw_rect(img, cx + 6, 48 + bob, 4, 7, Color(0.420, 0.220, 0.114))
		_draw_rect(img, cx + 22, 49 + bob, 3, 5, Color(0.800, 0.651, 0.302))
		# CABECA de perfil (olhando pra direita)
		_draw_circle(img, cx, 32 + bob, 8, Color(0.984, 0.725, 0.529))
		_draw_ellipse(img, cx + 8, 34 + bob, 4, 3, Color(0.984, 0.725, 0.529))
		_draw_ellipse(img, cx - 1, 27 + bob, 8.5, 6, Color(0.529, 0.282, 0.145))
		_draw_ellipse(img, cx - 7, 32 + bob, 3, 6, Color(0.529, 0.282, 0.145))
		_draw_ellipse(img, cx - 2, 22 + bob, 2, 3, Color(0.529, 0.282, 0.145))
		_draw_ellipse(img, cx + 4, 21 + bob, 2, 3, Color(0.420, 0.220, 0.114))
		# orelha
		_draw_circle(img, cx - 1, 33 + bob, 2, Color(0.871, 0.596, 0.412))
		# olho de perfil + sobrancelha + boca
		_draw_rect(img, cx + 5, 30 + bob, 2, 2, Color(0.129, 0.071, 0.043))
		_draw_rect(img, cx + 4, 28 + bob, 4, 1, Color(0.420, 0.220, 0.114))
		_draw_rect(img, cx + 9, 37 + bob, 3, 1, Color(0.588, 0.353, 0.275))
	else:
		# FRENTE (down): igual ao original — rosto, peitoral, espada na mao direita
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

# ---------- CIDADE 1 (fiel à referência do usuário: lago com cachoeira+ponte à
# esquerda, área de treino com bonecos de palha no alto-esquerda, fonte multinível,
# loja de armas azul, loja de poções roxa = LOJA [F], casa marrom, torres nos portões) ----------
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
	# caminho LESTE-OESTE (cruza o lago pela ponte de madeira)
	for x in range(180, 920):
		var wobble = cos(x * 0.05) * 6
		for y in range(H / 2 - 26 + wobble, H / 2 + 26 + wobble):
			var c = dirt if (x + y) % 7 != 0 else dirt_d
			img.set_pixel(x, y, c)
	# caminho NORTE (da fonte pra muralha norte)
	for y in range(180, 440):
		var wobble = sin(y * 0.05) * 6
		for x in range(W / 2 - 26 + wobble, W / 2 + 26 + wobble):
			var c = dirt if (x + y) % 7 != 0 else dirt_d
			img.set_pixel(x, y, c)
	# caminho SUL: da fonte pro bueiro e desce ATÉ a borda (portao sul, fiel ao cenario)
	for y in range(580, 1024):
		var wobble = sin(y * 0.05) * 6
		for x in range(W / 2 - 26 + wobble, W / 2 + 26 + wobble):
			var c = dirt if (x + y) % 7 != 0 else dirt_d
			img.set_pixel(x, y, c)
	# ---- LAGO à esquerda (referência): margem de areia, agua, brilhos, vitorias-regias ----
	var pond_cx := 230.0
	var pond_cy := 480.0
	_draw_ellipse(img, pond_cx, pond_cy, 110, 150, Color(0.76, 0.68, 0.5))
	_draw_ellipse(img, pond_cx, pond_cy, 100, 140, Color(0.25, 0.45, 0.75))
	_draw_ellipse(img, pond_cx, pond_cy, 92, 132, Color(0.3, 0.52, 0.82))
	for i in range(30):
		var ang = randf() * TAU
		var rr = randf() * 0.8
		var px = pond_cx + cos(ang) * 100.0 * rr
		var py = pond_cy + sin(ang) * 140.0 * rr
		_draw_ellipse(img, px, py, 3 + randf() * 4, 1.2, Color(0.55, 0.75, 0.95, 0.6))
	for pos in [[180, 420], [270, 545], [200, 565], [290, 405]]:
		_draw_circle(img, pos[0], pos[1], 7, Color(0.3, 0.62, 0.32))
		_draw_circle(img, pos[0], pos[1], 4, Color(0.42, 0.74, 0.4))
	for pos in [[142, 505], [322, 460], [252, 612]]:
		_draw_circle(img, pos[0], pos[1], 6, Color(0.55, 0.53, 0.5))
	# ---- CACHOEira no topo do lago: rochas + filetes de agua caindo ----
	_draw_rect(img, 180, 320, 92, 26, Color(0.52, 0.5, 0.47))
	_draw_rect(img, 188, 312, 76, 10, Color(0.6, 0.58, 0.55))
	for i in range(5):
		var wx := 192 + i * 17
		_draw_rect(img, wx, 340, 6, 26, Color(0.75, 0.88, 1.0, 0.85))
		_draw_rect(img, wx + 1, 366, 4, 14, Color(0.6, 0.8, 0.98, 0.6))
	# ---- PONTE de madeira sobre o lago (o caminho leste-oeste passa por ela) ----
	for x in range(120, 340):
		for y in range(H / 2 - 26, H / 2 + 26):
			var plank = Color(0.55, 0.4, 0.24) if (x % 8) < 6 else Color(0.48, 0.34, 0.2)
			img.set_pixel(x, y, plank)
	_draw_rect(img, 118, H / 2 - 31, 224, 4, Color(0.42, 0.3, 0.18))
	_draw_rect(img, 118, H / 2 + 27, 224, 4, Color(0.42, 0.3, 0.18))
	# ---- PRAÇA e FONTE multinivel no centro (referência) ----
	_draw_circle(img, W / 2, H / 2, 105, Color(0.63, 0.61, 0.57))
	for i in range(400):
		var ang2 = randf() * TAU
		var r2 = randf() * 100
		var px2 = W / 2 + cos(ang2) * r2
		var py2 = H / 2 + sin(ang2) * r2
		img.set_pixel(px2, py2, Color(0.58, 0.56, 0.52))
	# base larga com agua
	_draw_circle(img, W / 2, H / 2, 52, Color(0.58, 0.56, 0.53))
	_draw_circle(img, W / 2, H / 2, 46, Color(0.3, 0.55, 0.85))
	_draw_circle(img, W / 2, H / 2, 42, Color(0.35, 0.62, 0.9))
	# tier medio
	_draw_circle(img, W / 2, H / 2, 26, Color(0.62, 0.6, 0.56))
	_draw_circle(img, W / 2, H / 2, 21, Color(0.35, 0.62, 0.9))
	# tier topo
	_draw_circle(img, W / 2, H / 2, 10, Color(0.66, 0.64, 0.6))
	_draw_circle(img, W / 2, H / 2, 5, Color(0.72, 0.7, 0.66))
	# jorros d'agua
	for i in range(3):
		_draw_ellipse(img, W / 2 + 24 - i * 10, H / 2 + 8 - i * 14, 6.0 - i, 2.0 - i * 0.5, Color(0.5, 0.72, 0.95, 0.6))
	# ---- MURALHA (alinhada aos colisores: portao LESTE arte y 466-578,
	# portao SUL arte x 466-578 — o caminho do bueiro desce livre até a borda) ----
	var wall := Color(0.6, 0.58, 0.54)
	var wall_d := Color(0.5, 0.48, 0.45)
	# topo (contínua)
	for i in range(0, W, 2):
		var wv = sin(i * 0.08) * 2
		_draw_ellipse(img, i, 143 + wv, 2.2, 14, wall)
		if i % 8 == 0:
			_draw_ellipse(img, i + 1, 143 + wv, 1.8, 14, wall_d)
	# esquerda (contínua, y 150-861)
	for j in range(150, 861, 2):
		var wv2 = cos(j * 0.08) * 2
		_draw_ellipse(img, 143 + wv2, j, 14, 2.2, wall)
		if j % 8 == 0:
			_draw_ellipse(img, 143 + wv2, j + 1, 14, 1.8, wall_d)
	# direita com PORTAO LESTE (abertura y 466-578)
	for j in range(150, 861, 2):
		if j > 460 and j < 584:
			continue
		var wv3 = cos(j * 0.08) * 2
		_draw_ellipse(img, 881 + wv3, j, 14, 2.2, wall)
		if j % 8 == 0:
			_draw_ellipse(img, 881 + wv3, j + 1, 14, 1.8, wall_d)
	# baixo com PORTAO SUL (abertura x 466-578 = o caminho do bueiro)
	for i in range(100, 926, 2):
		if i > 460 and i < 584:
			continue
		var wv4 = sin(i * 0.08) * 2
		_draw_ellipse(img, i, 881 + wv4, 2.2, 14, wall)
		if i % 8 == 0:
			_draw_ellipse(img, i + 1, 881 + wv4, 1.8, 14, wall_d)
	# ameias nas muralhas
	for i in range(150, 860, 42):
		_draw_circle(img, i, 124, 8, wall)
		_draw_circle(img, i, 900, 8, wall)
	for j in range(150, 860, 42):
		_draw_circle(img, 124, j, 8, wall)
		_draw_circle(img, 900, j, 8, wall)
	# torres de esquina
	for pos in [[143, 143], [881, 143], [143, 881], [881, 881]]:
		_draw_circle(img, pos[0], pos[1], 22, Color(0.66, 0.64, 0.6))
		_draw_circle(img, pos[0], pos[1], 14, Color(0.72, 0.7, 0.66))
		_draw_circle(img, pos[0], pos[1], 5, Color(0.35, 0.33, 0.3))
	# ---- TORRES com bandeira nas esquinas dos portoes (referência) ----
	for pos in [[881, 452], [881, 592], [452, 881], [592, 881]]:
		_draw_circle(img, pos[0], pos[1], 20, Color(0.66, 0.64, 0.6))
		_draw_circle(img, pos[0], pos[1], 14, Color(0.72, 0.7, 0.66))
		_draw_circle(img, pos[0], pos[1], 5, Color(0.35, 0.33, 0.3))
		_draw_rect(img, pos[0] - 1, pos[1] - 46, 3, 32, Color(0.35, 0.24, 0.14))
		_draw_rect(img, pos[0] + 2, pos[1] - 46, 14, 9, Color(0.8, 0.25, 0.2))
	# ---- LOJA DE ARMAS (teto azul, placa com espadas cruzadas) ----
	_draw_building(img, 640, 220, 160, 115, Color(0.3, 0.45, 0.8))
	_draw_rect(img, 700, 178, 40, 26, Color(0.45, 0.3, 0.18))
	_draw_rect(img, 700, 178, 40, 4, Color(0.55, 0.4, 0.24))
	for i in range(14):
		img.set_pixel(708 + i, 184 + i, Color(0.8, 0.82, 0.85))
		img.set_pixel(721 - i, 184 + i, Color(0.8, 0.82, 0.85))
	for i in range(3):
		_draw_rect(img, 620 + i * 24, 330, 18, 26, Color(0.52, 0.38, 0.22))
		_draw_rect(img, 620 + i * 24, 330, 18, 5, Color(0.62, 0.46, 0.28))
	# ---- LOJA DE POÇÕES (teto roxo, placa com frasco — esta é a LOJA [F]) ----
	_draw_building(img, 210, 640, 160, 115, Color(0.6, 0.35, 0.75))
	_draw_rect(img, 250, 596, 40, 26, Color(0.45, 0.3, 0.18))
	_draw_rect(img, 250, 596, 40, 4, Color(0.55, 0.4, 0.24))
	_draw_rect(img, 267, 602, 6, 5, Color(0.75, 0.78, 0.82))
	_draw_circle(img, 270, 613, 6, Color(0.85, 0.25, 0.3))
	for i in range(3):
		_draw_rect(img, 230 + i * 22, 750, 12, 18, Color(0.5, 0.36, 0.5))
		_draw_rect(img, 233 + i * 22, 746, 6, 5, Color(0.6, 0.5, 0.6))
	# ---- CASA MARROM com chamine (canto sudeste, referência) ----
	_draw_building(img, 800, 760, 140, 100, Color(0.55, 0.38, 0.22))
	_draw_rect(img, 880, 726, 16, 26, Color(0.5, 0.36, 0.3))
	# ---- ÁREA DE TREINO (alto-esquerda, referência): areia, cerca, bonecos de palha ----
	_draw_rect(img, 175, 185, 230, 150, Color(0.82, 0.72, 0.5))
	for i in range(300):
		var sx = 180 + randi() % 220
		var sy = 190 + randi() % 140
		img.set_pixel(sx, sy, Color(0.74, 0.64, 0.44))
	for x in range(175, 406, 22):
		_draw_rect(img, x, 176, 5, 12, Color(0.5, 0.36, 0.2))
		_draw_rect(img, x, 330, 5, 12, Color(0.5, 0.36, 0.2))
	for y in range(185, 336, 22):
		_draw_rect(img, 168, y, 12, 5, Color(0.5, 0.36, 0.2))
		_draw_rect(img, 398, y, 12, 5, Color(0.5, 0.36, 0.2))
	for pos in [[250, 255], [340, 255]]:
		_draw_rect(img, pos[0] - 3, pos[1] + 12, 6, 24, Color(0.45, 0.32, 0.18))
		_draw_ellipse(img, pos[0], pos[1], 14, 18, Color(0.85, 0.72, 0.4))
		_draw_rect(img, pos[0] - 14, pos[1] - 4, 28, 4, Color(0.6, 0.45, 0.2))
		_draw_circle(img, pos[0], pos[1] - 22, 8, Color(0.85, 0.72, 0.4))
	# ---- árvores reposicionadas (fora do lago/caminhos/prédios) ----
	for pos in [[450, 330], [880, 320], [930, 700], [430, 860], [160, 770], [880, 180]]:
		_draw_tree(img, pos[0], pos[1])
	for i in range(40):
		var fx = 20 + randi() % (W - 40)
		var fy = 20 + randi() % (H - 40)
		if img.get_pixel(fx, fy).g > 0.5:
			var fc = [Color(0.9, 0.8, 0.3), Color(0.9, 0.5, 0.6), Color(0.8, 0.8, 0.95)][randi() % 3]
			_draw_circle(img, fx, fy, 1.5, fc)
	# bueiro com escada (saida sul pro bueiro/caverna) — no caminho sul
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
	# estrada de terra no PORTAO LESTE (saida pra city2)
	for y in range(H / 2 - 46, H / 2 + 46):
		for x in range(W - 130, W):
			var c2 = dirt if (x + y) % 7 != 0 else dirt_d
			img.set_pixel(x, y, c2)
	_draw_rect(img, W - 90, H / 2 - 52, 70, 14, Color(0.45, 0.3, 0.18))
	_draw_rect(img, W - 90, H / 2 + 38, 70, 14, Color(0.45, 0.3, 0.18))
	return ImageTexture.create_from_image(img)


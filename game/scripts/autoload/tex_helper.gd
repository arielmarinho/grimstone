# ---------- CIDADE 2 (portao LESTE da city1 — vila de pedra, estilo anao) ----------
static func _map_city2() -> Texture2D:
	# VILA ANA (nivel de arte = city1 v0.6.23): base oliva de montanha, ruas de
	# pedra com paralelepipedos, praca com estatua de heroi ana, muralha de
	# blocos com ameias/torres/estandartes, casas de pedra com telhado de cobre,
	# forja acesa com fumaca, rochas e arvores esparsas.
	# FIEL AOS COLISORES (colliders.gd _city2): portao OESTE abertura y 466-578
	# (arte), muralha SUL em 2 segmentos (x 100-250 e 775-925 — estrada desce
	# livre ate a borda), LESTE fechada, 4 casas, forja, estatua central.
	var W := 1024
	var H := 1024
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.44, 0.6, 0.32))
	for i in range(9000):
		var x = randi() % W
		var y = randi() % H
		var shade = 0.38 + randf() * 0.14
		img.set_pixel(x, y, Color(shade, shade + 0.18, shade * 0.62))
	for i in range(120):
		var gx = 20 + randi() % (W - 40)
		var gy = 20 + randi() % (H - 40)
		_draw_ellipse(img, gx, gy, 2 + randf() * 3, 1.5 + randf() * 2, Color(0.34, 0.5, 0.24, 0.5))
	# ---- RUAS DE PEDRA (paralelepipedos com juntas e pedras claras) ----
	var stone := Color(0.58, 0.56, 0.53)
	var stone_d := Color(0.47, 0.45, 0.43)
	var stone_l := Color(0.67, 0.65, 0.61)
	# rua NORTE-SUL: da muralha norte ate a BORDA sul (estrada desce ate a saida)
	for y in range(150, H):
		var wob = sin(y * 0.05) * 5
		for x in range(W / 2 - 30 + wob, W / 2 + 30 + wob):
			var c = stone if (x / 6 + y / 6) % 2 == 0 else stone_d
			if (x + y) % 11 == 0:
				c = stone_l
			img.set_pixel(x, y, c)
	# rua LESTE-OESTE: do portao oeste ate a muralha leste
	for x in range(0, 880):
		var wob2 = cos(x * 0.05) * 5
		for y in range(H / 2 - 30 + wob2, H / 2 + 30 + wob2):
			var c = stone if (x / 6 + y / 6) % 2 == 0 else stone_d
			if (x + y) % 11 == 0:
				c = stone_l
			img.set_pixel(x, y, c)
	# meio-fio nas bordas das ruas
	for y in range(150, H, 3):
		var wob3 = sin(y * 0.05) * 5
		_draw_rect(img, W / 2 - 33 + wob3, y, 3, 3, stone_d)
		_draw_rect(img, W / 2 + 30 + wob3, y, 3, 3, stone_d)
	for x in range(0, 880, 3):
		var wob4 = cos(x * 0.05) * 5
		_draw_rect(img, x, H / 2 - 33 + wob4, 3, 3, stone_d)
		_draw_rect(img, x, H / 2 + 30 + wob4, 3, 3, stone_d)
	# ---- PRACA central de pedra com anel ----
	_draw_circle(img, W / 2, H / 2, 105, Color(0.62, 0.6, 0.57))
	for i in range(500):
		var ang = randf() * TAU
		var rr = randf() * 103
		var px = W / 2 + cos(ang) * rr
		var py = H / 2 + sin(ang) * rr
		var pc = stone if (int(px) / 6 + int(py) / 6) % 2 == 0 else stone_d
		img.set_pixel(px, py, pc)
	_draw_circle_ring(img, W / 2, H / 2, 105, Color(0.5, 0.48, 0.45))
	# ---- ESTATUA do heroi ana (pedestal de blocos + figura com machado) ----
	var sx := W / 2
	var sy := H / 2
	_draw_circle(img, sx, sy, 56, Color(0.55, 0.53, 0.5))
	_draw_rect(img, sx - 34, sy - 6, 68, 44, Color(0.52, 0.5, 0.47))
	_draw_rect(img, sx - 26, sy - 16, 52, 12, Color(0.6, 0.58, 0.55))
	_draw_rect(img, sx - 18, sy - 26, 36, 10, Color(0.56, 0.54, 0.51))
	for yy in range(sy - 4, sy + 36, 8):
		for xx in range(sx - 32, sx + 30, 12):
			_draw_rect(img, xx, yy, 10, 6, Color(0.46, 0.44, 0.42))
	# figura: pernas, tunica, cabeca, barba, capacete com chifres, machado
	_draw_rect(img, sx - 8, sy - 40, 6, 14, Color(0.4, 0.3, 0.2))
	_draw_rect(img, sx + 2, sy - 40, 6, 14, Color(0.4, 0.3, 0.2))
	_draw_rect(img, sx - 10, sy - 58, 20, 20, Color(0.55, 0.42, 0.28))
	_draw_circle(img, sx, sy - 64, 7, Color(0.85, 0.65, 0.5))
	_draw_rect(img, sx - 6, sy - 60, 12, 10, Color(0.75, 0.45, 0.2))
	_draw_rect(img, sx - 8, sy - 72, 16, 8, Color(0.6, 0.6, 0.62))
	_draw_rect(img, sx - 12, sy - 74, 4, 4, Color(0.8, 0.78, 0.7))
	_draw_rect(img, sx + 8, sy - 74, 4, 4, Color(0.8, 0.78, 0.7))
	_draw_rect(img, sx + 10, sy - 60, 4, 22, Color(0.4, 0.28, 0.16))
	_draw_rect(img, sx + 6, sy - 62, 14, 5, Color(0.7, 0.7, 0.72))
	# ---- MURALHA de blocos (fiel aos colisores) ----
	var wall := Color(0.56, 0.54, 0.51)
	var wall_d := Color(0.44, 0.42, 0.4)
	# topo (continua)
	for i in range(100, 926, 4):
		_draw_rect(img, i, 140, 4, 16, wall if (i / 4) % 3 != 0 else wall_d)
	_draw_rect(img, 100, 136, 826, 4, wall_d)
	# leste (continua)
	for j in range(150, 902, 4):
		_draw_rect(img, 890, j, 16, 4, wall if (j / 4) % 3 != 0 else wall_d)
	_draw_rect(img, 902, 150, 4, 752, wall_d)
	# oeste com PORTAO (abertura y 466-578)
	for j in range(150, 902, 4):
		if j > 462 and j < 582:
			continue
		_draw_rect(img, 140, j, 16, 4, wall if (j / 4) % 3 != 0 else wall_d)
	_draw_rect(img, 136, 150, 4, 316, wall_d)
	_draw_rect(img, 136, 582, 4, 320, wall_d)
	# sul em 2 segmentos (x 100-250 e 775-925) — estrada desce livre no meio
	for i in range(100, 252, 4):
		_draw_rect(img, i, 890, 4, 16, wall if (i / 4) % 3 != 0 else wall_d)
	for i in range(775, 926, 4):
		_draw_rect(img, i, 890, 4, 16, wall if (i / 4) % 3 != 0 else wall_d)
	_draw_rect(img, 100, 902, 152, 4, wall_d)
	_draw_rect(img, 775, 902, 151, 4, wall_d)
	# ameias no lado interno
	for i in range(110, 920, 36):
		_draw_rect(img, i, 156, 10, 8, wall)
	for j in range(160, 900, 36):
		if j > 462 and j < 582:
			continue
		_draw_rect(img, 156, j, 8, 10, wall)
		_draw_rect(img, 874, j, 8, 10, wall)
	for i in range(110, 250, 36):
		_draw_rect(img, i, 874, 10, 8, wall)
	for i in range(780, 920, 36):
		_draw_rect(img, i, 874, 10, 8, wall)
	# torres de esquina (round com ameias + seteira)
	for pos in [[143, 143], [881, 143], [143, 881], [881, 881]]:
		_draw_circle(img, pos[0], pos[1], 22, Color(0.62, 0.6, 0.57))
		_draw_circle(img, pos[0], pos[1], 16, Color(0.7, 0.68, 0.64))
		_draw_rect(img, pos[0] - 2, pos[1] - 6, 4, 12, Color(0.3, 0.28, 0.26))
		for a in range(6):
			var ta = TAU * a / 6.0
			_draw_circle(img, pos[0] + cos(ta) * 19, pos[1] + sin(ta) * 19, 3, Color(0.5, 0.48, 0.45))
	# torres de portao com ESTANDARTE azul/dourado (oeste e sul)
	for pos in [[143, 452], [143, 592], [250, 890], [775, 890]]:
		_draw_circle(img, pos[0], pos[1], 18, Color(0.62, 0.6, 0.57))
		_draw_circle(img, pos[0], pos[1], 12, Color(0.7, 0.68, 0.64))
		_draw_rect(img, pos[0] - 1, pos[1] - 44, 3, 32, Color(0.35, 0.24, 0.14))
		_draw_rect(img, pos[0] + 2, pos[1] - 44, 14, 10, Color(0.25, 0.4, 0.75))
		_draw_circle(img, pos[0] + 9, pos[1] - 39, 3, Color(0.9, 0.75, 0.25))
	# ---- 4 CASAS ANAS (pedra + telhado de cobre, chamine com fumaca) ----
	for hb in [[220, 225], [605, 225], [220, 640], [605, 640]]:
		var hx = hb[0]
		var hy = hb[1]
		_draw_ellipse(img, hx + 75, hy + 104, 82, 8, Color(0, 0, 0, 0.22))
		# parede de pedra com tijolos
		_draw_rect(img, hx + 6, hy + 50, 138, 54, Color(0.72, 0.68, 0.62))
		for yy in range(hy + 54, hy + 100, 10):
			for xx in range(hx + 8, hx + 140, 18):
				_draw_rect(img, xx, yy, 15, 7, Color(0.62, 0.58, 0.52) if (xx / 18 + yy / 10) % 2 == 0 else Color(0.72, 0.68, 0.62))
		# telhado de cobre (duas aguas) com cumeeira
		var roof := Color(0.72, 0.45, 0.2)
		var peak = hy + 6
		for i2 in range(46):
			var t = float(i2) / 46.0
			var rw = int(75 * (1.0 - t) + 10)
			var rc = roof if i2 % 6 != 0 else roof.darkened(0.25)
			_draw_rect(img, hx + 75 - rw, peak + i2, rw * 2, 1, rc)
		_draw_rect(img, hx + 2, hy + 48, 146, 4, roof.darkened(0.3))
		_draw_rect(img, hx + 72, peak - 2, 6, 4, roof.lightened(0.2))
		# porta em arco + macaneta
		_draw_rect(img, hx + 66, hy + 78, 18, 26, Color(0.45, 0.3, 0.16))
		_draw_circle(img, hx + 75, hy + 78, 9, Color(0.45, 0.3, 0.16))
		_draw_circle(img, hx + 80, hy + 92, 1.5, Color(0.85, 0.7, 0.3))
		# janelas com brilho quente
		for wx in [hx + 20, hx + 116]:
			_draw_rect(img, wx, hy + 60, 12, 12, Color(0.95, 0.75, 0.35))
			_draw_rect(img, wx - 2, hy + 58, 16, 3, Color(0.5, 0.36, 0.22))
			_draw_rect(img, wx - 2, hy + 58, 3, 16, Color(0.5, 0.36, 0.22))
			_draw_rect(img, wx + 11, hy + 58, 3, 16, Color(0.5, 0.36, 0.22))
			_draw_rect(img, wx, hy + 70, 12, 2, Color(0.5, 0.36, 0.22))
		# chamine com fumaca
		_draw_rect(img, hx + 108, hy + 18, 12, 22, Color(0.5, 0.36, 0.3))
		_draw_rect(img, hx + 106, hy + 16, 16, 4, Color(0.4, 0.28, 0.24))
		for s in range(3):
			_draw_circle(img, hx + 114 + s * 3, hy + 8 - s * 7, 4.0 - s * 0.8, Color(0.85, 0.85, 0.85, 0.5 - s * 0.12))
	# ---- FORJA acesa (canto sudeste): forno de pedra + chamine + fumaca ----
	_draw_ellipse(img, 780, 812, 40, 7, Color(0, 0, 0, 0.22))
	_draw_rect(img, 752, 752, 56, 56, Color(0.5, 0.47, 0.44))
	for yy in range(756, 804, 10):
		for xx in range(754, 804, 14):
			_draw_rect(img, xx, yy, 11, 7, Color(0.42, 0.4, 0.38) if (xx / 14 + yy / 10) % 2 == 0 else Color(0.5, 0.47, 0.44))
	# boca do forno acesa
	_draw_rect(img, 764, 780, 32, 22, Color(0.2, 0.12, 0.08))
	_draw_circle(img, 780, 792, 12, Color(0.95, 0.45, 0.1))
	_draw_circle(img, 780, 792, 8, Color(1.0, 0.75, 0.25))
	_draw_circle(img, 780, 792, 4, Color(1.0, 0.95, 0.6))
	# chamine + fumaca
	_draw_rect(img, 796, 722, 14, 32, Color(0.45, 0.42, 0.4))
	_draw_rect(img, 793, 718, 20, 5, Color(0.36, 0.34, 0.32))
	for s in range(4):
		_draw_circle(img, 803 + s * 4, 706 - s * 9, 6.0 - s, Color(0.8, 0.8, 0.82, 0.55 - s * 0.1))
	# ---- ROCHAS (vibe de montanha) e arvores esparsas ----
	for pos in [[380, 420], [700, 480], [420, 760], [840, 560], [300, 860], [620, 200]]:
		_draw_ellipse(img, pos[0], pos[1], 10, 7, Color(0.55, 0.53, 0.5))
		_draw_ellipse(img, pos[0] - 2, pos[1] - 2, 7, 4, Color(0.66, 0.64, 0.6))
	for pos in [[90, 300], [930, 320], [90, 700], [430, 110], [500, 950]]:
		_draw_tree(img, pos[0], pos[1])
	# flores so na grama
	for i in range(40):
		var fx = 20 + randi() % (W - 40)
		var fy = 20 + randi() % (H - 40)
		var fc = img.get_pixel(fx, fy)
		if fc.g > fc.r + 0.05:
			var fl = [Color(0.9, 0.8, 0.3), Color(0.9, 0.5, 0.6), Color(0.8, 0.8, 0.95)][randi() % 3]
			_draw_circle(img, fx, fy, 1.5, fl)
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

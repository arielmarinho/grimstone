extends Object
## DECOR (v0.6.8) — decoracao procedural das cidades (polish de mapas):
## postes de luz com brilho, canteiros de flores, barris, caixotes,
## bandeiras nos portoes e barraca de feira. Objetos solidos ganham colisor.
## Adicionada ao map_layer DEPOIS de build_colliders (e limpa junto no switch).

const LAMP := 0
const FLOWERS := 1
const BARREL := 2
const CRATE := 3
const FLAG := 4
const STALL := 5

# [tipo, pos, solido]
const CITY1_DECOR := [
	[LAMP, Vector2(640, 950), false], [LAMP, Vector2(1408, 950), false],
	[LAMP, Vector2(640, 1100), false], [LAMP, Vector2(1408, 1100), false],
	[LAMP, Vector2(950, 700), false], [LAMP, Vector2(1100, 700), false],
	[LAMP, Vector2(950, 1250), false], [LAMP, Vector2(1100, 1250), false],
	[FLOWERS, Vector2(860, 1024), false], [FLOWERS, Vector2(1188, 1024), false],
	[FLOWERS, Vector2(1024, 860), false], [FLOWERS, Vector2(1024, 1188), false],
	[BARREL, Vector2(440, 1560), true], [BARREL, Vector2(460, 1620), true],
	[CRATE, Vector2(700, 1560), true],
	[FLAG, Vector2(1770, 900), false], [FLAG, Vector2(1770, 1150), false],
	[STALL, Vector2(1600, 1250), true],
]
const CITY2_DECOR := [
	[LAMP, Vector2(640, 950), false], [LAMP, Vector2(1408, 950), false],
	[LAMP, Vector2(640, 1100), false], [LAMP, Vector2(1408, 1100), false],
	[LAMP, Vector2(950, 700), false], [LAMP, Vector2(1100, 700), false],
	[LAMP, Vector2(950, 1250), false], [LAMP, Vector2(1100, 1250), false],
	[FLOWERS, Vector2(860, 1024), false], [FLOWERS, Vector2(1188, 1024), false],
	[FLOWERS, Vector2(1024, 860), false], [FLOWERS, Vector2(1024, 1188), false],
	[CRATE, Vector2(1470, 1620), true], [CRATE, Vector2(1650, 1500), true],
	[BARREL, Vector2(1660, 720), true],
	[FLAG, Vector2(280, 900), false], [FLAG, Vector2(280, 1150), false],
	[STALL, Vector2(1320, 420), true],
]

static func build_decor(map_name: String, parent: Node) -> void:
	var items: Array = []
	if map_name == "city1":
		items = CITY1_DECOR
	elif map_name == "city2":
		items = CITY2_DECOR
	for it in items:
		var pos: Vector2 = it[1]
		var solid: bool = it[2]
		var root: Node2D
		if solid:
			var body = StaticBody2D.new()
			body.position = pos
			var cs = CollisionShape2D.new()
			var sh = CircleShape2D.new()
			sh.radius = 26.0
			cs.shape = sh
			body.add_child(cs)
			parent.add_child(body)
			root = body
		else:
			root = Node2D.new()
			root.position = pos
			parent.add_child(root)
		var spr = Sprite2D.new()
		spr.texture = _tex_of(it[0])
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.scale = Vector2(2, 2)
		root.add_child(spr)
		if it[0] == LAMP:
			var glow = Sprite2D.new()
			glow.texture = _tex_glow()
			glow.position = Vector2(0, -52)
			glow.scale = Vector2(2, 2)
			var mat = CanvasItemMaterial.new()
			mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			glow.material = mat
			root.add_child(glow)
			glow.z_index = -1

static func _tex_of(kind: int) -> ImageTexture:
	match kind:
		LAMP: return _tex_lamp()
		FLOWERS: return _tex_flowers()
		BARREL: return _tex_barrel()
		CRATE: return _tex_crate()
		FLAG: return _tex_flag()
	return _tex_stall()

# ---------- texturas procedurais (48x64, estilo pixel) ----------
static func _tex_lamp() -> ImageTexture:
	var img = Image.create(48, 64, false, Image.FORMAT_RGBA8)
	# base de pedra
	for x in range(18, 30):
		for y in range(56, 62):
			img.set_pixel(x, y, Color(0.45, 0.43, 0.4))
	# poste de metal escuro
	for x in range(22, 26):
		for y in range(16, 58):
			img.set_pixel(x, y, Color(0.22, 0.2, 0.24))
	# braco e lampada
	for x in range(22, 26):
		for y in range(10, 16):
			img.set_pixel(x, y, Color(0.22, 0.2, 0.24))
	for x in range(16, 32):
		for y in range(4, 14):
			img.set_pixel(x, y, Color(1.0, 0.85, 0.4))
	for x in range(18, 30):
		for y in range(2, 4):
			img.set_pixel(x, y, Color(0.22, 0.2, 0.24))
	return ImageTexture.create_from_image(img)

static func _tex_glow() -> ImageTexture:
	var img = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	for y in range(48):
		for x in range(48):
			var d = Vector2(x - 24, y - 24).length() / 24.0
			if d < 1.0:
				img.set_pixel(x, y, Color(1.0, 0.8, 0.35, 0.28 * (1.0 - d)))
	return ImageTexture.create_from_image(img)

static func _tex_flowers() -> ImageTexture:
	var img = Image.create(48, 24, false, Image.FORMAT_RGBA8)
	# canteiro de terra
	for y in range(14, 24):
		for x in range(2, 46):
			img.set_pixel(x, y, Color(0.45, 0.32, 0.2) if (x + y) % 5 != 0 else Color(0.38, 0.27, 0.17))
	var cols := [Color(0.95, 0.35, 0.4), Color(0.95, 0.85, 0.3), Color(0.75, 0.5, 0.95), Color(0.95, 0.6, 0.3)]
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in range(9):
		var fx = 6 + (i % 5) * 9 + rng.randi_range(-2, 2)
		var fy = 6 + (i / 5) * 7 + rng.randi_range(-1, 1)
		var c: Color = cols[i % cols.size()]
		for dx in range(-2, 3):
			for dy in range(-2, 3):
				if dx * dx + dy * dy <= 4:
					img.set_pixel(fx + dx, fy + dy, c)
		img.set_pixel(fx, fy + 2, Color(0.3, 0.55, 0.25))
	return ImageTexture.create_from_image(img)

static func _tex_barrel() -> ImageTexture:
	var img = Image.create(40, 48, false, Image.FORMAT_RGBA8)
	var wood := Color(0.55, 0.38, 0.2)
	var wood_d := Color(0.42, 0.29, 0.15)
	for y in range(6, 46):
		for x in range(6, 34):
			var t = float(x - 6) / 28.0
			var edge = absf(t - 0.5) * 2.0
			if edge < 0.92:
				img.set_pixel(x, y, wood if y % 9 != 0 else wood_d)
	# aros de metal
	for y in [10, 11, 38, 39]:
		for x in range(6, 34):
			if img.get_pixel(x, y).a > 0.0:
				img.set_pixel(x, y, Color(0.35, 0.33, 0.3))
	# tampa
	for y in range(4, 8):
		for x in range(8, 32):
			img.set_pixel(x, y, wood_d)
	return ImageTexture.create_from_image(img)

static func _tex_crate() -> ImageTexture:
	var img = Image.create(40, 40, false, Image.FORMAT_RGBA8)
	var wood := Color(0.62, 0.45, 0.24)
	var wood_d := Color(0.48, 0.34, 0.18)
	for y in range(4, 38):
		for x in range(4, 36):
			img.set_pixel(x, y, wood)
	# bordas e diagonal
	for i in range(4, 36):
		img.set_pixel(i, 4, wood_d)
		img.set_pixel(i, 37, wood_d)
		img.set_pixel(4, i, wood_d)
		img.set_pixel(35, i, wood_d)
		img.set_pixel(i, i, wood_d)
		img.set_pixel(39 - i, i, wood_d)
	return ImageTexture.create_from_image(img)

static func _tex_flag() -> ImageTexture:
	var img = Image.create(32, 64, false, Image.FORMAT_RGBA8)
	# mastro
	for x in range(14, 17):
		for y in range(4, 62):
			img.set_pixel(x, y, Color(0.3, 0.26, 0.2))
	# bandeira vermelha ondulada
	for x in range(17, 30):
		var wave = int(sin(x * 0.5) * 2.0)
		for y in range(6 + wave, 20 + wave):
			img.set_pixel(x, y, Color(0.8, 0.25, 0.2) if (x + y) % 7 != 0 else Color(0.65, 0.2, 0.16))
	return ImageTexture.create_from_image(img)

static func _tex_stall() -> ImageTexture:
	var img = Image.create(72, 56, false, Image.FORMAT_RGBA8)
	# pernas
	for x in [8, 9, 62, 63]:
		for y in range(28, 54):
			img.set_pixel(x, y, Color(0.45, 0.32, 0.18))
	# mesa
	for y in range(26, 32):
		for x in range(4, 68):
			img.set_pixel(x, y, Color(0.58, 0.42, 0.22))
	# toldo listrado
	for x in range(2, 70):
		for y in range(4, 16):
			var stripe = (x / 6) % 2 == 0
			img.set_pixel(x, y, Color(0.85, 0.3, 0.25) if stripe else Color(0.92, 0.88, 0.8))
	# mercadorias na mesa
	var cols := [Color(0.9, 0.7, 0.2), Color(0.6, 0.75, 0.3), Color(0.8, 0.4, 0.5)]
	for i in range(6):
		var gx = 10 + i * 10
		for dx in range(-3, 4):
			for dy in range(-3, 4):
				if dx * dx + dy * dy <= 5:
					img.set_pixel(gx + dx, 22 + dy, cols[i % cols.size()])
	return ImageTexture.create_from_image(img)

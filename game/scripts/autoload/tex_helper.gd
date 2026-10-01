extends Object
## TexHelper — carrega sprite real do disco; se nao existir, gera grafico procedural

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
	for f in range(4):
		var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var bob := 0 if f % 2 == 0 else 2
		var body_color := Color(0.55, 0.38, 0.2) if not is_rat else Color(0.45, 0.32, 0.18)
		var cx := 32
		if is_rat:
			_draw_rect(img, cx - 12, 44, 6, 8, body_color)
			_draw_rect(img, cx + 6, 44, 6, 8, body_color)
			_draw_rect(img, cx - 14, 30, 28, 16, body_color)
			_draw_rect(img, cx - 8, 22 + bob, 16, 12, body_color)
			_draw_rect(img, cx - 8, 18 + bob, 5, 5, Color(0.85, 0.65, 0.7))
			_draw_rect(img, cx + 3, 18 + bob, 5, 5, Color(0.85, 0.65, 0.7))
			_draw_rect(img, cx - 5, 26 + bob, 3, 3, Color(0.9, 0.1, 0.1))
			_draw_rect(img, cx + 2, 26 + bob, 3, 3, Color(0.9, 0.1, 0.1))
			if is_attack and f >= 2:
				_draw_rect(img, cx - 4, 34, 8, 5, Color(0.95, 0.9, 0.85))
			if is_death and f >= 2:
				img.rotate_90(CLOCKWISE)
		else:
			_draw_rect(img, cx - 8, 46, 6, 10, Color(0.3, 0.2, 0.12))
			_draw_rect(img, cx + 2, 46, 6, 10, Color(0.3, 0.2, 0.12))
			_draw_rect(img, cx - 11, 28 + bob, 22, 20, Color(0.6, 0.42, 0.22))
			_draw_rect(img, cx - 9, 16 + bob, 18, 14, Color(0.85, 0.7, 0.55))
			_draw_rect(img, cx - 9, 14 + bob, 18, 5, Color(0.35, 0.22, 0.1))
			_draw_rect(img, cx - 5, 20 + bob, 3, 3, Color(0, 0, 0))
			_draw_rect(img, cx + 2, 20 + bob, 3, 3, Color(0, 0, 0))
			_draw_rect(img, cx + 13, 30 + bob, 4, 22, Color(0.8, 0.82, 0.85))
			if is_attack and f >= 2:
				_draw_rect(img, cx + 8, 20 + bob, 10, 30, Color(0.9, 0.92, 0.95))
			if is_death and f >= 2:
				img.rotate_90(CLOCKWISE)
		frames.append(ImageTexture.create_from_image(img))
	return frames

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
		return img
	var img2 = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	img2.fill(Color(0.35, 0.6, 0.3))
	for x in range(230, 280):
		for y in range(512):
			img2.set_pixel(x, y, Color(0.75, 0.65, 0.5))
	for i in range(512):
		_draw_rect(img2, i, 60, 1, 10, Color(0.5, 0.5, 0.52))
	return ImageTexture.create_from_image(img2)

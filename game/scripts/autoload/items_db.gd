class_name ItemsDB
extends Object
## Banco de itens do Grimstone

const ITEMS = {
	"moeda": {"nome": "Moedas", "tipo": "moeda", "cor": Color(0.9, 0.75, 0.2)},
	"carne": {"nome": "Carne", "tipo": "uso", "cor": Color(0.72, 0.3, 0.24), "hp": 30, "desc": "Recupera 30 HP"},
	"pocao_vida": {"nome": "Pocao de Vida", "tipo": "uso", "cor": Color(0.85, 0.2, 0.25), "hp": 50, "desc": "Recupera 50 HP"},
	"pocao_mana": {"nome": "Pocao de Mana", "tipo": "uso", "cor": Color(0.3, 0.45, 0.9), "mana": 40, "desc": "Recupera 40 Mana"},
	"espada": {"nome": "Espada", "tipo": "arma", "arma": "sword", "cor": Color(0.8, 0.82, 0.86)},
	"machado": {"nome": "Machado", "tipo": "arma", "arma": "axe", "cor": Color(0.75, 0.77, 0.8)},
	"arco": {"nome": "Arco", "tipo": "arma", "arma": "bow", "cor": Color(0.55, 0.4, 0.22)},
	"cajado": {"nome": "Cajado", "tipo": "arma", "arma": "staff", "cor": Color(0.5, 0.36, 0.2)},
}

static func draw_icon(id: String, size: int = 24) -> Texture2D:
	# 1) PNG real (assets_override > assets/icons)
	for base in ["res://assets_override/icons/", "res://assets/icons/"]:
		var path = base + id + ".png"
		if ResourceLoader.exists(path):
			var tex = load(path)
			if tex != null:
				return tex
	# 2) PNG embutido (base64 da arte pixel real)
	var embedded = preload("res://scripts/autoload/icons_embedded.gd")
	var png_bytes = embedded.get_png_bytes(id)
	if png_bytes.size() > 0:
		var img = Image.new()
		if img.load_png_from_buffer(png_bytes) == OK:
			return ImageTexture.create_from_image(img)
	# 3) fallback: desenha por codigo
	var img2 = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img2.fill(Color(0, 0, 0, 0))
	var it = ITEMS.get(id, {"cor": Color(0.5, 0.5, 0.5), "tipo": ""})
	var c: Color = it["cor"]
	var cx = size / 2.0
	var cy = size / 2.0
	match it.get("tipo", ""):
		"moeda":
			_ellipse(img2, cx, cy, size * 0.32, size * 0.32, Color(0.55, 0.4, 0.1))
			_ellipse(img2, cx, cy, size * 0.26, size * 0.26, c)
			_ellipse(img2, cx - size * 0.08, cy - size * 0.08, size * 0.08, size * 0.08, Color(1, 0.95, 0.7))
		"uso":
			if id == "carne":
				_ellipse(img2, cx, cy + 2, size * 0.3, size * 0.2, Color(0.45, 0.18, 0.12))
				_ellipse(img2, cx, cy + 2, size * 0.24, size * 0.14, c)
				_ellipse(img2, cx - size * 0.28, cy + 2, size * 0.1, size * 0.06, Color(0.95, 0.93, 0.85))
			else:
				_rect(img2, int(cx - 3), int(cy - size * 0.32), 6, 4, Color(0.75, 0.78, 0.8))
				_ellipse(img2, cx, cy + 2, size * 0.22, size * 0.26, Color(0.2, 0.2, 0.25))
				_ellipse(img2, cx, cy + 3, size * 0.17, size * 0.2, c)
				_ellipse(img2, cx - 2, cy - 1, 2, 2, Color(1, 1, 1, 0.5))
		"arma":
			var wid = it.get("arma", "sword")
			var eq = preload("res://scripts/autoload/equips.gd")
			eq.draw_weapon(img2, wid, int(size * 0.2), 4, 0, false)
	return ImageTexture.create_from_image(img2)

static func _ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, c: Color) -> void:
	for j in range(int(cy - ry) - 1, int(cy + ry) + 2):
		for i in range(int(cx - rx) - 1, int(cx + rx) + 2):
			if i < 0 or j < 0 or i >= img.get_width() or j >= img.get_height():
				continue
			var dx = (i - cx) / max(rx, 0.1)
			var dy = (j - cy) / max(ry, 0.1)
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(i, j, c)

static func _rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for j in range(h):
		for i in range(w):
			var px = x + i
			var py = y + j
			if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
				img.set_pixel(px, py, c)

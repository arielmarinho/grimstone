class_name Equips
extends Object
## Sistema de armas estilo Rucoy: a ARMA define a classe/estilo de combate.

const WEAPONS = {
	"sword": {
		"nome": "Espada", "classe": "Guerreiro",
		"cor": Color(0.78, 0.8, 0.84), "cor_cabo": Color(0.35, 0.24, 0.14),
		"dano": 15, "alcance": 260.0, "cooldown": 0.8, "skill": "espada",
		"tipo": "melee",
	},
	"axe": {
		"nome": "Machado", "classe": "Barbaro",
		"cor": Color(0.72, 0.74, 0.78), "cor_cabo": Color(0.4, 0.28, 0.16),
		"dano": 22, "alcance": 255.0, "cooldown": 1.3, "skill": "machado",
		"tipo": "melee",
	},
	"bow": {
		"nome": "Arco", "classe": "Arqueiro",
		"cor": Color(0.5, 0.36, 0.2), "cor_cabo": Color(0.85, 0.82, 0.75),
		"dano": 14, "alcance": 260.0, "cooldown": 0.8, "skill": "distancia",
		"tipo": "ranged",
	},
	"staff": {
		"nome": "Cajado", "classe": "Mago",
		"cor": Color(0.45, 0.32, 0.18), "cor_orb": Color(0.3, 0.55, 0.95),
		"dano": 19, "alcance": 220.0, "cooldown": 1.1, "skill": "magia",
		"tipo": "magic",
	},
}

const CLOTHES_COLORS = {
	"dourado": Color(0.86, 0.75, 0.39),
	"ruivo": Color(0.75, 0.31, 0.16),
	"preto": Color(0.12, 0.12, 0.14),
	"castanho_claro": Color(0.59, 0.41, 0.24),
	"branco": Color(0.78, 0.78, 0.8),
}

const PANTS_COLORS = {
	"marrom": Color(0.28, 0.23, 0.19),
	"preto": Color(0.15, 0.15, 0.17),
	"azul": Color(0.2, 0.3, 0.55),
	"verde": Color(0.22, 0.4, 0.24),
	"vermelho": Color(0.6, 0.2, 0.2),
	"cinza": Color(0.45, 0.45, 0.48),
}

static func draw_weapon(img: Image, weapon: String, cx: int, sy: int, f: int, is_attack: bool) -> void:
	var w = WEAPONS[weapon]
	match weapon:
		"sword":
			var steel: Color = w["cor"]
			var steel_l: Color = Color(0.9, 0.91, 0.94)
			if is_attack and f >= 2:
				_draw_blade(img, cx - 2, sy + 8, 22, 3, steel)
				_draw_blade(img, cx - 6, sy + 5, 8, 8, Color(0.95, 0.95, 1.0, 0.45))
			else:
				for i in range(18):
					var wdt = 3.0 - i * 0.12
					_draw_blade(img, cx + 4 - wdt / 2, sy + i, int(wdt) + 1, 1, steel if i % 3 != 0 else steel_l)
				_draw_blade(img, cx - 1, sy + 17, 10, 3, Color(0.55, 0.42, 0.2))
				_draw_circle(img, cx + 4, sy + 21, 1.8, w["cor_cabo"])
		"axe":
			var steel: Color = w["cor"]
			if is_attack and f >= 2:
				_draw_blade(img, cx - 2, sy + 6, 22, 3, steel)
				_draw_circle(img, cx + 12, sy + 7, 4, Color(0.95, 0.95, 1.0, 0.4))
			else:
				_draw_blade(img, cx + 3, sy - 2, 3, 24, w["cor_cabo"])
				_draw_ellipse(img, cx + 9, sy + 2, 6, 7, steel)
				_draw_ellipse(img, cx + 10.5, sy + 2, 3.5, 5, Color(0.88, 0.9, 0.93))
		"bow":
			var wood: Color = w["cor"]
			var string_c: Color = w["cor_cabo"]
			for i in range(14):
				var ang = -1.2 + i * (2.4 / 13)
				var bx = cx + 6 + cos(ang) * 4
				var by = sy + 10 + sin(ang) * 11
				_draw_circle(img, bx, by, 1.6, wood)
			_draw_blade(img, cx + 10, sy - 1, 1, 22, string_c)
			if is_attack and f >= 2:
				_draw_blade(img, cx + 10, sy + 9, 14, 2, Color(0.9, 0.85, 0.7))
				_draw_blade(img, cx + 22, sy + 8, 3, 4, Color(0.85, 0.85, 0.85))
		"staff":
			var wood: Color = w["cor"]
			var orb: Color = w["cor_orb"]
			_draw_blade(img, cx + 3, sy - 2, 3, 26, wood)
			var orb_c := orb
			if is_attack and f >= 2:
				orb_c = Color(0.75, 0.9, 1.0)
			_draw_circle(img, cx + 4.5, sy - 5, 3.5, orb_c)
			_draw_circle(img, cx + 3.5, sy - 6, 1.2, Color(1, 1, 1, 0.8))
			if is_attack and f >= 2:
				_draw_circle(img, cx + 16, sy + 8, 4, Color(0.95, 0.6, 0.2))
				_draw_circle(img, cx + 18, sy + 8, 2.2, Color(0.98, 0.85, 0.4))

static func _draw_blade(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for j in range(h):
		for i in range(w):
			var px = x + i
			var py = y + j
			if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
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

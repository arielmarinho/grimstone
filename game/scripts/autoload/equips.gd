class_name Equips
extends Object
## Sistema de armas estilo Rucoy: a ARMA define a classe/estilo de combate.

const WEAPONS = {
	"sword": {
		"nome": "Espada", "classe": "Guerreiro",
		"cor": Color(0.78, 0.8, 0.84), "cor_cabo": Color(0.35, 0.24, 0.14),
		"dano": 15, "alcance": 60.0, "cooldown": 0.8, "skill": "espada",
		"tipo": "melee",
	},
	"axe": {
		"nome": "Machado", "classe": "Barbaro",
		"cor": Color(0.72, 0.74, 0.78), "cor_cabo": Color(0.4, 0.28, 0.16),
		"dano": 22, "alcance": 55.0, "cooldown": 1.3, "skill": "machado",
		"tipo": "melee",
	},
	"bow": {
		"nome": "Arco", "classe": "Arqueiro",
		"cor": Color(0.5, 0.36, 0.2), "cor_cabo": Color(0.85, 0.82, 0.75),
		"dano": 10, "alcance": 260.0, "cooldown": 0.9, "skill": "distancia",
		"tipo": "ranged",
	},
	"staff": {
		"nome": "Cajado", "classe": "Mago",
		"cor": Color(0.45, 0.32, 0.18), "cor_orb": Color(0.3, 0.55, 0.95),
		"dano": 18, "alcance": 220.0, "cooldown": 1.1, "skill": "magia",
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

static func draw_weapon(img: Image, weapon: String, cx: int, sy: int, f: int, is_attack: bool) -> void:
	var w = WEAPONS[weapon]
	match weapon:
		"sword":
			var steel: Color = w["cor"]
			if is_attack and f >= 2:
				_draw_blade(img, cx + 10, sy + 4, 14, 4, steel)
				_draw_blade(img, cx + 6, sy + 2, 6, 8, Color(0.9, 0.92, 0.95, 0.6))
			else:
				_draw_blade(img, cx + 14, sy, 4, 22, steel)
			_draw_blade(img, cx + 13, sy + 20, 6, 3, w["cor_cabo"])
		"axe":
			var steel: Color = w["cor"]
			if is_attack and f >= 2:
				_draw_blade(img, cx + 10, sy + 2, 14, 4, steel)
			else:
				_draw_blade(img, cx + 15, sy, 4, 22, w["cor_cabo"])
				_draw_blade(img, cx + 13, sy - 2, 10, 10, steel)
				_draw_blade(img, cx + 15, sy - 2, 6, 10, Color(0.85, 0.87, 0.9))
		"bow":
			var wood: Color = w["cor"]
			var string_c: Color = w["cor_cabo"]
			for i in range(10):
				var off = abs(i - 5)
				_draw_blade(img, cx + 16 + off / 2, sy + i * 2, 3, 2, wood)
			_draw_blade(img, cx + 21, sy, 1, 20, string_c)
			if is_attack and f >= 2:
				_draw_blade(img, cx + 22, sy + 8, 12, 2, Color(0.9, 0.85, 0.7))
		"staff":
			var wood: Color = w["cor"]
			var orb: Color = w["cor_orb"]
			_draw_blade(img, cx + 15, sy, 4, 24, wood)
			var orb_c := orb
			if is_attack and f >= 2:
				orb_c = Color(0.7, 0.85, 1.0)
			_draw_blade(img, cx + 14, sy - 6, 6, 6, orb_c)
			if is_attack and f >= 2:
				_draw_blade(img, cx + 24, sy + 2, 8, 8, Color(0.95, 0.6, 0.2))

static func _draw_blade(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for j in range(h):
		for i in range(w):
			var px = x + i
			var py = y + j
			if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
				img.set_pixel(px, py, c)

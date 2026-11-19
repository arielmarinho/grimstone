class_name Equips
extends Object
## Sistema de armas estilo Rucoy: a ARMA define a classe/estilo de combate.

const WEAPONS = {
	"druid_staff": {
		"nome": "Cajado Druidico", "classe": "Druida",
		"cor": Color(0.34, 0.42, 0.18), "cor_orb": Color(0.35, 0.88, 0.22),
		"dano": 17, "alcance": 220.0, "cooldown": 1.0, "skill": "magia",
		"tipo": "magic",
	},
	"spear": {
		"nome": "Lanca", "classe": "Paladino",
		"cor": Color(0.72, 0.74, 0.78), "cor_cabo": Color(0.42, 0.27, 0.15),
		"dano": 15, "alcance": 280.0, "cooldown": 0.9, "skill": "espada",
		"tipo": "melee",
	},
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

# Paleta de customização (cabelo + túnica) — cores extraídas das referências
# do usuário (knight castanho/preto/branco + túnica vermelha)
# ESCALA DO SPRITE POR CLASSE — MEDIDA nos PNGs do repo, nao presumida.
# Altura do CORPO e linha dos PES dentro da celula 96x96 (mediana de idle+walk,
# medido por scripts/222ef96c095afc0b/measure_art.py):
#   knight 86.0px / pes 88.0   paladino 56.0 / 84.0
#   mago   55.5px / pes 88.5   druida   55.0 / 87.0
# Com sprite.scale fixo em 1.15 as classes novas apareciam 33-36% MENORES que
# o knight na tela. Fator = 86 / altura_classe, aplicado sobre o 1.15 do knight.
# Nenhum PNG e alterado (a arte do usuario fica intacta, o ajuste e em runtime).
const KNIGHT_SPRITE_SCALE := 1.15
const KNIGHT_BODY_H := 86.0
const KNIGHT_BODY_BOTTOM := 88.0
const CLASS_BODY_H := {"paladin": 56.0, "mage": 55.5, "druid": 55.0}
const CLASS_BODY_BOTTOM := {"paladin": 84.0, "mage": 88.5, "druid": 87.0}
const CELL_CENTER := 48.0

## Diretorio da classe no pacote de sprites para uma arma base.
static func class_dir_for(weapon_base: String) -> String:
	match weapon_base:
		"spear":
			return "paladin"
		"staff":
			return "mage"
		"druid_staff":
			return "druid"
	return "knight"

## Escala que iguala a ALTURA do corpo a do knight.
static func sprite_scale_for(weapon_base: String) -> float:
	if not CLASS_BODY_H.has(class_dir_for(weapon_base)):
		return KNIGHT_SPRITE_SCALE
	return KNIGHT_SPRITE_SCALE * (KNIGHT_BODY_H / float(CLASS_BODY_H[class_dir_for(weapon_base)]))

## Deslocamento vertical (em pixels de TEXTURA) para os PES ficarem no mesmo Y
## do knight. Sem isto o sprite cresce em torno do CENTRO da celula e o
## personagem AFUNDA no chao: 18px (paladino), 26px (mago), 24px (druida) —
## medido. `AnimatedSprite2D.offset` e multiplicado pela escala do node, por
## isso a divisao final por `sc`.
static func sprite_offset_y_for(weapon_base: String) -> float:
	var cls := class_dir_for(weapon_base)
	var sc := sprite_scale_for(weapon_base)
	if sc <= 0.0:
		return 0.0
	var feet_knight: float = (KNIGHT_BODY_BOTTOM - CELL_CENTER) * KNIGHT_SPRITE_SCALE
	var bottom: float = float(CLASS_BODY_BOTTOM.get(cls, KNIGHT_BODY_BOTTOM))
	var feet_class: float = (bottom - CELL_CENTER) * sc
	var delta: float = feet_knight - feet_class
	if absf(delta) < 0.5:
		return 0.0
	return delta / sc

const CLOTHES_COLORS = {
	"castanho": Color(0.53, 0.28, 0.15),
	"dourado": Color(0.86, 0.75, 0.39),
	"ruivo": Color(0.75, 0.31, 0.16),
	"preto": Color(0.12, 0.12, 0.14),
	"castanho_claro": Color(0.59, 0.41, 0.24),
	"branco": Color(0.78, 0.78, 0.8),
	"vermelho": Color(0.67, 0.08, 0.08),
	"azul": Color(0.25, 0.4, 0.7),
	"verde": Color(0.3, 0.55, 0.3),
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
		"spear":
			_draw_blade(img, cx + 3, sy - 2, 3, 24, Color(0.42, 0.27, 0.15))
			_draw_blade(img, cx, sy - 5, 9, 6, Color(0.72, 0.74, 0.78))
			_draw_blade(img, cx + 2, sy - 7, 5, 3, Color(0.9, 0.91, 0.94))
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
		"druid_staff":
			_draw_blade(img, cx + 3, sy - 2, 3, 26, w["cor"])
			_draw_circle(img, cx + 4.5, sy - 5, 4.0, w["cor_orb"])
			_draw_circle(img, cx + 3.5, sy - 6, 1.2, Color(0.85, 1.0, 0.68))
			if is_attack and f >= 2:
				_draw_circle(img, cx + 17, sy + 8, 4, Color(0.4, 0.9, 0.25))
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

extends Node2D
## Sprites procedurais dos monstros (slime, morcego, aranha, lobo, goblin, orc, esqueleto)

static func draw_mob(img: Image, type: String, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	match type:
		"dummy":
			_draw_dummy(img, f, is_attack, is_death, is_walk)
		"slime":
			_draw_slime(img, f, is_attack, is_death, is_walk)
		"bat":
			_draw_bat(img, f, is_attack, is_death, is_walk)
		"spider":
			_draw_spider(img, f, is_attack, is_death, is_walk)
		"wolf":
			_draw_wolf(img, f, is_attack, is_death, is_walk)
		"goblin":
			_draw_goblin(img, f, is_attack, is_death, is_walk)
		"orc":
			_draw_orc(img, f, is_attack, is_death, is_walk)
		"skeleton":
			_draw_skeleton(img, f, is_attack, is_death, is_walk)

# ---------- DUMMY DE TREINO (boneco de madeira, imortal) ----------
static func _draw_dummy(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 48
	var wood := Color(0.62, 0.44, 0.26)
	var wood_d := Color(0.45, 0.31, 0.18)
	var straw := Color(0.85, 0.72, 0.35)
	# sombra
	_ell(img, cx, 92, 16, 3.5, Color(0, 0, 0, 0.25))
	# base (tripe de madeira)
	_rect(img, cx - 12, 86, 24, 5, wood_d)
	_rect(img, cx - 2, 60, 4, 28, wood_d)
	# corpo (tronco de madeira)
	_rect(img, cx - 9, 38, 18, 48, wood)
	_rect(img, cx - 9, 38, 4, 48, wood_d)
	# faixas que seguram o tronco
	_rect(img, cx - 11, 48, 22, 4, wood_d)
	_rect(img, cx - 11, 70, 22, 4, wood_d)
	# cabeca de palha
	_circ(img, cx, 30, 9, straw)
	_circ(img, cx - 3, 28, 1.6, Color(0.2, 0.15, 0.05))
	_circ(img, cx + 3, 28, 1.6, Color(0.2, 0.15, 0.05))
	# balanco leve no idle (f)
	if not is_attack and not is_death and f % 2 == 1:
		_rect(img, cx + 9, 40, 2, 44, wood_d)

# ---------- SLIME (verde gelatinoso, pulsa) ----------
static func _draw_slime(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 48
	var body := Color(0.3, 0.75, 0.4)
	var body_d := Color(0.2, 0.55, 0.3)
	var shine := Color(0.6, 0.95, 0.7)
	if is_death:
		_ell(img, cx, 86, 20, 4, body_d)
		_ell(img, cx, 86, 14, 2.5, body)
		return
	var squash: float = [0.0, 2.0, 0.0, -2.0][f]
	var ry := 12.0 + squash
	var rx := 15.0 - squash * 0.5
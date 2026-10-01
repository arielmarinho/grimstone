extends Node2D
## Sprites procedurais dos monstros (slime, morcego, aranha, lobo, goblin, orc, esqueleto)

static func draw_mob(img: Image, type: String, f: int, is_attack: bool, is_death: bool, is_walk: bool, dir: String = "down") -> void:
	match type:
		"rat":
			_draw_rat(img, f, is_attack, is_death, is_walk, dir)
		"dummy":
			_draw_dummy(img, f, is_attack, is_death, is_walk)
		"slime":
			_draw_slime(img, f, is_attack, is_death, is_walk, dir)
		"bat":
			_draw_bat(img, f, is_attack, is_death, is_walk, dir)
		"spider":
			_draw_spider(img, f, is_attack, is_death, is_walk, dir)
		"wolf":
			_draw_wolf(img, f, is_attack, is_death, is_walk, dir)
		"goblin":
			_draw_goblin(img, f, is_attack, is_death, is_walk, dir)
		"orc":
			_draw_orc(img, f, is_attack, is_death, is_walk, dir)
		"skeleton":
			_draw_skeleton(img, f, is_attack, is_death, is_walk, dir)

# ---------- RATO (marrom, orelhas rosa, cauda longa) — procedural, 3 direcoes ----------
static func _draw_rat(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool, dir: String = "down") -> void:
	var cx := 48
	var fur := Color(0.55, 0.42, 0.3)
	var fur_d := Color(0.42, 0.31, 0.22)
	var belly := Color(0.75, 0.65, 0.52)
	var ear := Color(0.85, 0.6, 0.65)
	var eye := Color(0.9, 0.15, 0.15)
	var tail := Color(0.8, 0.55, 0.55)
	if is_death:
		# deitado de lado, patas pra cima
		_ell(img, cx, 86, 18, 5, fur)
		_ell(img, cx, 82, 14, 4, belly)
		_ell(img, cx - 20, 84, 7, 2.5, tail)
		_ell(img, cx + 16, 82, 4, 5, fur_d)
		_circ(img, cx + 18, 78, 2.5, ear)
		_circ(img, cx + 17, 81, 1.2, eye)
		return
	var bob: int = [0, 1, 0, 1][f]
	var step: int = [3, 0, -3, 0][f] if is_walk else 0
	_ell(img, cx, 88, 16, 3, Color(0, 0, 0, 0.25))
	# cauda (curva pra tras)
	_ell(img, cx - 22, 80 - bob, 9, 2.5, tail)
	_ell(img, cx - 28, 76 - bob, 5, 2, tail)
	if dir == "up":
		# visto de tras: corpo + costas, sem rosto, orelhas de costas
		_ell(img, cx, 78 + bob, 15, 9, fur)
		_ell(img, cx, 82 + bob, 10, 5, fur_d)
		_ell(img, cx - 8, 84 + step, 3, 4, fur_d)
		_ell(img, cx + 8, 84 - step, 3, 4, fur_d)
		_circ(img, cx - 6, 68 + bob, 4, fur)
		_circ(img, cx + 6, 68 + bob, 4, fur)
		_circ(img, cx - 6, 68 + bob, 2, ear)
		_circ(img, cx + 6, 68 + bob, 2, ear)
		if is_attack and f >= 2:
			_ell(img, cx, 70 + bob, 5, 3, fur_d)
		return
	# frente (down) e perfil (side)
	_ell(img, cx, 78 + bob, 15, 9, fur)
	_ell(img, cx, 82 + bob, 10, 5, belly)
	# patas
	_ell(img, cx - 8, 84 + step, 3, 4, fur_d)
	_ell(img, cx + 8, 84 - step, 3, 4, fur_d)
	# cabeca
	var hy := 68 + bob
	if dir == "side":
		# perfil: focinho apontado pra direita (flip_h cobre esquerda)
		_circ(img, cx + 4, hy, 7, fur)
		_ell(img, cx + 12, hy + 2, 5, 3, fur)
		_circ(img, cx + 17, hy + 2, 1.2, Color(0.15, 0.1, 0.1))
		_circ(img, cx + 2, hy - 6, 3.5, fur)
		_circ(img, cx + 2, hy - 6, 2, ear)
		_circ(img, cx + 6, hy - 1, 1.5, eye)
		_tri(img, cx + 14, hy + 4, 3, 2, Color(0.95, 0.93, 0.85))
		if is_attack and f >= 2:
			_tri(img, cx + 18, hy + 5, 4, 3, Color(0.95, 0.95, 0.9))
	else:
		# frente: orelhas redondas + olhos vermelhos + dentes
		_circ(img, cx - 6, hy - 6, 4, fur)
		_circ(img, cx + 6, hy - 6, 4, fur)
		_circ(img, cx - 6, hy - 6, 2, ear)
		_circ(img, cx + 6, hy - 6, 2, ear)
		_circ(img, cx, hy, 7, fur)
		_circ(img, cx - 3, hy - 1, 1.5, eye)
		_circ(img, cx + 3, hy - 1, 1.5, eye)
		_circ(img, cx - 2.5, hy - 1.5, 0.5, Color(1, 0.9, 0.9))
		_circ(img, cx + 3.5, hy - 1.5, 0.5, Color(1, 0.9, 0.9))
		_ell(img, cx, hy + 4, 3, 2, Color(0.7, 0.5, 0.5))
		_rect(img, cx - 2, hy + 5, 1.5, 2, Color(0.95, 0.93, 0.85))
		_rect(img, cx + 1, hy + 5, 1.5, 2, Color(0.95, 0.93, 0.85))
		if is_attack and f >= 2:
			_tri(img, cx - 2, hy + 6, 3, 3, Color(0.95, 0.95, 0.9))
			_tri(img, cx + 2, hy + 6, 3, 3, Color(0.95, 0.95, 0.9))

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
static func _draw_slime(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool, dir: String = "down") -> void:
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
	_ell(img, cx, 86, rx + 2, 3, Color(0, 0, 0, 0.25))
	_ell(img, cx, 76 - squash, rx, ry, body)
	_ell(img, cx - 3, 74 - squash, rx * 0.6, ry * 0.6, body_d)
	_ell(img, cx - 5, 68 - squash, 4, 3, shine)
	if dir != "up":
		_circ(img, cx - 5, 72 - squash, 2.2, Color(0.1, 0.15, 0.1))
		_circ(img, cx + 5, 72 - squash, 2.2, Color(0.1, 0.15, 0.1))
		_circ(img, cx - 4.5, 71.5 - squash, 0.8, Color(0.9, 1, 0.9))
		_circ(img, cx + 5.5, 71.5 - squash, 0.8, Color(0.9, 1, 0.9))
	if is_attack and f >= 2:
		_ell(img, cx, 79 - squash, 4, 2.5, Color(0.15, 0.3, 0.15))

# ---------- MORCEGO (roxo, asas batendo) ----------
static func _draw_bat(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool, dir: String = "down") -> void:
	var cx := 48
	var fur := Color(0.45, 0.3, 0.55)
	var wing := Color(0.35, 0.22, 0.45)
	var eye := Color(1.0, 0.85, 0.2)
	if is_death:
		_ell(img, cx, 86, 14, 4, fur)
		_ell(img, cx - 12, 84, 8, 3, wing)
		_ell(img, cx + 12, 84, 8, 3, wing)
		return
	var fly: int = [0, -3, -5, -3][f]
	var wing_up: bool = f % 2 == 0
	var wy := -6.0 if wing_up else 2.0
	_ell(img, cx, 60 + fly, 9, 7, fur)
	_ell(img, cx - 16, 56 + fly + wy * 0.5, 10, 5, wing)
	_ell(img, cx - 24, 52 + fly + wy, 8, 4, wing)
	_ell(img, cx + 16, 56 + fly + wy * 0.5, 10, 5, wing)
	_ell(img, cx + 24, 52 + fly + wy, 8, 4, wing)
	_tri(img, cx - 5, 50 + fly, 4, 6, fur)
	_tri(img, cx + 5, 50 + fly, 4, 6, fur)
	if dir != "up":
		_circ(img, cx - 3, 58 + fly, 1.8, eye)
		_circ(img, cx + 3, 58 + fly, 1.8, eye)
	if is_attack and f >= 2:
		_rect(img, cx - 4, 63 + fly, 2, 3, Color(0.95, 0.95, 0.9))
		_rect(img, cx + 2, 63 + fly, 2, 3, Color(0.95, 0.95, 0.9))

# ---------- ARANHA (preta, 8 patas) ----------
static func _draw_spider(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool, dir: String = "down") -> void:
	var cx := 48
	var body := Color(0.15, 0.12, 0.18)
	var body_d := Color(0.1, 0.08, 0.12)
	var eye := Color(0.9, 0.2, 0.2)
	if is_death:
		_ell(img, cx, 84, 16, 5, body)
		for i in range(4):
			_ell(img, cx - 20 + i * 4, 82 + (i % 2) * 3, 6, 1.5, body_d)
		return
	var step: int = [2, 0, -2, 0][f] if is_walk else 0
	_ell(img, cx, 86, 18, 3, Color(0, 0, 0, 0.25))
	for i in range(4):
		var ly := 68 + i * 6
		var off := step if i % 2 == 0 else -step
		_ell(img, cx - 18 + off, ly, 8, 2, body_d)
		_ell(img, cx + 18 - off, ly, 8, 2, body_d)
	_ell(img, cx, 78, 12, 9, body)
	_ell(img, cx, 80, 8, 5, body_d)
	_circ(img, cx, 76, 2.5, Color(0.8, 0.15, 0.15))
	_ell(img, cx, 66, 7, 6, body)
	if dir != "up":
		for i in range(3):
			_circ(img, cx - 4 + i * 4, 62, 1.3, eye)
	if is_attack and f >= 2:
		_tri(img, cx - 4, 70, 3, 5, Color(0.9, 0.9, 0.85))
		_tri(img, cx + 4, 70, 3, 5, Color(0.9, 0.9, 0.85))

# ---------- LOBO (cinza, orelhas em pe, cauda) ----------
static func _draw_wolf(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool, dir: String = "down") -> void:
	var cx := 44
	var fur := Color(0.45, 0.45, 0.48)
	var fur_d := Color(0.32, 0.32, 0.36)
	var belly := Color(0.65, 0.65, 0.68)
	var eye := Color(0.95, 0.75, 0.2)
	if is_death:
		_ell(img, cx, 86, 20, 5, fur)
		_circ(img, cx + 22, 84, 6, fur)
		_tri(img, cx + 20, 80, 4, 5, fur_d)
		return
	var bob: int = [0, 1, 0, 1][f]
	var step: int = [3, 0, -3, 0][f] if is_walk else 0
	_ell(img, cx, 88, 20, 3.5, Color(0, 0, 0, 0.25))
	_ell(img, cx - 26, 72 - bob * 2, 8, 3, fur_d)
	_ell(img, cx - 32, 68 - bob * 3, 5, 2.5, fur)
	_ell(img, cx, 74 + bob, 19, 10, fur)
	_ell(img, cx - 2, 78 + bob, 13, 5, belly)
	_ell(img, cx - 10, 84 + step, 3, 4, fur_d)
	_ell(img, cx + 2, 84 - step, 3, 4, fur_d)
	_ell(img, cx + 10, 84 + step, 3, 4, fur_d)
	_circ(img, cx + 20, 62 + bob, 8, fur)
	_ell(img, cx + 28, 65 + bob, 6, 3.5, fur_d)
	_circ(img, cx + 33, 64 + bob, 1.5, Color(0.2, 0.2, 0.2))
	_tri(img, cx + 16, 52 + bob, 4, 7, fur)
	_tri(img, cx + 23, 52 + bob, 4, 7, fur)
	if dir != "up":
		_circ(img, cx + 21, 60 + bob, 1.8, eye)
	if is_attack and f >= 2:
		_rect(img, cx + 27, 68 + bob, 2, 3, Color(0.95, 0.95, 0.9))
		_rect(img, cx + 30, 68 + bob, 2, 3, Color(0.95, 0.95, 0.9))

# ---------- GOBLIN (pele verde, orelhas grandes, adaga) ----------
static func _draw_goblin(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool, dir: String = "down") -> void:
	var cx := 48
	var skin := Color(0.35, 0.6, 0.3)
	var skin_d := Color(0.25, 0.45, 0.22)
	var cloth := Color(0.45, 0.35, 0.2)
	var eye := Color(0.95, 0.8, 0.2)
	if is_death:
		_ell(img, cx, 86, 16, 5, cloth)
		_circ(img, cx - 14, 84, 6, skin)
		_ell(img, cx - 20, 80, 5, 2.5, skin)
		return
	var bob: int = [0, 1, 0, 1][f]
	var step: int = [3, 0, -3, 0][f] if is_walk else 0
	_ell(img, cx, 88, 11, 3, Color(0, 0, 0, 0.25))
	# pernas
	_ell(img, cx - 4, 78 + step, 3, 6, skin_d)
	_ell(img, cx + 4, 78 - step, 3, 6, skin_d)
	# tunica rasgada
	_ell(img, cx, 62 + bob, 10, 11, cloth)
	_ell(img, cx + 3, 66 + bob, 6, 7, cloth.darkened(0.2))
	# cabeca grande com orelhas pontudas
	_circ(img, cx, 40 + bob, 8, skin)
	_tri(img, cx - 12, 36 + bob, 8, 4, skin)
	_tri(img, cx + 4, 36 + bob, 8, 4, skin)
	if dir != "up":
		_circ(img, cx - 3, 40 + bob, 1.5, eye)
		_circ(img, cx + 3, 40 + bob, 1.5, eye)
		_circ(img, cx - 2.5, 39.5 + bob, 0.5, Color(1, 1, 0.7))
		_circ(img, cx + 3.5, 39.5 + bob, 0.5, Color(1, 1, 0.7))
		# boca com dentes
		_rect(img, cx - 3, 45 + bob, 6, 2, Color(0.3, 0.15, 0.15))
		_rect(img, cx - 2, 45 + bob, 1, 1, Color(0.95, 0.95, 0.9))
		_rect(img, cx + 1, 45 + bob, 1, 1, Color(0.95, 0.95, 0.9))
	# adaga na mao
	var reach := 8
	if is_attack and f >= 2:
		reach = 16
		_tri(img, cx + 14 + reach, 56 + bob, 6, 3, Color(0.9, 0.9, 0.95))
	_rect(img, cx + 10, 55 + bob, reach, 2, Color(0.8, 0.82, 0.86))
	_rect(img, cx + 8, 54 + bob, 3, 4, Color(0.4, 0.28, 0.16))

# ---------- ORC (grande, verde escuro, presas, machado) ----------
static func _draw_orc(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool, dir: String = "down") -> void:
	var cx := 48
	var skin := Color(0.3, 0.45, 0.28)
	var skin_d := Color(0.22, 0.34, 0.2)
	var armor := Color(0.35, 0.3, 0.26)
	var eye := Color(0.9, 0.25, 0.15)
	if is_death:
		_ell(img, cx, 84, 20, 6, armor)
		_circ(img, cx - 18, 82, 7, skin)
		_ell(img, cx + 16, 86, 8, 3, skin_d)
		return
	var bob: int = [0, 1, 0, 1][f]
	var step: int = [3, 0, -3, 0][f] if is_walk else 0
	_ell(img, cx, 90, 14, 3.5, Color(0, 0, 0, 0.25))
	# pernas grossas
	_ell(img, cx - 6, 76 + step, 4.5, 8, skin_d)
	_ell(img, cx + 6, 76 - step, 4.5, 8, skin_d)
	_ell(img, cx - 6, 85 + step, 5, 3, Color(0.3, 0.22, 0.14))
	_ell(img, cx + 6, 85 - step, 5, 3, Color(0.3, 0.22, 0.14))
	# tronco largo com peitoral
	_ell(img, cx, 56 + bob, 15, 14, skin)
	_ell(img, cx, 60 + bob, 11, 9, skin_d)
	_ell(img, cx, 54 + bob, 13, 8, armor)
	# cabeca com presas
	_circ(img, cx, 34 + bob, 9.5, skin)
	if dir != "up":
		_ell(img, cx - 4, 40 + bob, 2, 3, Color(0.95, 0.93, 0.85))
		_ell(img, cx + 4, 40 + bob, 2, 3, Color(0.95, 0.93, 0.85))
		_circ(img, cx - 3.5, 33 + bob, 1.8, eye)
		_circ(img, cx + 3.5, 33 + bob, 1.8, eye)
	# machado grande
	var steel := Color(0.72, 0.74, 0.78)
	_rect(img, cx + 14, 40 + bob, 3, 34, Color(0.4, 0.28, 0.16))
	_ell(img, cx + 20, 42 + bob, 7, 9, steel)
	_ell(img, cx + 22, 42 + bob, 4, 6, Color(0.88, 0.9, 0.93))
	if is_attack and f >= 2:
		_ell(img, cx + 26, 48 + bob, 6, 6, Color(0.95, 0.95, 1.0, 0.4))

# ---------- ESQUELETO (ossos brancos, espada, olhos vazios) ----------
static func _draw_skeleton(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool, dir: String = "down") -> void:
	var cx := 48
	var bone := Color(0.88, 0.86, 0.78)
	var bone_d := Color(0.7, 0.68, 0.6)
	var eye := Color(0.1, 0.08, 0.08)
	if is_death:
		_ell(img, cx, 86, 14, 3, bone_d)
		_circ(img, cx - 16, 84, 6, bone)
		_ell(img, cx - 16, 82, 5, 2, Color(0.2, 0.15, 0.1))
		for i in range(3):
			_rect(img, cx + 2 + i * 6, 84, 4, 2, bone)
		return
	var bob: int = [0, 1, 0, 1][f]
	var step: int = [3, 0, -3, 0][f] if is_walk else 0
	_ell(img, cx, 88, 11, 3, Color(0, 0, 0, 0.25))
	# pernas osso
	_rect(img, cx - 5, 68 + step, 3, 14, bone)
	_rect(img, cx + 2, 68 - step, 3, 14, bone)
	_circ(img, cx - 3.5, 82 + step, 2.5, bone_d)
	_circ(img, cx + 3.5, 82 - step, 2.5, bone_d)
	# costelas
	_ell(img, cx, 56 + bob, 10, 10, Color(0, 0, 0, 0.0))
	for i in range(4):
		_rect(img, cx - 9, 50 + bob + i * 4, 18, 2, bone)
	_rect(img, cx - 1, 48 + bob, 2, 18, bone_d)
	# ombros
	_circ(img, cx - 10, 48 + bob, 3, bone)
	_circ(img, cx + 10, 48 + bob, 3, bone)
	# bracos
	_rect(img, cx - 13, 48 + bob, 2, 10, bone)
	_rect(img, cx + 12, 48 + bob, 2, 10, bone)
	# cabeca caveira
	_circ(img, cx, 36 + bob, 8, bone)
	_ell(img, cx, 40 + bob, 5, 3, bone)
	if dir != "up":
		_ell(img, cx - 3.5, 35 + bob, 2, 2.5, eye)
		_ell(img, cx + 3.5, 35 + bob, 2, 2.5, eye)
		_rect(img, cx - 3, 41 + bob, 6, 1.5, bone_d)
		for i in range(3):
			_rect(img, cx - 2 + i * 2, 41 + bob, 1, 1.5, Color(0.3, 0.28, 0.25))
	# espada
	var steel := Color(0.78, 0.8, 0.84)
	var reach := 6
	if is_attack and f >= 2:
		reach = 14
	_rect(img, cx + 15, 44 + bob, reach, 2.5, steel)
	_rect(img, cx + 13, 42 + bob, 3, 7, Color(0.55, 0.42, 0.2))

static func _ell(img: Image, cx: float, cy: float, rx: float, ry: float, c: Color) -> void:
	for j in range(int(cy - ry) - 1, int(cy + ry) + 2):
		for i in range(int(cx - rx) - 1, int(cx + rx) + 2):
			if i < 0 or j < 0 or i >= img.get_width() or j >= img.get_height():
				continue
			var dx = (i - cx) / max(rx, 0.1)
			var dy = (j - cy) / max(ry, 0.1)
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(i, j, c)

static func _circ(img: Image, cx: float, cy: float, r: float, c: Color) -> void:
	_ell(img, cx, cy, r, r, c)

static func _tri(img: Image, cx: float, cy: float, w: float, h: float, c: Color) -> void:
	for j in range(int(h)):
		var row_w = w * (1.0 - float(j) / h)
		for i in range(int(row_w) + 1):
			var px = int(cx - row_w / 2 + i)
			var py = int(cy + j)
			if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
				img.set_pixel(px, py, c)

static func _rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for j in range(int(h)):
		for i in range(int(w)):
			px = x + i
			py = y + j
			if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
				img.set_pixel(px, py, c)

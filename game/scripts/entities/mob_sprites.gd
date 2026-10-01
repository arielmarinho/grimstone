extends Node2D
## Sprites procedurais dos monstros novos (slime, morcego, aranha, lobo)

static func draw_mob(img: Image, type: String, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	match type:
		"slime":
			_draw_slime(img, f, is_attack, is_death, is_walk)
		"bat":
			_draw_bat(img, f, is_attack, is_death, is_walk)
		"spider":
			_draw_spider(img, f, is_attack, is_death, is_walk)
		"wolf":
			_draw_wolf(img, f, is_attack, is_death, is_walk)

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
	_ell(img, cx, 86, rx + 2, 3, Color(0, 0, 0, 0.25))
	_ell(img, cx, 76 - squash, rx, ry, body)
	_ell(img, cx - 3, 74 - squash, rx * 0.6, ry * 0.6, body_d)
	_ell(img, cx - 5, 68 - squash, 4, 3, shine)
	_circ(img, cx - 5, 72 - squash, 2.2, Color(0.1, 0.15, 0.1))
	_circ(img, cx + 5, 72 - squash, 2.2, Color(0.1, 0.15, 0.1))
	_circ(img, cx - 4.5, 71.5 - squash, 0.8, Color(0.9, 1, 0.9))
	_circ(img, cx + 5.5, 71.5 - squash, 0.8, Color(0.9, 1, 0.9))
	if is_attack and f >= 2:
		_ell(img, cx, 79 - squash, 4, 2.5, Color(0.15, 0.3, 0.15))

# ---------- MORCEGO (roxo, asas batendo) ----------
static func _draw_bat(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
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
	_circ(img, cx - 3, 58 + fly, 1.8, eye)
	_circ(img, cx + 3, 58 + fly, 1.8, eye)
	if is_attack and f >= 2:
		_rect(img, cx - 4, 63 + fly, 2, 3, Color(0.95, 0.95, 0.9))
		_rect(img, cx + 2, 63 + fly, 2, 3, Color(0.95, 0.95, 0.9))

# ---------- ARANHA (preta, 8 patas, viuva negra) ----------
static func _draw_spider(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
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
	for i in range(3):
		_circ(img, cx - 4 + i * 4, 62, 1.3, eye)
	if is_attack and f >= 2:
		_tri(img, cx - 4, 70, 3, 5, Color(0.9, 0.9, 0.85))
		_tri(img, cx + 4, 70, 3, 5, Color(0.9, 0.9, 0.85))

# ---------- LOBO (cinza, orelhas em pe, cauda) ----------
static func _draw_wolf(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
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
	_circ(img, cx + 21, 60 + bob, 1.8, eye)
	if is_attack and f >= 2:
		_rect(img, cx + 27, 68 + bob, 2, 3, Color(0.95, 0.95, 0.9))
		_rect(img, cx + 30, 68 + bob, 2, 3, Color(0.95, 0.95, 0.9))

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
	for j in range(h):
		for i in range(w):
			var px = x + i
			var py = y + j
			if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
				img.set_pixel(px, py, c)

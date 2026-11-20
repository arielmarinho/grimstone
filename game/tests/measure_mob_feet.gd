extends SceneTree
## measure_mob_feet.gd — pe' de cada monstro por DIRECAO e QUADRO.
## Regua: linha dos pes do knight = 46px abaixo do centro do node (Equips.KNIGHT_FEET_SCREEN).
## Um pixel da arte em y aparece em (y - 48 + offset) * scale.
## Roda: godot --headless --path . -s res://tests/measure_mob_feet.gd

const CELL := 96
const MS := preload("res://scripts/entities/mob_sprites.gd")
const TYPES := ["rat", "slime", "bat", "spider", "wolf", "goblin", "orc", "skeleton", "dummy"]
const TARGET := 46.0


func _bottom_edge(img: Image) -> float:
	var m := -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.9:
				m = maxi(m, y)
				break
	return float(m + 1)


func _img(t: String, f: int, d: String, walk: bool, atk: bool) -> Image:
	var im := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	im.fill(Color(0, 0, 0, 0))
	MS.draw_mob(im, t, f, atk, false, walk, d)
	return im


func _run() -> void:
	for t in TYPES:
		var small: bool = t in ["rat", "slime", "bat"]
		var sc: float = 1.4 if small else 1.15
		var all: Array[float] = []
		for d in ["down", "up", "side"]:
			for f in range(4):
				all.append(_bottom_edge(_img(t, f, d, false, false)))
				all.append(_bottom_edge(_img(t, f, d, true, false)))
				all.append(_bottom_edge(_img(t, f, d, false, true)))
		all.sort()
		var lo: float = all[0]
		var hi: float = all[all.size() - 1]
		var med: float = all[all.size() / 2]
		# mediana minimiza o pior erro de um offset unico (1 numero por monstro)
		var off: float = TARGET / sc - (med - 48.0)
		var worst := 0.0
		for b in all:
			worst = maxf(worst, absf((b - 48.0 + off) * sc - TARGET))
		print("FEET|%s|scale=%.2f|arte=%.0f..%.0f|mediana=%.0f|offset=%.2f|pior_erro_tela=%.1f" % [
			t, sc, lo, hi, med, off, worst])
	print("MEASURE_MOB_FEET_DONE")
	quit()


func _initialize() -> void:
	_run()

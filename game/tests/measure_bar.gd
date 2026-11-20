extends SceneTree
## measure_bar.gd — barra de HP do mob vs altura real do corpo (depois do offset de pes v0.6.48)
## Roda: godot --headless --path . -s res://tests/measure_bar.gd

const CELL := 96
const MS := preload("res://scripts/entities/mob_sprites.gd")
const MOB := preload("res://scripts/entities/mob.gd")
const TYPES := ["rat", "slime", "bat", "spider", "wolf", "goblin", "orc", "skeleton", "dummy"]


func _top(img: Image) -> float:
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.9:
				return float(y)
	return float(img.get_height())


func _bottom(img: Image) -> float:
	var m := -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.9:
				m = maxi(m, y)
	return float(m + 1)


func _run() -> void:
	for t in TYPES:
		var small: bool = t in ["rat", "slime", "bat"]
		var sc: float = 1.4 if small else 1.15
		var off: float = float(MOB.MOB_FEET_OFFSET.get(t, 0.0))
		var top := 999.0
		var bot := 0.0
		for d in ["down", "up", "side"]:
			for f in range(4):
				for walk in [false, true]:
					for atk in [false, true]:
						var im := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
						im.fill(Color(0, 0, 0, 0))
						MS.draw_mob(im, t, f, atk, false, walk, d)
						top = minf(top, _top(im))
						bot = maxf(bot, _bottom(im))
		var top_scr: float = (top - 48.0 + off) * sc
		var bot_scr: float = (bot - 48.0 + off) * sc
		print("BAR|%s|top=%.1f|bottom=%.1f|bar=-44..-38|gap_to_head=%.1f" % [t, top_scr, bot_scr, -44.0 - top_scr])
	print("DONE")
	quit()


func _initialize() -> void:
	_run()

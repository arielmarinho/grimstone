extends SceneTree
## preview dos sprites direcionais dos mobs — salva folha PNG em /tmp/mobs_preview.png

const MOB_SPRITES = preload("res://scripts/entities/mob_sprites.gd")

func _init() -> void:
	var types = ["rat", "slime", "bat", "spider", "wolf", "goblin", "orc", "skeleton"]
	var dirs = ["down", "up", "side"]
	var cell := 96
	var cols := 3  # down/up/side
	var rows := types.size()
	var sheet := Image.create(cell * cols, cell * rows, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.16, 0.16, 0.18))
	for r in range(rows):
		for c in range(cols):
			var img = Image.create(cell, cell, false, Image.FORMAT_RGBA8)
			img.fill(Color(0, 0, 0, 0))
			MOB_SPRITES.draw_mob(img, types[r], 0, false, false, false, dirs[c])
			sheet.blend_rect(img, Rect2i(0, 0, cell, cell), Vector2i(c * cell, r * cell))
	var err = sheet.save_png("/tmp/mobs_preview.png")
	print("PREVIEW_SAVED err=", err, " rows=", rows)
	quit(0)

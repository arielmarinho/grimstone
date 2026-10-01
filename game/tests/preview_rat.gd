extends SceneTree
func _init():
	var MS = load("res://scripts/entities/mob_sprites.gd")
	var W = 96 * 4
	var H = 96 * 3
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.25, 0.45, 0.2))
	var dirs = ["down", "up", "side"]
	for d in range(dirs.size()):
		for f in range(4):
			var sub = Image.create(96, 96, false, Image.FORMAT_RGBA8)
			MS.draw_mob(sub, "rat", f, false, false, true, dirs[d])
			img.blit_rect(sub, Rect2i(0, 0, 96, 96), Vector2i(f * 96, d * 96))
	img.resize(W * 2, H * 2, Image.INTERPOLATE_NEAREST)
	img.save_png("/home/ethos/.assistant/workspace/artifacts/rat_new_preview.png")
	print("RAT_PREVIEW_OK")
	quit()

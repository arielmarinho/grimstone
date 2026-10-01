extends SceneTree
func _init():
	# preview: down=arte real, up=arte real editada (costas), side=arte real
	var TH = load("res://scripts/autoload/tex_helper.gd")
	var anims = {
		"idle_down": "res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png",
		"idle_up": "res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png",
		"idle_side": "res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png",
		"walk_down": "res://assets/sprites/animation/player/knight/walk/down/knight_walk_down_base.png",
		"walk_up": "res://assets/sprites/animation/player/knight/walk/down/knight_walk_down_base.png",
		"walk_side": "res://assets/sprites/animation/player/knight/walk/down/knight_walk_down_base.png",
	}
	var keys = anims.keys()
	var W = 96 * 4
	var H = 96 * keys.size()
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.25, 0.45, 0.2))
	for r in range(keys.size()):
		var frames: Array
		var k = keys[r]
		if "_down" in k:
			frames = TH.load_sheet_custom(anims[k], "sword", "castanho", "castanho")
		elif "_up" in k:
			frames = TH.load_sheet_up_real(anims[k], "castanho", "castanho")
		else:
			frames = TH.load_sheet_custom(anims[k], "sword", "castanho", "castanho")
		for f in range(4):
			var fr = frames[f].get_image()
			img.blit_rect(fr, Rect2i(0, 0, 96, 96), Vector2i(f * 96, r * 96))
	img.resize(W * 2, H * 2, Image.INTERPOLATE_NEAREST)
	img.save_png("/home/ethos/.assistant/workspace/artifacts/player_hybrid2.png")
	print("HYBRID2_OK")
	quit()

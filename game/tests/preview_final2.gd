extends SceneTree
func _init():
	# preview FINAL: down=arte real, up/side=procedural novo (cores da arte real)
	var TH = load("res://scripts/autoload/tex_helper.gd")
	var anims = {
		"DOWN": "res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png",
		"UP": "res://assets/sprites/animation/player/knight/idle/up/knight_idle_up_base.png",
		"SIDE": "res://assets/sprites/animation/player/knight/idle/side/knight_idle_side_base.png",
		"WALK_UP": "res://assets/sprites/animation/player/knight/walk/up/knight_walk_up_base.png",
		"WALK_SIDE": "res://assets/sprites/animation/player/knight/walk/side/knight_walk_side_base.png",
		"ATTACK_SIDE": "res://assets/sprites/animation/player/knight/attack/side/knight_attack_side_base.png",
	}
	var keys = anims.keys()
	var W = 96 * 4
	var H = 96 * keys.size()
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.25, 0.45, 0.2))
	for r in range(keys.size()):
		var k = keys[r]
		var frames: Array
		if k == "DOWN":
			frames = TH.load_sheet_custom(anims[k], "sword", "castanho", "castanho")
		else:
			frames = TH.load_sheet_procedural_custom(anims[k], "sword", "castanho", "castanho")
		for f in range(4):
			var fr = frames[f].get_image()
			img.blit_rect(fr, Rect2i(0, 0, 96, 96), Vector2i(f * 96, r * 96))
	img.resize(W * 2, H * 2, Image.INTERPOLATE_NEAREST)
	img.save_png("/home/ethos/.assistant/workspace/artifacts/player_final2.png")
	print("FINAL2_OK")
	quit()

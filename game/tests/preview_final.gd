extends SceneTree
func _init():
	# preview FINAL: replica EXATAMENTE o player.gd _build_frames
	var TH = load("res://scripts/autoload/tex_helper.gd")
	var anims = {
		"idle_down": "res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png",
		"idle_up": "res://assets/sprites/animation/player/knight/idle/up/knight_idle_up_base.png",
		"idle_side": "res://assets/sprites/animation/player/knight/idle/side/knight_idle_side_base.png",
		"walk_down": "res://assets/sprites/animation/player/knight/walk/down/knight_walk_down_base.png",
		"walk_up": "res://assets/sprites/animation/player/knight/walk/up/knight_walk_up_base.png",
		"walk_side": "res://assets/sprites/animation/player/knight/walk/side/knight_walk_side_base.png",
		"attack_down": "res://assets/sprites/animation/player/knight/attack/down/knight_attack_down_base.png",
		"attack_up": "res://assets/sprites/animation/player/knight/attack/up/knight_attack_up_base.png",
		"attack_side": "res://assets/sprites/animation/player/knight/attack/side/knight_attack_side_base.png",
		"death": "res://assets/sprites/animation/player/knight/death/down/knight_death_down_base.png",
	}
	var keys = anims.keys()
	var W = 96 * 4
	var H = 96 * keys.size()
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.25, 0.45, 0.2))
	for r in range(keys.size()):
		var k = keys[r]
		var frames: Array
		if "_down" in k or k == "death":
			frames = TH.load_sheet_custom(anims[k], "sword", "castanho", "castanho")
		elif "_up" in k:
			frames = TH.load_sheet_up_real(anims[k].replace("/up/", "/down/"), "castanho", "castanho")
		else:
			frames = TH.load_sheet_custom(anims[k].replace("/side/", "/down/"), "sword", "castanho", "castanho")
		for f in range(4):
			var fr = frames[f].get_image()
			img.blit_rect(fr, Rect2i(0, 0, 96, 96), Vector2i(f * 96, r * 96))
	img.resize(W * 2, H * 2, Image.INTERPOLATE_NEAREST)
	img.save_png("/home/ethos/.assistant/workspace/artifacts/player_final_dirs.png")
	print("FINAL_PREVIEW_OK")
	quit()

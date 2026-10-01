extends SceneTree
func _init():
	# preview DEFINITIVO: 4 classes x 4 direcoes x idle/walk — o que o jogo desenha
	var TH = load("res://scripts/autoload/tex_helper.gd")
	var weapons = ["sword", "axe", "bow", "staff"]
	var anims = {
		"down": "res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png",
		"up": "res://assets/sprites/animation/player/knight/idle/up/knight_idle_up_base.png",
		"side": "res://assets/sprites/animation/player/knight/idle/side/knight_idle_side_base.png",
	}
	var W = 96 * 4
	var H = 96 * weapons.size() * anims.size()
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.25, 0.45, 0.2))
	var row = 0
	for w in weapons:
		for a in anims:
			var frames = TH.load_sheet_procedural_custom(anims[a], w, "castanho", "castanho")
			for f in range(4):
				var fr = frames[f].get_image()
				img.blit_rect(fr, Rect2i(0, 0, 96, 96), Vector2i(f * 96, row * 96))
			row += 1
	img.resize(W * 2, H * 2, Image.INTERPOLATE_NEAREST)
	img.save_png("/home/ethos/.assistant/workspace/artifacts/preview_todas.png")
	print("TODAS_OK")
	quit()

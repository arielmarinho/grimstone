extends SceneTree
func _init():
	# check: up deve ser COSTAS (sem pele na regiao do rosto), side deve ser PERFIL
	# e up/side devem ser DIFERENTES do down (arte propria, nao flip/reuso)
	var TH = load("res://scripts/autoload/tex_helper.gd")
	var base = "res://assets/sprites/animation/player/knight/idle/"
	var down = TH.load_sheet_custom(base + "down/knight_idle_down_base.png", "sword", "castanho", "castanho")
	var up = TH.load_sheet_custom(base + "up/knight_idle_up_base.png", "sword", "castanho", "castanho")
	var side = TH.load_sheet_custom(base + "side/knight_idle_side_base.png", "sword", "castanho", "castanho")
	if down.is_empty() or up.is_empty() or side.is_empty():
		print("CHECK_FAIL_EMPTY")
		quit(1)
		return
	var d0 = down[0].get_image()
	var u0 = up[0].get_image()
	var s0 = side[0].get_image()
	# 1) up != down (imagem propria)
	var diff_ud := 0
	var diff_us := 0
	for y in range(96):
		for x in range(96):
			if d0.get_pixel(x, y) != u0.get_pixel(x, y):
				diff_ud += 1
			if d0.get_pixel(x, y) != s0.get_pixel(x, y):
				diff_us += 1
	# 2) pele na regiao do rosto (y24-50, x38-72): down deve TER, up NAO deve
	var skin_down := 0
	var skin_up := 0
	for y in range(24, 51):
		for x in range(38, 73):
			var cd = d0.get_pixel(x, y)
			var cu = u0.get_pixel(x, y)
			if cd.a > 0.5 and cd.r > 0.8 and cd.g > 0.55 and cd.b < 0.65:
				skin_down += 1
			if cu.a > 0.5 and cu.r > 0.8 and cu.g > 0.55 and cu.b < 0.65:
				skin_up += 1
	print("diff_up_vs_down=", diff_ud, " diff_side_vs_down=", diff_us)
	print("skin_face_down=", skin_down, " skin_face_up=", skin_up)
	var ok = diff_ud > 200 and diff_us > 200 and skin_up < 5
	print("REAL4_CHECK_OK" if ok else "REAL4_CHECK_FAIL")
	quit(0 if ok else 1)

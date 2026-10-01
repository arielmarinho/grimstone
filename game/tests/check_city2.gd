extends SceneTree
func _init():
	var TH = load("res://scripts/autoload/tex_helper.gd")
	var img = TH.load_map("res://assets/maps/city2.png").get_image()
	# abertura EXCLUINDO a faixa da rua (y 476-546) e as torres (y<472, y>572)
	var wall_open = 0
	for y in range(472, 476):
		for x in range(140, 157):
			var c = img.get_pixel(x, y)
			if abs(c.r - c.g) < 0.06 and abs(c.g - c.b) < 0.06 and c.r > 0.4 and c.r < 0.75:
				wall_open += 1
	for y in range(546, 572):
		for x in range(140, 157):
			var c = img.get_pixel(x, y)
			if abs(c.r - c.g) < 0.06 and abs(c.g - c.b) < 0.06 and c.r > 0.4 and c.r < 0.75:
				wall_open += 1
	var wall_ctl = 0
	for y in range(200, 300):
		for x in range(140, 157):
			var c = img.get_pixel(x, y)
			if abs(c.r - c.g) < 0.06 and abs(c.g - c.b) < 0.06 and c.r > 0.4 and c.r < 0.75:
				wall_ctl += 1
	var road_s = 0
	for y in range(990, 1020):
		for x in range(470, 575):
			var c = img.get_pixel(x, y)
			if abs(c.r - c.g) < 0.08 and c.r > 0.4 and c.r < 0.75:
				road_s += 1
	var forge = 0
	for y in range(780, 805):
		for x in range(768, 792):
			var c = img.get_pixel(x, y)
			if c.r > 0.85 and c.g > 0.35 and c.g < 0.85 and c.b < 0.3:
				forge += 1
	print("CHECK wall_open=%d wall_ctl=%d road_south=%d forge=%d" % [wall_open, wall_ctl, road_s, forge])
	print("RESULT " + ("OK" if (wall_open < 30 and wall_ctl > 100 and road_s > 300 and forge > 30) else "FAIL"))
	quit()

extends SceneTree
func _init():
	var TH = load("res://scripts/autoload/tex_helper.gd")
	for name in ["city1", "city2", "forest", "rat_cave"]:
		var t = TH.load_map("res://assets/maps/%s.png" % name)
		var img = t.get_image()
		img.resize(512, 512, Image.INTERPOLATE_NEAREST)
		img.save_png("/home/ethos/.assistant/workspace/artifacts/map_%s.png" % name)
	print("MAPS_OK")
	quit()

extends SceneTree
func _init():
	var TH = load("res://scripts/autoload/tex_helper.gd")
	var t = TH.load_map("res://assets/maps/city1.png")
	print("city1 texture: ", t.get_width(), "x", t.get_height())
	var t2 = TH.load_map("res://assets/maps/rat_cave.png")
	print("rat_cave texture: ", t2.get_width(), "x", t2.get_height())
	quit()

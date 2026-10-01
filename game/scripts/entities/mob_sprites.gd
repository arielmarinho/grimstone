static func _rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for j in range(int(h)):
		for i in range(int(w)):
			var px = x + i
			var py = y + j
			if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
				img.set_pixel(px, py, c)
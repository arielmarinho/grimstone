extends SceneTree
## preview_mob_shadow.gd — Area 44 (v0.6.50): monstros com e sem sombra no chao.
## Roda: godot --headless --path . -s tests/preview_mob_shadow.gd
## Grava artifacts/preview/mob_shadow_v0650.png (ANTES sem sombra | DEPOIS com sombra)

const TH := preload("res://scripts/autoload/tex_helper.gd")
const SH := preload("res://scripts/entities/mob_shadow.gd")
const MOB := preload("res://scripts/entities/mob.gd")
const CELL := 96
const FEET := 46.0
const TYPES := ["rat", "slime", "bat", "spider", "wolf", "goblin", "orc", "skeleton", "dummy"]


func _blit(dst: Image, src: Image, s: float, off_y: float, dx: int, dy: int, tint_a: float) -> void:
	var w := int(round(src.get_width() * s))
	var h := int(round(src.get_height() * s))
	var sc := src.duplicate()
	sc.convert(Image.FORMAT_RGBA8)
	sc.resize(maxi(w, 1), maxi(h, 1), Image.INTERPOLATE_NEAREST)
	var oy := int(round(off_y * s))
	for y in range(h):
		for x in range(w):
			var c: Color = sc.get_pixel(x, y)
			if c.a <= 0.0:
				continue
			var tx := dx + x
			var ty := dy + oy + y
			if tx < 0 or ty < 0 or tx >= dst.get_width() or ty >= dst.get_height():
				continue
			var ca: float = c.a * tint_a
			var base: Color = dst.get_pixel(tx, ty)
			var a: float = ca + base.a * (1.0 - ca)
			if a <= 0.0:
				continue
			dst.set_pixel(tx, ty, Color(
				(c.r * ca + base.r * base.a * (1.0 - ca)) / a,
				(c.g * ca + base.g * base.a * (1.0 - ca)) / a,
				(c.b * ca + base.b * base.a * (1.0 - ca)) / a, a))


func _initialize() -> void:
	var CW := 130
	var CH := 200
	var W := CW * TYPES.size()
	var H := CH * 2 + 30
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.10, 0.11, 0.09))
	for band in range(2):
		var y0: int = band * (CH + 15)
		var ground_y: int = y0 + 140
		for y in range(ground_y, y0 + CH):
			for x in range(W):
				img.set_pixel(x, y, Color(0.22, 0.27, 0.18))
		for x in range(W):
			img.set_pixel(x, ground_y, Color(0.9, 0.3, 0.3, 0.9))
		for i in range(TYPES.size()):
			var t: String = TYPES[i]
			TH.CURRENT_MOB = t
			var texs: Array = TH.load_sheet_procedural("res://assets/sprites/animation/enemy/rat/idle/down/rat_idle_down.png")
			if texs.is_empty():
				continue
			var src: Image = texs[0].get_image()
			if src == null:
				continue
			src.convert(Image.FORMAT_RGBA8)
			var small: bool = t in ["rat", "slime", "bat"]
			var s: float = 1.4 if small else 1.15
			var off: float = float(MOB.MOB_FEET_OFFSET.get(t, 0.0))
			var cx: int = i * CW + CW / 2
			var node_y: int = ground_y - int(FEET)
			# banda de baixo = COM sombra: desenha a sombra antes do corpo
			if band == 1:
				# sombra: elipse preta com alpha caindo para a borda, base na linha do pe'
				var sh_w: float = SH.width_for(t)
				var sh_h: float = SH.height_screen()
				var scy: float = float(ground_y) - sh_h * 0.5
				for yy in range(int(ground_y - sh_h) - 1, int(ground_y) + 2):
					for xx in range(int(cx - sh_w) - 1, int(cx + sh_w) + 2):
						var nx: float = (float(xx) + 0.5 - float(cx)) / (sh_w * 0.5)
						var ny: float = (float(yy) + 0.5 - scy) / (sh_h * 0.5)
						var d2: float = nx * nx + ny * ny
						if d2 >= 1.0:
							continue
						if xx < 0 or yy < 0 or xx >= W or yy >= H:
							continue
						var ca: float = SH.ALPHA * (1.0 - d2) * (1.0 - d2)
						if ca <= 0.004:
							continue
						var base: Color = img.get_pixel(xx, yy)
						var a: float = ca + base.a * (1.0 - ca)
						img.set_pixel(xx, yy, Color(
							(0.0 * ca + base.r * base.a * (1.0 - ca)) / a,
							(0.0 * ca + base.g * base.a * (1.0 - ca)) / a,
							(0.0 * ca + base.b * base.a * (1.0 - ca)) / a, 1.0))
			var dx: int = cx - int(round(src.get_width() * s * 0.5))
			var dy: int = node_y - int(round(src.get_height() * s * 0.5))
			_blit(img, src, s, off, dx, dy, 1.0)
		# etiqueta da faixa
		var tag: Color = Color(0.9, 0.35, 0.3) if band == 0 else Color(0.35, 0.85, 0.4)
		for y in range(y0 + 6, y0 + 16):
			for x in range(8, 8 + 120):
				img.set_pixel(x, y, tag)
	var out := "/home/ethos/.assistant/workspace/artifacts/preview"
	DirAccess.make_dir_recursive_absolute(out)
	img.resize(W * 2, H * 2, Image.INTERPOLATE_NEAREST)
	img.save_png(out + "/mob_shadow_v0650.png")
	print("PREVIEW_MOB_SHADOW_OK " + out + "/mob_shadow_v0650.png")
	quit()

extends SceneTree
## preview_npcs.gd — prova visual da Area 41: knight | NPC quest | NPC banco, com a
## LINHA DO CHAO desenhada. Roda: `godot --headless --path . -s tests/preview_npcs.gd`
## Grava artifacts/preview/npcs_line.png

const CELL := 96
const NA := preload("res://scripts/world/npc_art.gd")
const TH := preload("res://scripts/autoload/tex_helper.gd")
const TARGET := 46.0


func _blit(dst: Image, src: Image, scale: float, off_y: float, dx: int, dy: int) -> void:
	var w := int(CELL * scale)
	var h := int(CELL * scale)
	var sc := src.duplicate()
	sc.resize(w, h, Image.INTERPOLATE_NEAREST)
	var oy := int(off_y * scale)
	for y in range(h):
		for x in range(w):
			var c: Color = sc.get_pixel(x, y)
			if c.a <= 0.0:
				continue
			var tx := dx + x
			var ty := dy + oy + y
			if tx < 0 or ty < 0 or tx >= dst.get_width() or ty >= dst.get_height():
				continue
			var base: Color = dst.get_pixel(tx, ty)
			var a: float = c.a + base.a * (1.0 - c.a)
			if a <= 0.0:
				continue
			var out := Color(
				(c.r * c.a + base.r * base.a * (1.0 - c.a)) / a,
				(c.g * c.a + base.g * base.a * (1.0 - c.a)) / a,
				(c.b * c.a + base.b * base.a * (1.0 - c.a)) / a, a)
			dst.set_pixel(tx, ty, out)


func _run() -> void:
	var W := 760
	var H := 420
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.16, 0.18, 0.14))
	# chao
	for y in range(300, H):
		for x in range(W):
			img.set_pixel(x, y, Color(0.24, 0.28, 0.19))
	# linha do chao na tela (y do pe' do player)
	var line_y := 300
	for x in range(0, W):
		img.set_pixel(x, line_y, Color(1, 0.3, 0.3, 0.9))
		img.set_pixel(x, line_y + 1, Color(1, 0.5, 0.4, 0.5))

	# knight (referencia)
	var k := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	k.fill(Color(0, 0, 0, 0))
	TH._draw_knight(k, 0, false, false, false, "sword", "castanho", "castanho", "down")
	# o knight no jogo e' centrado na celula com o pe' em 46px; aqui coloco o pe' na linha
	_blit(img, k, 1.15, 0.0, 60, line_y - int(48 * 1.15) - int(41.4 - 46))
	_blit(img, NA.quest_image(), NA.SPRITE_SCALE, NA.sprite_offset_y(), 300, line_y - 48)
	_blit(img, NA.bank_image(), NA.SPRITE_SCALE, NA.sprite_offset_y(), 500, line_y - 48)

	var out := "/home/ethos/.assistant/workspace/artifacts/preview"
	DirAccess.make_dir_recursive_absolute(out)
	var big := img.duplicate()
	big.resize(W * 2, H * 2, Image.INTERPOLATE_NEAREST)
	big.save_png(out + "/npcs_line.png")
	print("PREVIEW_NPCS_IMG " + out + "/npcs_line.png")
	quit()


func _initialize() -> void:
	_run()

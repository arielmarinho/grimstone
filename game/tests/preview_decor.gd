extends SceneTree
## preview_decor.gd — Area 43 (v0.6.48): ANTES x DEPOIS da linha do chao da decoracao.
## Roda: godot --headless --path . -s tests/preview_decor.gd
## Grava artifacts/preview/decor_line.png
##   faixa de cima  = ANTES (offset 0)          -> objetos fora do chao
##   faixa de baixo = DEPOIS (offset da arte)   -> todos com o pe' na linha
## A linha vermelha em cada faixa e' o pe' do player (KNIGHT_FEET_SCREEN).

const DECOR := preload("res://scripts/world/decor.gd")
const TH := preload("res://scripts/autoload/tex_helper.gd")
const CELL := 96
const SCALE := 2.0
const KNIGHT_FEET := 46.0
const LINE_IN_BAND := 178  # y da linha do chao dentro de cada faixa
const BAND_H := 220
const W := 1160


func _blit(dst: Image, src: Image, scale: float, off_y: float, dx: int, dy: int) -> void:
	var w := int(src.get_width() * scale)
	var h := int(src.get_height() * scale)
	var sc := src.duplicate()
	sc.convert(Image.FORMAT_RGBA8)
	sc.resize(maxi(w, 1), maxi(h, 1), Image.INTERPOLATE_NEAREST)
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
			dst.set_pixel(tx, ty, Color(
				(c.r * c.a + base.r * base.a * (1.0 - c.a)) / a,
				(c.g * c.a + base.g * base.a * (1.0 - c.a)) / a,
				(c.b * c.a + base.b * base.a * (1.0 - c.a)) / a, a))


func _band(img: Image, y0: int, ok: bool) -> void:
	var ground := Color(0.24, 0.28, 0.19) if ok else Color(0.26, 0.22, 0.20)
	for y in range(y0, y0 + BAND_H):
		for x in range(W):
			img.set_pixel(x, y, Color(0.16, 0.18, 0.14) if y < y0 + LINE_IN_BAND else ground)
	var ly := y0 + LINE_IN_BAND
	for x in range(W):
		img.set_pixel(x, ly, Color(1, 0.3, 0.3, 0.95))
		img.set_pixel(x, ly + 1, Color(1, 0.5, 0.4, 0.5))
	# "rotulo" da faixa: barra verde (ok) ou vermelha (problema) no canto superior
	var tag := Color(0.35, 0.85, 0.4) if ok else Color(0.9, 0.35, 0.3)
	for y in range(y0 + 6, y0 + 18):
		for x in range(8, 8 + 220):
			img.set_pixel(x, y, tag)


func _initialize() -> void:
	var H := BAND_H * 2 + 8
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.10, 0.11, 0.09))
	_band(img, 0, false)          # ANTES
	_band(img, BAND_H + 8, true)  # DEPOIS

	# knight de referencia nas duas faixas (pe' na linha vermelha)
	var k := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	k.fill(Color(0, 0, 0, 0))
	TH._draw_knight(k, 0, false, false, false, "sword", "castanho", "castanho", "down")
	var k_off := (41.4 - KNIGHT_FEET)
	for band in [0, BAND_H + 8]:
		_blit(img, k, 1.15, k_off, 30, band + LINE_IN_BAND - int(CELL * 0.5 * 1.15))

	var kinds := [DECOR.LAMP, DECOR.FLOWERS, DECOR.BARREL, DECOR.CRATE, DECOR.FLAG, DECOR.STALL]
	var x := 190
	for kd in kinds:
		var tex: Texture2D = DECOR._tex_of(kd)
		var src := tex.get_image()
		src.convert(Image.FORMAT_RGBA8)
		# o sprite e' CENTRADO no node e o node fica 46px acima da linha do chao
		# (exatamente como o jogo desenha: Sprite2D na posicao do decor).
		var node_y := LINE_IN_BAND - int(KNIGHT_FEET)
		var dy := node_y - int(src.get_height() * 0.5 * SCALE)
		# ANTES (faixa de cima): sprite centrado no node, offset ZERO
		_blit(img, src, SCALE, 0.0, x, dy)
		# DEPOIS (faixa de baixo): mesmo node, com o offset derivado da arte
		_blit(img, src, SCALE, DECOR.feet_offset(tex), x, dy + BAND_H + 8)
		x += 150

	var out := "/home/ethos/.assistant/workspace/artifacts/preview"
	DirAccess.make_dir_recursive_absolute(out)
	var big := img.duplicate()
	big.resize(W * 2, H * 2, Image.INTERPOLATE_NEAREST)
	big.save_png(out + "/decor_line.png")
	print("PREVIEW_DECOR_IMG " + out + "/decor_line.png")
	quit()

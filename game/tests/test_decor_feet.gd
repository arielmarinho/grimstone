extends SceneTree
## test_decor_feet.gd — Area 43 (v0.6.48): decoracao das cidades na LINHA DO CHAO.
## Roda: `godot --headless --path . -s tests/test_decor_feet.gd`  -> DECOR_FEET_TEST_OK
##
## BUG medido (tests/measure_decor.gd, antes do fix):
##   LAMP  pe_tela 60.0 (+14.0 = 14px AFUNDADO)
##   FLOWERS        24.0 (-22.0 = 22px FLUTUANDO)
##   BARREL         44.0 ( -2.0)
##   CRATE          36.0 (-10.0 = 10px flutuando)
##   FLAG           60.0 (+14.0 = 14px afundado)
##   STALL          52.0 ( +6.0 = 6px afundado)
## O Sprite2D era centrado na posicao do node, scale 2.0, SEM offset -> cada objeto
## apoiava num y diferente. Agora o offset vem da propria arte (ultimo pixel opaco).
##
## Regua igual a do player/monstros/NPCs: pe' a KNIGHT_FEET_SCREEN (46px) abaixo do
## centro do node. Tolerancia 1px.

const DECOR := preload("res://scripts/world/decor.gd")
const KNIGHT_FEET := 46.0
const TOL := 1.0

var fails := 0


func _check(kind: int, name: String) -> void:
	var tex: Texture2D = DECOR._tex_of(kind)
	var img: Image = tex.get_image()
	img.convert(Image.FORMAT_RGBA8)
	var base := -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.5:
				base = y
	var off: float = DECOR.feet_offset(tex)
	var feet: float = (float(base) + 1.0 - float(img.get_height()) * 0.5 + off) * DECOR.SPRITE_SCALE
	print("DECORFEET|%s|pe=%.2f|offset=%.2f|desvio=%+.2f" % [name, feet, off, feet - KNIGHT_FEET])
	if absf(feet - KNIGHT_FEET) > TOL:
		print("FALHA %s: pe' a %.2fpx da linha do player (%.2f), tolerancia %.1f" % [name, feet, KNIGHT_FEET, TOL])
		fails += 1


func _initialize() -> void:
	# 1) a regua fecha: offset calculado pela propria arte devolve o pe' na linha
	_check(DECOR.LAMP, "LAMP")
	_check(DECOR.FLOWERS, "FLOWERS")
	_check(DECOR.BARREL, "BARREL")
	_check(DECOR.CRATE, "CRATE")
	_check(DECOR.FLAG, "FLAG")
	_check(DECOR.STALL, "STALL")

	# 2) toda entrada das DUAS cidades usa uma arte conhecida (nada de kind invalido)
	var kinds := 0
	for it in DECOR.CITY1_DECOR:
		kinds = maxi(kinds, int(it[0]))
	for it in DECOR.CITY2_DECOR:
		kinds = maxi(kinds, int(it[0]))
	if kinds != DECOR.STALL:
		print("FALHA: decoracao com tipo desconhecido (max %d, esperado %d)" % [kinds, DECOR.STALL])
		fails += 1

	# 3) nada encosta nas bordas LATERAIS nem no TOPO (cortaria no mundo).
	# A borda de BAIXO e' a linha do chao: encostar nela e' o correto (canteiro).
	for k in range(DECOR.STALL + 1):
		var img: Image = DECOR._tex_of(k).get_image()
		img.convert(Image.FORMAT_RGBA8)
		var w := img.get_width()
		var h := img.get_height()
		var touch := false
		for x in range(w):
			if img.get_pixel(x, 0).a > 0.5:
				touch = true
		for y in range(h):
			if img.get_pixel(0, y).a > 0.5 or img.get_pixel(w - 1, y).a > 0.5:
				touch = true
		if touch:
			print("FALHA kind %d: textura encosta na borda (%dx%d)" % [k, w, h])
			fails += 1

	if fails == 0:
		print("DECOR_FEET_TEST_OK")
	else:
		print("DECOR_FEET_TEST_FAIL %d" % fails)
	quit()

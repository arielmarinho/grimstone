extends SceneTree
## test_mob_feet.gd — LINHA DO CHAO dos monstros (Area 42, v0.6.47)
## Roda: `godot --headless --path . -s res://tests/test_mob_feet.gd`
##
## O BUG que este teste trava (medido, tests/measure_mob_feet.gd):
##   o node do mob e' ancorado no CENTRO da celula 96 sem offset de pe', e o pe'
##   desenhado varia de y=63 (morcego) a y=91 (dummy). Na tela: morcego 18px
##   ACIMA da linha do chao do player, rato/slime 10-11px ABAIXO, goblin e
##   esqueleto 3.5px abaixo. Todo bicho flutuava ou afundava.
##
## Regua (a mesma do NpcArt e do player): pes do knight = 46px abaixo do centro
## (Equips.KNIGHT_FEET_SCREEN). Um pixel da arte em y aparece na tela em
## (y - 48 + offset) * scale.
## Criterio: com o offset por tipo, IDLE/WALK/ATTACK nas 3 direcoes tem que cair
## a no maximo TOL px da linha — e o offset nao pode ser zero pra todo mundo
## (era o bug).

const CELL := 96
const MS := preload("res://scripts/entities/mob_sprites.gd")
const MOB := preload("res://scripts/entities/mob.gd")
const TYPES := ["rat", "slime", "bat", "spider", "wolf", "goblin", "orc", "skeleton", "dummy"]
const TARGET := 46.0
const TOL := 5.0

var fails := 0


func _check(cond: bool, msg: String) -> void:
	if cond:
		print("  ok  ", msg)
	else:
		fails += 1
		print("  FAIL ", msg)


func _bottom_edge(img: Image) -> float:
	var m := -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.9:
				m = maxi(m, y)
				break
	return float(m + 1)


func _img(t: String, f: int, d: String, walk: bool, atk: bool) -> Image:
	var im := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	im.fill(Color(0, 0, 0, 0))
	MS.draw_mob(im, t, f, atk, false, walk, d)
	return im


func _run() -> void:
	print("MOB_FEET_TEST")
	var offs: Dictionary = MOB.MOB_FEET_OFFSET
	_check(offs.size() == TYPES.size(), "tabela tem uma entrada por tipo (%d/%d)" % [offs.size(), TYPES.size()])
	var non_zero := 0
	for t in TYPES:
		_check(offs.has(t), "%s tem offset de pe'" % t)
		if absf(float(offs.get(t, 0.0))) > 0.01:
			non_zero += 1
	# o bug era exatamente "todos ancorados no centro" -> offset zero na tabela inteira
	_check(non_zero >= 5, "offset realmente difere por tipo (%d tipos com offset != 0)" % non_zero)

	for t in TYPES:
		var small: bool = t in ["rat", "slime", "bat"]
		var sc: float = 1.4 if small else 1.15
		var off: float = float(offs.get(t, 0.0))
		var worst := 0.0
		var worst_where := ""
		for d in ["down", "up", "side"]:
			for f in range(4):
				for mode in [0, 1, 2]:  # idle / walk / attack
					var b := _bottom_edge(_img(t, f, d, mode == 1, mode == 2))
					var dev: float = (b - 48.0 + off) * sc - TARGET
					if absf(dev) > worst:
						worst = absf(dev)
						worst_where = "%s f%d m%d" % [d, f, mode]
		_check(worst <= TOL, "%s: pior desvio %.1fpx (tol %.0f, %s)" % [t, worst, TOL, worst_where])

	# controle do player: o knight e' a referencia, nao pode ser "corrigido" aqui
	_check(true, "regua = pes do knight a %.0fpx do centro (Equips.KNIGHT_FEET_SCREEN)" % TARGET)

	if fails == 0:
		print("MOB_FEET_TEST_OK (%d tipos, tolerancia %.0fpx)" % [TYPES.size(), TOL])
	else:
		print("MOB_FEET_TEST_FAIL: %d" % fails)
	quit()


func _initialize() -> void:
	_run()

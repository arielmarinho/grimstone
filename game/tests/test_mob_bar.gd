extends SceneTree
## test_mob_bar.gd — BARRA DE VIDA do monstro na altura da cabeca (Area 43, v0.6.49)
## Roda: godot --headless --path . -s res://tests/test_mob_bar.gd
##
## O BUG que trava: o ProgressBar da barra de vida tinha offset FIXO no .tscn
## (-44..-38). Com o offset de pe' por tipo (v0.6.48) cada corpo termina num y
## diferente e a barra ficou boiando ate 50px acima da cabeca do slime/morcego/
## aranha e colada no rato (7.5px). Um numero magico no .tscn que nao conhece
## nem a arte nem a escala.
##
## Criterio: a barra tem que ficar GAP +/- TOL px acima do topo REAL da arte de
## CADA tipo (medido pixel a pixel), e a regra tem que ser a mesma do resto do
## jogo: centro da celula 96, (y - 48 + feet_offset) * scale.

const CELL := 96
const MS := preload("res://scripts/entities/mob_sprites.gd")
const MOB := preload("res://scripts/entities/mob.gd")
const MB := preload("res://scripts/entities/mob_bar.gd")
const TYPES := ["rat", "slime", "bat", "spider", "wolf", "goblin", "orc", "skeleton", "dummy"]
const TOL := 1.5

var fails := 0


func _check(cond: bool, msg: String) -> void:
	if cond:
		print("  ok  ", msg)
	else:
		fails += 1
		print("  FAIL ", msg)


func _top(img: Image) -> float:
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.9:
				return float(y)
	return -1.0


func _run() -> void:
	print("MOB_BAR_TEST")
	var gaps: Array[float] = []
	for t in TYPES:
		var small: bool = t in ["rat", "slime", "bat"]
		var sc: float = 1.4 if small else 1.15
		var off: float = float(MOB.MOB_FEET_OFFSET.get(t, 0.0))
		# topo real da arte (o mais alto entre idle/walk/attack nas 3 direcoes)
		var top := 999.0
		for d in ["down", "up", "side"]:
			for f in range(4):
				for walk in [false, true]:
					for atk in [false, true]:
						var im := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
						im.fill(Color(0, 0, 0, 0))
						MS.draw_mob(im, t, f, atk, false, walk, d)
						var v := _top(im)
						if v >= 0.0:
							top = minf(top, v)
		var bar_top: float = MB.bar_top(top, off, sc)
		var head: float = MB.head_top_screen(top, off, sc)
		var gap: float = head - (bar_top + MB.BAR_H) + MB.GAP
		gaps.append(head - (bar_top + MB.BAR_H))
		_check(absf(head - (bar_top + MB.BAR_H) - MB.GAP) < TOL,
			"%s: barra %0.1fpx acima da cabeca (alvo %0.1f)" % [t, head - (bar_top + MB.BAR_H), MB.GAP])
		# a barra nunca pode encostar no corpo nem sair muito longe
		var dgap: float = head - (bar_top + MB.BAR_H)
		_check(dgap > 2.0 and dgap < 14.0, "%s: folga visivel (%0.1fpx)" % [t, dgap])

	# o bug: offset fixo do .tscn dava folgas de -7.5 a -50 px (barra ALTA demais
	# ou colada). Se todos os tipos caem na MESMA folga, a regra esta' derivando
	# da arte de verdade, nao de um numero fixo.
	var lo: float = gaps[0]
	var hi: float = gaps[0]
	for g in gaps:
		lo = minf(lo, g)
		hi = maxf(hi, g)
	_check(hi - lo < TOL * 2.0, "folga uniforme entre os 9 tipos (%.1f..%.1f)" % [lo, hi])
	# guarda contra regressao do bug original: com offset fixo -44 a folga variava 42px
	_check(hi - lo < 10.0, "folga nao varia 40+px como no offset fixo (-44)")

	# helper puro: topo de imagem vazia = -1 (nao inventa numero)
	var empty := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	empty.fill(Color(0, 0, 0, 0))
	_check(MB.head_top_of(empty) < 0.0, "imagem vazia devolve -1")

	if fails == 0:
		print("MOB_BAR_TEST_OK")
	else:
		print("MOB_BAR_TEST_FAIL %d" % fails)
	quit()


func _initialize() -> void:
	_run()

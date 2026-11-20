extends SceneTree
## test_npc_art.gd — Area 41 (v0.6.45): NPCs na MESMA linha do chao do player.
## Roda: `godot --headless --path . -s tests/test_npc_art.gd`  -> NPC_ART_TEST_OK
##
## BUG medido (tests/measure_npcs.gd) e travado aqui:
##   quest_npc.gd e bank.gd desenhavam o sprite em scale 2.0 SEM offset de pe':
##   - altura 144px na tela contra 99px do knight (1.45x mais alto);
##   - o pe' caia a 84px abaixo do centro contra 46px do player = 38px AFUNDADO
##     no chao, e o nome flutuava 95px acima.
## Regua: KNIGHT_FEET_SCREEN = 46px (Equips.sprite_offset_y_for) com
##   pe_tela = (pe_arte - 48 + offset) * scale.

const NA := preload("res://scripts/world/npc_art.gd")
const CELL := 96
const KNIGHT_FEET := 46.0
const KNIGHT_H := 99.0   # 86px de arte * 1.15 (medido na folha real do knight)
const TOL_PE := 1.0
const TOL_H := 0.15      # 15% de altura: NPC pode ser um pouco mais alto/baixo

var fails := 0


func _feet(img: Image) -> float:
	var m := -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.9:   # sombra (alpha 0.25) nao e' pe'
				m = maxi(m, y)
				break
	return float(m + 1)


func _top(img: Image) -> float:
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.9:
				return float(y)
	return 0.0


func _check(name: String, img: Image) -> void:
	var sc: float = NA.SPRITE_SCALE
	var off: float = NA.sprite_offset_y()
	var feet_art := _feet(img)
	var feet_screen: float = (feet_art - CELL * 0.5 + off) * sc
	var h_screen: float = (_feet(img) - _top(img)) * sc
	print("NPCART|%s|pe_tela=%.1f|altura=%.1f|scale=%.2f|offset=%.2f" % [name, feet_screen, h_screen, sc, off])
	if absf(feet_screen - KNIGHT_FEET) > TOL_PE:
		print("FALHA %s: pe a %.1fpx da linha do player (%.1f) — tolerancia %.1f" % [name, feet_screen, KNIGHT_FEET, TOL_PE])
		fails += 1
	if absf(h_screen - KNIGHT_H) / KNIGHT_H > TOL_H:
		print("FALHA %s: altura %.1fpx vs knight %.1fpx (tolerancia %.0f%%)" % [name, h_screen, KNIGHT_H, TOL_H * 100.0])
		fails += 1
	# nada pode encostar na borda da celula (senao o sprite corta no mundo)
	var b := Rect2i(0, 0, 0, 0)
	var x0 := CELL
	var y0 := CELL
	var x1 := -1
	var y1 := -1
	for y in range(CELL):
		for x in range(CELL):
			if img.get_pixel(x, y).a > 0.0:
				x0 = mini(x0, x)
				y0 = mini(y0, y)
				x1 = maxi(x1, x)
				y1 = maxi(y1, y)
	if x0 < 1 or y0 < 1 or x1 > CELL - 2 or y1 > CELL - 2:
		print("FALHA %s: sprite encosta na borda da celula (%d,%d)-(%d,%d)" % [name, x0, y0, x1, y1])
		fails += 1
	print("NPCART|%s|bbox=%d,%d-%d,%d" % [name, x0, y0, x1, y1])


func _run() -> void:
	# 1) a regua fecha: offset calculado devolve o pe na linha do player
	var sc: float = NA.SPRITE_SCALE
	var check: float = (NA.FEET_ART - CELL * 0.5 + NA.sprite_offset_y()) * sc
	print("NPCART|regua|pe_calculado=%.2f" % check)
	if absf(check - KNIGHT_FEET) > 0.01:
		print("FALHA regua: constante FEET_ART/offset incoerentes (%.2f)" % check)
		fails += 1

	# 2) os dois NPCs na mesma linha e mesma altura
	var q := NA.quest_image()
	var b := NA.bank_image()
	_check("quest", q)
	_check("bank", b)
	if absf(_feet(q) - _feet(b)) > 0.5:
		print("FALHA: NPC de quest e do banco com pes diferentes (%.0f vs %.0f)" % [_feet(q), _feet(b)])
		fails += 1
	if absf(_top(q) - _top(b)) > 0.5:
		print("FALHA: NPC de quest e do banco com alturas diferentes")
		fails += 1

	# 3) a arte nao pode ser a mesma imagem (quest = azul, banco = dourado)
	var same := 0
	for y in range(0, CELL, 3):
		for x in range(0, CELL, 3):
			var ca := q.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			if ca.a > 0.9 and cb.a > 0.9 and absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b) < 0.05:
				same += 1
	if same > 300:
		print("FALHA: quest e banco quase identicos (%d amostras iguais)" % same)
		fails += 1

	if fails == 0:
		print("NPC_ART_TEST_OK")
	else:
		print("NPC_ART_TEST_FAIL %d" % fails)
	quit()


func _initialize() -> void:
	_run()

extends SceneTree
## test_ground_items.gd — Area 45 (v0.6.51): itens dropados e moedas NA LINHA DO CHAO.
## Roda: `godot --headless --path . -s tests/test_ground_items.gd` -> GROUND_ITEM_TEST_OK
##
## BUG medido (antes do fix): `drop.gd` cria o Sprite2D CENTRADO na posicao do node,
## e o node nasce em `mob.global_position` (CENTRO da celula). Pela regua do projeto
## o pe' fica FEET_SCREEN=46px abaixo desse centro, logo a base do icone de 20px
## caia em 46 - 36 = +10px = 36px ACIMA do chao: o loot pairava no ar.
##
## Trava: base do icone na linha do chao (tol 0.5px), aura no chao, pulinho sem
## afundar o item, e a regua unica compartilhada com player/mobs/NPCs/decor.

const GROUND := preload("res://scripts/entities/ground_item.gd")
const DROP := preload("res://scripts/entities/drop.gd")

const TOL := 0.5
var fails := 0


func _ok(cond: bool, msg: String) -> void:
	if not cond:
		print("FALHA: ", msg)
		fails += 1


func _initialize() -> void:
	# 1) regua unica do projeto: 46px abaixo do centro do node
	_ok(GROUND.FEET_SCREEN == 46.0, "FEET_SCREEN deveria ser 46 (regua do player)")
	_ok(GROUND.FEET_SCREEN == GROUND.base_offset(0.0),
		"icone de altura 0 deveria assentar o centro na linha do chao")

	# 2) base do icone exatamente na linha do chao, para os icones do jogo
	for h in [12.0, 16.0, 20.0, 24.0, 32.0]:
		var base: float = GROUND.base_offset(h) + h * 0.5
		print("GROUND|h=%.0f|base_tela=%.2f|desvio=%+.2f" % [h, base, base - GROUND.FEET_SCREEN])
		_ok(absf(base - GROUND.FEET_SCREEN) <= TOL,
			"icone h=%.0f: base a %.2fpx da linha (esperado %.1f)" % [h, base, GROUND.FEET_SCREEN])

	# 3) o pulinho SOBE o item (nunca afunda no chao)
	var peak: float = GROUND.bob_peak(20.0)
	var peak_base: float = peak + 10.0
	_ok(peak_base < GROUND.FEET_SCREEN, "pico do pulinho deveria ficar ACIMA do chao")
	_ok(GROUND.bob_peak(20.0) < GROUND.base_offset(20.0), "pulinho deveria subir (y menor)")

	# 4) aura de raridade no chao (nao no meio do icone flutuante)
	_ok(GROUND.aura_center_y() > 0.0 and GROUND.aura_center_y() < GROUND.FEET_SCREEN,
		"aura deveria ficar entre o centro e a linha do chao (y=%.1f)" % GROUND.aura_center_y())

	# 5) o drop.gd REAL usa a regua (nao voltou ao Sprite2D centrado)
	var src := FileAccess.get_file_as_string("res://scripts/entities/drop.gd")
	_ok(src.contains("GROUND.base_offset"), "drop.gd deveria usar GROUND.base_offset")
	_ok(not src.contains("as_relative()"), "drop.gd nao deveria animar por posicao relativa (bug antigo)")

	if fails == 0:
		print("GROUND_ITEM_TEST_OK")
	else:
		print("GROUND_ITEM_TEST_FAIL %d" % fails)
	quit()

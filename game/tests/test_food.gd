extends SceneTree
## teste unitario: comida/energia (well_fed) — FED_TEST_OK esperado

func _init() -> void:
	var gm = load("res://scripts/autoload/game_manager.gd").new()
	# comer carne: +30 hp, +180s de bem alimentado
	gm.bag = {"carne": 2}
	var hp0: int = gm.hp_max - 50  # espaco pra curar
	gm.hp = hp0
	var ok: bool = gm.use_item("carne")
	_assert(ok, "use_item carne")
	_assert(gm.well_fed_time >= 180.0, "well_fed apos carne (%.0f)" % gm.well_fed_time)
	_assert(gm.hp == hp0 + 30, "hp +30")
	# comer de novo empilha
	gm.use_item("carne")
	_assert(gm.well_fed_time >= 360.0, "empilhou (%.0f)" % gm.well_fed_time)
	# queijo +300s
	gm.bag = {"queijo": 1}
	gm.use_item("queijo")
	_assert(gm.well_fed_time >= 600.0, "empilhou queijo (%.0f)" % gm.well_fed_time)
	# cap de 600s: comer mais nao passa
	gm.bag = {"queijo": 3}
	gm.use_item("queijo")
	_assert(gm.well_fed_time <= 600.0, "cap 600 (%.0f)" % gm.well_fed_time)
	# item sem comida nao mexe no timer
	gm.bag = {"pocao_vida_p": 1}
	gm.well_fed_time = 100.0
	gm.use_item("pocao_vida_p")
	_assert(absf(gm.well_fed_time - 100.0) < 0.01, "pocao nao mexe no timer (%.0f)" % gm.well_fed_time)
	print("FED_TEST_OK")
	quit(0)

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		printerr("FED_TEST_FAIL: " + msg)
		quit(1)

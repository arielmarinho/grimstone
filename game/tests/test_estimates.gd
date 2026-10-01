# Teste headless: estimativas de tempo (skill_xp_need / skill_time_left / level_time_left)
extends SceneTree

func _init() -> void:
	var gm = load("res://scripts/autoload/game_manager.gd").new()
	gm.skills = {"espada": {"level": 10, "xp": 100}, "defesa": {"level": 12, "xp": 0}}
	gm.level = 5
	gm.xp = 0
	var need_espada: int = gm.skill_xp_need("espada")
	assert(need_espada == 500)  # 10^2*5
	var need_defesa: int = gm.skill_xp_need("defesa")
	assert(need_defesa == 720)  # 12^2*5
	# espada: falta 400 xp a 240/min = ~1.67min
	var t_espada: String = gm.skill_time_left("espada")
	assert(t_espada == "2min")  # %.0f de 1.67 = 2
	# defesa: falta 720 a 60/min = 12min
	var t_defesa: String = gm.skill_time_left("defesa")
	assert(t_defesa == "12min")
	# level 6 precisa de xp_for_level(6); falta tudo a 450/min
	var need_lvl: int = gm.xp_for_level(6)
	var t_lvl: String = gm.level_time_left()
	assert(t_lvl == gm.fmt_time_min(float(need_lvl) / 450.0))
	# formato de horas
	assert(gm.fmt_time_min(120.0) == "2.0h")
	assert(gm.fmt_time_min(30.0) == "30min")
	assert(gm.fmt_time_min(0.2) == "12s")
	print("ESTIMATE_TEST_OK")
	quit(0)

extends SceneTree
## test_map_check.gd — os mapas carregam em 1024x1024 (nunca o PNG 512 cinza).
## Roda: `godot --headless --path . -s tests/test_map_check.gd` -> MAP_CHECK_OK
##
## O bug historico (PLANO_POLISH_VISUAL.md #1/#2): PNGs de 512x512 num mundo de
## 2048px deixavam 3/4 do cenario cinza. Fix = mapas PROCEDURAIS de 1024 que
## escalam. Este teste trava a regra: nenhum load_map pode voltar <= 512.
## (antes era um script de diagnostico que so imprimia e nunca dizia OK/FAIL)

func _init():
	var fails := 0
	var TH = load("res://scripts/autoload/tex_helper.gd")
	for name in ["city1", "city2", "forest", "rat_cave"]:
		var t = TH.load_map("res://assets/maps/%s.png" % name)
		if t == null:
			print("FALHA %s: mapa nao carregou" % name)
			fails += 1
			continue
		print("%s texture: %dx%d" % [name, t.get_width(), t.get_height()])
		if t.get_width() <= 512 or t.get_height() <= 512:
			print("FALHA %s: mapa pequeno demais (%dx%d) — sobraria area cinza" % [name, t.get_width(), t.get_height()])
			fails += 1
	if fails == 0:
		print("MAP_CHECK_OK")
	else:
		print("MAP_CHECK_FAIL %d" % fails)
	quit()

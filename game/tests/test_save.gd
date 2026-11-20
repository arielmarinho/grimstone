extends SceneTree
## test_save.gd — gravacao ATOMICA e load tolerante a save corrompido (v0.6.42)
## Roda sem autoload: `godot --headless -s tests/test_save.gd`   -> SAVE_TEST_OK
##
## Por que existe (bugs REAIS medidos no ciclo 22:0x):
##  A) save_game() gravava DIRETO no savegame.json. O Android mata o processo a
##     qualquer momento: um kill no meio do store_string deixava o arquivo pela
##     METADE e o save anterior ja tinha sido apagado. Progresso perdido pra
##     sempre. Prova no probe: "load de save TRUNCADO devolveu=false | level=1".
##  B) load_game() fazia int(parsed.get("level", 1)) sem checar tipo: um save com
##     {"level": "muitos"} estourava SCRIPT ERROR (float->Dictionary na linha do
##     skills) e o jogo ficava com estado pela metade.
## O que este teste garante:
##  1. save -> load devolve EXATAMENTE o que foi salvo (roundtrip completo);
##  2. existe .bak da gravacao anterior e ele carrega sozinho se o principal
##     estiver truncado;
##  3. save truncado NO MEIO da escrita nao destroi o save bom (backup responde);
##  4. save com tipos errados carrega sem crash, com defaults sãos;
##  5. mochila/banco/bestiario com lixo nao viram quantidade invalida;
##  6. save antigo (sem campos novos) continua carregando.

const GM_PATH := "res://scripts/autoload/game_manager.gd"

class FakeGM extends "res://scripts/autoload/game_manager.gd":
	pass

var fails := 0
var g


func _check(cond: bool, msg: String) -> void:
	if cond:
		print("  ok   ", msg)
	else:
		fails += 1
		print("  FAIL ", msg)


func _wipe() -> void:
	# usa os CONSTANTES do jogo (o save, o .tmp e o .bak NAO derivam do
	# savegame.json — savegame.tmp / savegame.bak ficam ao lado)
	for p in [g.SAVE_PATH, g.SAVE_TMP, g.SAVE_BAK]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)


func GM_SAVE() -> String:
	return g.SAVE_PATH


func _write(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _init() -> void:
	print("== test_save ==")
	g = FakeGM.new()
	_wipe()

	# ---- 1. roundtrip completo
	g.player_name = "Space Spanker"
	g.level = 42
	g.xp = 7777
	g.coins = 1234
	g.hp_max = g.max_hp_for_level(g.level)
	g.hp = g.hp_max - 13
	g.mana_max = g.max_mana_for_level(g.level)
	g.mana = 41
	g.skills = {"espada": {"level": 33, "xp": 900}, "defesa": {"level": 12, "xp": 4}}
	g.current_map = "city2"
	g.weapon = "sword#3"
	g.arrows = 87
	g.city2_visited = true
	g.city2_unlocked = true
	g.bag = {"espada#2": 1, "pocao_vida_g": 5}
	g.bank = {"flecha": 300}
	g.bestiary = {"rat": 12, "orc": 3}
	g.belt = {"z": "runa_cura", "x": "pocao_mana_p"}
	g.quests = {"ratos": {"progress": 10, "done": true, "claimed": false}}
	g.well_fed_time = 300.0

	g.save_game()
	g.coins = 1234
	g.save_game()  # 2a gravacao: a 1a vira .bak
	var h = FakeGM.new()
	var ok: bool = h.load_game()
	_check(ok, "save -> load devolve true")
	_check(h.player_name == "Space Spanker", "nome preservado")
	_check(h.level == 42 and h.xp == 7777, "level/xp preservados")
	_check(h.coins == 1234 and h.arrows == 87, "moedas/flechas preservadas")
	_check(h.hp == g.hp and h.mana == 41, "hp/mana preservados")
	_check(h.skills["espada"]["level"] == 33 and h.skills["defesa"]["xp"] == 4, "skills preservadas")
	_check(h.weapon == "sword#3", "arma COM raridade preservada (sword#3)")
	_check(h.bag == g.bag, "mochila preservada")
	_check(h.bank == g.bank and h.bestiary == g.bestiary, "banco e bestiario preservados")
	_check(h.belt == g.belt, "cinto preservado")
	_check(h.quests["ratos"]["done"] == true, "quest preservada")
	_check(h.current_map == "city2" and h.city2_unlocked, "mapa/desbloqueio preservados")

	# ---- 2. a gravacao atomica deixou backup
	_check(FileAccess.file_exists(g.SAVE_BAK), "existe .bak da gravacao (2o save em diante)")
	_check(not FileAccess.file_exists(g.SAVE_TMP), "o .tmp foi promovido (nao fica lixo)")

	# ---- 3. save principal TRUNCADO -> cai no backup, sem perder tudo
	var good: String = FileAccess.get_file_as_string(g.SAVE_PATH)
	_write(g.SAVE_PATH, good.substr(0, good.length() / 2))
	var h3 = FakeGM.new()
	var ok3: bool = h3.load_game()
	_check(ok3, "save truncado no meio: load NAO falha (usa o backup)")
	_check(h3.level > 1, "save truncado: progresso recuperado do backup, nao zerado")

	# ---- 4. tipos errados: carrega sem crash, com defaults sãos
	_wipe()
	_write(g.SAVE_PATH, '{"level": "muitos", "coins": null, "hp": -500, "mana": 1e9,'
		+ ' "skills": 5, "bag": [1,2], "bank": "x", "belt": 7, "arrows": "z", "quests": []}')
	var h4 = FakeGM.new()
	var ok4: bool = h4.load_game()
	_check(ok4, "save com tipos errados carrega sem crash")
	_check(h4.level == 1, "level invalido -> 1 (nao 0)")
	_check(h4.coins == 0, "coins null -> 0")
	_check(h4.hp >= 1 and h4.hp <= h4.hp_max, "hp negativo clampeado para dentro do maximo")
	_check(h4.mana <= h4.mana_max, "mana absurda clampeada no maximo")
	_check(h4.skills is Dictionary and h4.skills.has("espada"), "skills lixo -> default com espada")
	_check(h4.bag is Dictionary and h4.bag.is_empty(), "mochila array -> dicionario vazio")
	_check(h4.bank is Dictionary, "banco string -> dicionario")
	_check(h4.belt is Dictionary and h4.belt.has("z"), "cinto numero -> slots vazios")
	_check(h4.arrows == 50, "flechas invalidas -> default 50")
	_check(h4.quests is Dictionary and h4.quests.is_empty(), "quests array -> vazio")

	# ---- 5. mochila com quantidade invalida
	_wipe()
	_write(g.SAVE_PATH, '{"bag": {"espada#2": 3, "lixo": -4, "zero": 0, "txt": "abc"}}')
	var h5 = FakeGM.new()
	h5.load_game()
	_check(h5.bag.get("espada#2", 0) == 3, "item valido sobrevive")
	_check(not h5.bag.has("lixo") and not h5.bag.has("zero"), "quantidade <= 0 descartada")
	_check(h5.bag.get("txt", 0) == 0, "quantidade nao-numerica descartada")

	# ---- 6. save ANTIGO (so os campos da v0.5) continua carregando
	_wipe()
	_write(g.SAVE_PATH, '{"player_name": "Old", "level": 9, "xp": 100, "coins": 50, "weapon": "sword"}')
	var h6 = FakeGM.new()
	var ok6: bool = h6.load_game()
	_check(ok6, "save antigo carrega")
	_check(h6.level == 9 and h6.coins == 50, "save antigo: level/coins lidos")
	_check(h6.bank is Dictionary and h6.bank.is_empty(), "save antigo: banco vazio, sem crash")
	_check(h6.skills.has("espada") and h6.skills.has("defesa"), "save antigo: skills default")
	_check(h6.hp == h6.hp_max, "save antigo: hp cheio no maximo do level")

	# ---- 7. nenhum save
	_wipe()
	var h7 = FakeGM.new()
	_check(not h7.load_game(), "sem arquivo: load devolve false")

	_wipe()
	print("SAVE_TEST_OK" if fails == 0 else "SAVE_TEST_FAIL (%d)" % fails)
	quit(0 if fails == 0 else 1)

extends SceneTree
## Teste unitário das RUNAS (v0.6.7) — roda headless:
##   godot --headless --script tests/test_runes.gd
## Usa FakeGM (membros de classe) porque autoloads não existem em --script puro.
## Esperado no final: RUNE_TEST_OK

const GM = preload("res://scripts/autoload/game_manager.gd")

class FakeGM extends GM:
	pass

func _init() -> void:
	var ok := true
	var g := FakeGM.new()
	# estado limpo
	g.bag = {"runa_fogo": 2, "runa_cura": 1, "runa_gelo": 1, "runa_trovoada": 1}
	g.skills = {"magia": {"level": 10, "xp": 0}}
	g.hp = 50
	g.hp_max = 100
	# 1) runas registradas no RUNAS com efeito valido
	for rid in ["runa_fogo", "runa_gelo", "runa_trovoada", "runa_cura"]:
		if g.RUNAS.get(rid, {}).get("efeito", "") == "":
			print("FALHA: %s sem efeito no RUNAS" % rid); ok = false
	# 2) dano da runa escala com magia: base 60, lvl 10 -> 60*1.2 = 72
	if g.runa_dano("runa_fogo") != 72:
		print("FALHA: runa_dano fogo = %d (esperado 72)" % g.runa_dano("runa_fogo")); ok = false
	# 3) skill de magia maior = mais dano
	g.skills["magia"]["level"] = 50
	if g.runa_dano("runa_fogo") != 120:
		print("FALHA: runa_dano fogo lvl50 = %d (esperado 120)" % g.runa_dano("runa_fogo")); ok = false
	g.skills["magia"]["level"] = 10
	# 4) runa de cura: dano 0, cura 40% do hp_max ao usar
	if g.runa_dano("runa_cura") != 0:
		print("FALHA: runa de cura nao deveria ter dano"); ok = false
	if not g.use_item("runa_cura"):
		print("FALHA: use_item runa_cura"); ok = false
	if g.hp != 90:
		print("FALHA: cura esperava 90, ficou %d" % g.hp); ok = false
	if g.bag.has("runa_cura"):
		print("FALHA: runa de cura nao foi consumida"); ok = false
	# 5) runa de dano e consumida pelo use_item (o HUD aplica o efeito no mundo)
	if not g.use_item("runa_fogo"):
		print("FALHA: use_item runa_fogo"); ok = false
	if g.bag.get("runa_fogo", 0) != 1:
		print("FALHA: runa_fogo nao consumiu (bag=%s)" % g.bag); ok = false
	# 6) usar runa NAO gasta mana
	var mana0: int = g.mana
	if not g.use_item("runa_gelo"):
		print("FALHA: use_item runa_gelo"); ok = false
	if g.mana != mana0:
		print("FALHA: runa gastou mana (%d -> %d)" % [mana0, g.mana]); ok = false
	# 7) runa inexistente: dano 0
	if g.runa_dano("runa_fake") != 0:
		print("FALHA: runa_fake deveria dar dano 0"); ok = false
	if ok:
		print("RUNE_TEST_OK")
	else:
		print("RUNE_TEST_FAIL")
	quit(1 if not ok else 0)

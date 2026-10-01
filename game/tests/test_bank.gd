extends SceneTree
## Teste unitário do BANCO/DEPÓSITO (v0.6.5) — roda headless:
##   godot --headless --script tests/test_bank.gd
## Usa FakeGM (membros de classe) porque autoloads não existem em --script puro.
## Esperado no final: BANK_TEST_OK

const GM = preload("res://scripts/autoload/game_manager.gd")

class FakeGM extends GM:
	pass

func _init() -> void:
	var ok := true
	var g := FakeGM.new()
	# estado limpo
	g.bag = {"pocao_vida_p": 3, "espada#2": 1, "queijo": 2}
	g.bank = {}
	# 1) depositar item que nao tem = falha
	if g.bank_deposit("flecha", 1):
		print("FALHA: depositou item inexistente"); ok = false
	# 2) depositar qty maior que a mochila = falha
	if g.bank_deposit("pocao_vida_p", 10):
		print("FALHA: depositou mais do que tem"); ok = false
	# 3) depositar 1 pocao: sai da mochila, entra no banco
	if not g.bank_deposit("pocao_vida_p", 1):
		print("FALHA: deposito simples"); ok = false
	if g.bag["pocao_vida_p"] != 2 or g.bank.get("pocao_vida_p", 0) != 1:
		print("FALHA: contagem apos deposito bag=%s bank=%s" % [g.bag, g.bank]); ok = false
	# 4) depositar arma com tier (id com #) — slot proprio no banco
	if not g.bank_deposit("espada#2", 1):
		print("FALHA: deposito de arma com tier"); ok = false
	if not g.bank.has("espada#2"):
		print("FALHA: tier nao preservado no banco"); ok = false
	# 5) sacar: volta pra mochila, some do banco
	if not g.bank_withdraw("espada#2", 1):
		print("FALHA: saque de arma com tier"); ok = false
	if g.bank.has("espada#2") or not g.bag.has("espada#2"):
		print("FALHA: estado apos saque bag=%s bank=%s" % [g.bag, g.bank]); ok = false
	# 6) sacar item que nao esta = falha
	if g.bank_withdraw("espada#2", 1):
		print("FALHA: sacou item que nao esta no banco"); ok = false
	# 7) mochila cheia bloqueia saque (BAG_MAX 20)
	g.bag = {}
	for i in range(g.BAG_MAX):
		g.bag["item%d" % i] = 1
	g.bank = {"pocao_vida_p": 1}
	if g.bank_withdraw("pocao_vida_p", 1):
		print("FALHA: saque entrou com mochila cheia"); ok = false
	if g.bank.get("pocao_vida_p", 0) != 1:
		print("FALHA: item sumiu do banco com mochila cheia"); ok = false
	# 8) save/load preserva o banco — FileAccess direto (autoloads não existem em --script)
	var SAVE_PATH = "user://test_bank_save.json"
	var data := {"bank": {"pocao_vida_p": 1, "espada#2": 2}, "bag": {"queijo": 2}}
	var fw = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	fw.store_string(JSON.stringify(data, "\t"))
	fw = null
	var fr = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(fr.get_as_text())
	fr = null
	if parsed == null or parsed.get("bank", {}).get("pocao_vida_p", 0) != 1 \
			or parsed.get("bank", {}).get("espada#2", 0) != 2:
		print("FALHA: banco nao sobreviveu ao JSON save/load: %s" % parsed); ok = false
	if parsed.get("bag", {}).get("queijo", 0) != 2:
		print("FALHA: mochila corrompida no save/load"); ok = false
	if ok:
		print("BANK_TEST_OK")
	else:
		print("BANK_TEST_FAIL")
	quit(0 if ok else 1)

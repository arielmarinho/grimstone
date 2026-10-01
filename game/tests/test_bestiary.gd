extends SceneTree
## Teste unitário do BESTIÁRIO (v0.6.6) — roda headless:
##   godot --headless --script tests/test_bestiary.gd
## Usa FakeGM (membros de classe) porque autoloads não existem em --script puro.
## Esperado no final: BESTIARY_TEST_OK

const GM = preload("res://scripts/autoload/game_manager.gd")

class FakeGM extends GM:
	pass

func _init() -> void:
	var ok := true
	var g := FakeGM.new()
	# estado limpo
	g.bestiary = {}
	# 1) kill simples registra
	g.bestiary_kill("rat")
	if g.bestiary_count("rat") != 1:
		print("FALHA: kill simples nao registrou"); ok = false
	# 2) acumula kills
	for i in range(4):
		g.bestiary_kill("rat")
	if g.bestiary_count("rat") != 5:
		print("FALHA: acumulo de kills (esperado 5, veio %d)" % g.bestiary_count("rat")); ok = false
	# 3) tipo desconhecido conta como 0
	if g.bestiary_count("dragon") != 0:
		print("FALHA: tipo desconhecido deveria ser 0"); ok = false
	# 4) dummy de treino NAO entra no bestiario
	g.bestiary_kill("dummy")
	if g.bestiary_count("dummy") != 0:
		print("FALHA: dummy entrou no bestiario"); ok = false
	# 5) tipo vazio ignorado
	g.bestiary_kill("")
	if not g.bestiary.is_empty() and g.bestiary.has(""):
		print("FALHA: tipo vazio registrou"); ok = false
	# 6) bestiary_seen lista so os vistos, na ordem da ficha
	g.bestiary = {}
	g.bestiary_kill("slime")
	g.bestiary_kill("orc")
	g.bestiary_kill("rat")
	var seen: Array = g.bestiary_seen()
	if seen != ["rat", "slime", "orc"]:
		print("FALHA: bestiary_seen ordem/conteudo errado: %s" % str(seen)); ok = false
	# 7) ficha cobre todos os 8 mobs do jogo (sem dummy)
	if g.BESTIARY_INFO.size() != 8:
		print("FALHA: ficha deveria ter 8 mobs, tem %d" % g.BESTIARY_INFO.size()); ok = false
	for t in ["rat", "slime", "bat", "spider", "wolf", "goblin", "orc", "skeleton"]:
		if not g.BESTIARY_INFO.has(t):
			print("FALHA: ficha sem o mob %s" % t); ok = false
		elif not g.BESTIARY_INFO[t].has("nome") or not g.BESTIARY_INFO[t].has("onde") or not g.BESTIARY_INFO[t].has("desc"):
			print("FALHA: ficha de %s incompleta" % t); ok = false
	# 8) save/load preserva o bestiario (round-trip JSON)
	g.bestiary = {"rat": 12, "skeleton": 3}
	var data := {"bestiary": g.bestiary}
	var parsed = JSON.parse_string(JSON.stringify(data))
	if int(parsed.get("bestiary", {}).get("rat", 0)) != 12:
		print("FALHA: round-trip JSON do bestiario"); ok = false
	if ok:
		print("BESTIARY_TEST_OK")
	else:
		print("BESTIARY_TEST_FALHOU")
	quit(0 if ok else 1)

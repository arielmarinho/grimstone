extends SceneTree
## teste da logica de quests — espelha game_manager.gd com membros de classe
class FakeGM:
	var coins := 0
	var level := 1
	var xp := 0
	var quests := {}
	signal quest_done(id: String)
	const QUESTS := {
		"q_ratos": {"npc": "city1", "tipo": "kill", "alvo": "rat", "qtd": 5,
			"coins": 40, "xp": 100, "desc": "Mate 5 ratos", "req": ""},
		"q_slimes": {"npc": "city1", "tipo": "kill", "alvo": "slime", "qtd": 5,
			"coins": 60, "xp": 180, "desc": "Mate 5 slimes", "req": "q_ratos"},
	}
	func quest_state(id: String) -> Dictionary:
		return quests.get(id, {"progress": 0, "done": false, "claimed": false})
	func quest_available(id: String) -> bool:
		if quests.has(id) and quests[id].get("claimed", false):
			return false
		var q: Dictionary = QUESTS.get(id, {})
		var req: String = q.get("req", "")
		return req == "" or (quests.has(req) and quests[req].get("claimed", false))
	func quest_on_kill(mob_type: String) -> void:
		for id in QUESTS:
			var q: Dictionary = QUESTS[id]
			if q["tipo"] != "kill" or q["alvo"] != mob_type:
				continue
			if not quest_available(id):
				continue
			var st: Dictionary = quests.get(id, {"progress": 0, "done": false, "claimed": false})
			if st.get("done", false):
				continue
			st["progress"] = int(st.get("progress", 0)) + 1
			if st["progress"] >= int(q["qtd"]):
				st["done"] = true
				quest_done.emit(id)
			quests[id] = st
	func quest_claim(id: String) -> bool:
		var q: Dictionary = QUESTS.get(id, {})
		if q.is_empty() or not quests.has(id):
			return false
		var st: Dictionary = quests[id]
		if not st.get("done", false) or st.get("claimed", false):
			return false
		st["claimed"] = true
		quests[id] = st
		coins += int(q.get("coins", 0))
		xp += int(q.get("xp", 0))
		return true
func _init():
	var gm := FakeGM.new()
	var got_done := [""]
	gm.quest_done.connect(func(id): got_done[0] = id)
	# quest 1 disponivel, quest 2 bloqueada pela cadeia
	assert(gm.quest_available("q_ratos") == true)
	assert(gm.quest_available("q_slimes") == false)
	# matar 4 ratos: ainda incompleta
	for i in range(4):
		gm.quest_on_kill("rat")
	assert(gm.quest_state("q_ratos")["progress"] == 4)
	assert(gm.quest_state("q_ratos")["done"] == false)
	# 5o rato completa e emite o sinal
	gm.quest_on_kill("rat")
	assert(gm.quest_state("q_ratos")["done"] == true)
	assert(got_done[0] == "q_ratos")
	# matar mais ratos NAO progride (ja done)
	gm.quest_on_kill("rat")
	assert(gm.quest_state("q_ratos")["progress"] == 5)
	# done mas NAO entregue: AINDA disponivel (pra entregar no NPC)
	assert(gm.quest_available("q_ratos") == true)
	# entregar: moedas + xp; entrega dupla falha
	assert(gm.quest_claim("q_ratos") == true)
	assert(gm.coins == 40 and gm.xp == 100)
	assert(gm.quest_claim("q_ratos") == false)
	assert(gm.coins == 40)
	# cadeia liberada apos entrega
	assert(gm.quest_available("q_slimes") == true)
	# quest de outro mob nao progride a errada
	gm.quest_on_kill("rat")
	assert(gm.quest_state("q_slimes")["progress"] == 0)
	# completar q_slimes
	for i in range(5):
		gm.quest_on_kill("slime")
	assert(gm.quest_claim("q_slimes") == true)
	assert(gm.coins == 100 and gm.xp == 280)
	# quests desaparecem depois de entregues
	assert(gm.quest_available("q_ratos") == false)
	assert(gm.quest_available("q_slimes") == false)
	print("QUEST_TEST_OK")
	quit(0)

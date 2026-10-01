extends Node
## GameManager — autoload: estado global do jogo (serializável, pronto pra online futuro)

const SAVE_PATH = "user://savegame.json"
const BAG_MAX = 20

var player_name: String = "Grimstone"
var level: int = 1
var xp: int = 0
var hp: int = 100
var hp_max: int = 100
var mana: int = 50
var mana_max: int = 50
var skills := {
	"espada": {"level": 10, "xp": 0},
	"defesa": {"level": 10, "xp": 0},
}
var current_map: String = "city1"
var coins: int = 0
var bag := {}
var weapon: String = "sword"
var hair_color: String = "castanho"
var tunic_color: String = "castanho"
var pants_color: String = "marrom"
var arrows: int = 50
var city2_visited: bool = false  # R/G skills desbloqueiam ao chegar na VILA
var city2_unlocked: bool = false
var quests := {}  # id -> {"progress": int, "done": bool, "claimed": bool}

signal quest_done(id: String)

## quests de caca (estilo Tibia/Rucoy): NPC das cidades entrega moedas+xp por matar mobs
## cadeia: cada quest exige a anterior entregue (req)
const QUESTS := {
	"q_ratos": {"npc": "city1", "tipo": "kill", "alvo": "rat", "qtd": 5,
		"coins": 40, "xp": 100, "desc": "Mate 5 ratos no bueiro", "req": ""},
	"q_slimes": {"npc": "city1", "tipo": "kill", "alvo": "slime", "qtd": 5,
		"coins": 60, "xp": 180, "desc": "Mate 5 slimes no bueiro", "req": "q_ratos"},
	"q_aranhas": {"npc": "city2", "tipo": "kill", "alvo": "spider", "qtd": 5,
		"coins": 100, "xp": 350, "desc": "Mate 5 aranhas na floresta", "req": "q_slimes"},
	"q_goblins": {"npc": "city2", "tipo": "kill", "alvo": "goblin", "qtd": 5,
		"coins": 140, "xp": 500, "desc": "Mate 5 goblins na floresta", "req": "q_aranhas"},
	"q_orcs": {"npc": "city2", "tipo": "kill", "alvo": "orc", "qtd": 4,
		"coins": 250, "xp": 900, "desc": "Mate 4 orcs na floresta", "req": "q_goblins"},
	"q_esqueletos": {"npc": "city2", "tipo": "kill", "alvo": "skeleton", "qtd": 4,
		"coins": 250, "xp": 900, "desc": "Mate 4 esqueletos na floresta", "req": "q_orcs"},
}

func quest_state(id: String) -> Dictionary:
	return quests.get(id, {"progress": 0, "done": false, "claimed": false})

func quest_available(id: String) -> bool:
	if quests.has(id) and quests[id].get("done", false):
		return false  # aceita/entregue: nao aparece de novo
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
	add_xp(int(q.get("xp", 0)))
	return true

const RARITY = preload("res://scripts/autoload/rarity.gd")

const FUSION_COST := 50

## fusao de itens: 3 iguais do mesmo tier -> 1 do tier seguinte (custa FUSION_COST; lendario nao funde)
func can_fuse(id: String) -> bool:
	var tier := RARITY.tier_of(id)
	return tier < RARITY.TIERS.size() - 1 and bag.get(id, 0) >= 3 and coins >= FUSION_COST

func fuse_item(id: String) -> bool:
	var tier := RARITY.tier_of(id)
	if tier >= RARITY.TIERS.size() - 1:
		return false
	if bag.get(id, 0) < 3 or coins < FUSION_COST:
		return false
	if not remove_item(id, 3):
		return false
	coins -= FUSION_COST
	add_item(RARITY.key_with_tier(id.split("#")[0], tier + 1), 1)
	return true

## arma equipada pode ser "espada#2" (tier de raridade) — dano multiplicado pelo tier
func weapon_base() -> String:
	return weapon.split("#")[0]

func weapon_tier() -> int:
	return RARITY.tier_of(weapon)

func weapon_dano_mult() -> float:
	return RARITY.dano_mult(weapon_tier())

func EQUIPS_OK(w: String) -> bool:
	var base: String = w.split("#")[0]
	var eq = preload("res://scripts/autoload/equips.gd")
	return eq.WEAPONS.has(base)

func xp_for_level(lv: int) -> int:
	return int(50.0 / 3.0 * (pow(lv, 3) - 6 * pow(lv, 2) + 17 * lv - 12))

# --- estimativas de tempo (tela K) ---
# taxas medias medidas no jogo: golpe basico = 4 xp de skill por hit (~1 hit/s farmando) -> ~240 xp/min
# defesa = 2 xp por dano tomado (~1 hit tomado a cada 2s) -> ~60 xp/min
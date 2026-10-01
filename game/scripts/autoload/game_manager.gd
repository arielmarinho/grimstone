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

func xp_for_level(lv: int) -> int:
	return int(50.0 / 3.0 * (pow(lv, 3) - 6 * pow(lv, 2) + 17 * lv - 12))

# stats derivados do level (fonte unica de verdade — save antigo nunca mais desincroniza)
func max_hp_for_level(lv: int) -> int:
	return 100 + (lv - 1) * 10

func max_mana_for_level(lv: int) -> int:
	return 50 + (lv - 1) * 5

func add_xp(amount: int) -> void:
	xp += amount
	while level < 999 and xp >= xp_for_level(level + 1):
		level += 1
		hp_max = max_hp_for_level(level)
		mana_max = max_mana_for_level(level)
		# estilo Tibia: level up NAO enche vida/mana se o player esta em combate
		# (evita "heal gratis" no meio do fight); fora de combate enche normal
		var in_combat := false
		for m in get_tree().get_nodes_in_group("mobs"):
			if is_instance_valid(m) and not m.dead and not m.dying and m.state == "attack":
				in_combat = true
				break
		if not in_combat:
			hp = hp_max
			mana = mana_max
		else:
			hp = min(hp_max, hp + 30)
			mana = min(mana_max, mana + 15)
		print("LEVEL UP! Nivel ", level)

func add_skill_xp(skill: String, amount: int) -> void:
	if not skills.has(skill):
		skills[skill] = {"level": 10, "xp": 0}
	skills[skill]["xp"] += amount
	# curva Tibia: custo cresce com o nivel (lvl^2 * 5) — skill up rapido no inicio, lento no fim
	var need = skills[skill]["level"] * skills[skill]["level"] * 5
	while skills[skill]["xp"] >= need:
		skills[skill]["xp"] -= need
		skills[skill]["level"] += 1
		need = skills[skill]["level"] * skills[skill]["level"] * 5
		print("SKILL UP: ", skill, " nivel ", skills[skill]["level"])

func add_item(id: String, qty: int = 1) -> bool:
	if bag.has(id):
		bag[id] += qty
		return true
	if bag.size() >= BAG_MAX:
		return false
	bag[id] = qty
	return true

func remove_item(id: String, qty: int = 1) -> bool:
	if not bag.has(id) or bag[id] < qty:
		return false
	bag[id] -= qty
	if bag[id] <= 0:
		bag.erase(id)
	return true

func use_item(id: String) -> bool:
	var db = preload("res://scripts/autoload/items_db.gd")
	var it = db.ITEMS.get(id, null)
	if it == null or not remove_item(id):
		return false
	if it.get("tipo", "") == "uso":
		if it.has("hp"):
			hp = min(hp_max, hp + it["hp"])
		if it.has("mana"):
			mana = min(mana_max, mana + it["mana"])
	return true

func save_game() -> void:
	var data := {
		"player_name": player_name, "level": level, "xp": xp,
		"hp": hp, "hp_max": hp_max, "mana": mana, "mana_max": mana_max,
		"skills": skills, "current_map": current_map,
		"weapon": weapon, "hair_color": hair_color, "tunic_color": tunic_color,
		"pants_color": pants_color, "arrows": arrows, "city2_visited": city2_visited,
		"coins": coins, "bag": bag, "city2_unlocked": city2_unlocked,
	}
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed == null:
		return false
	player_name = parsed.get("player_name", "Grimstone")
	level = int(parsed.get("level", 1))
	xp = int(parsed.get("xp", 0))
	hp_max = max_hp_for_level(level)  # derivado do level — save antigo nunca desincroniza
	hp = min(int(parsed.get("hp", hp_max)), hp_max)
	mana_max = max_mana_for_level(level)
	mana = min(int(parsed.get("mana", mana_max)), mana_max)
	skills = parsed.get("skills", skills)
	current_map = parsed.get("current_map", "city1")
	weapon = parsed.get("weapon", "sword")
	coins = int(parsed.get("coins", 0))
	bag = parsed.get("bag", {})
	hair_color = parsed.get("hair_color", "castanho")
	tunic_color = parsed.get("tunic_color", "castanho")
	pants_color = parsed.get("pants_color", "marrom")
	arrows = int(parsed.get("arrows", 50))
	city2_visited = bool(parsed.get("city2_visited", false))
	city2_unlocked = bool(parsed.get("city2_unlocked", false))
	return true

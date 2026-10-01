extends Node
## GameManager — estado global (serializável, pronto pra online futuro)

const SAVE_PATH = "user://savegame.json"

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

func xp_for_level(lv: int) -> int:
	return int(50.0 / 3.0 * (pow(lv, 3) - 6 * pow(lv, 2) + 17 * lv - 12))

func add_xp(amount: int) -> void:
	xp += amount
	while level < 999 and xp >= xp_for_level(level + 1):
		level += 1
		hp_max += 10
		mana_max += 5
		hp = hp_max
		mana = mana_max
		print("LEVEL UP! Nivel ", level)

func add_skill_xp(skill: String, amount: int) -> void:
	if not skills.has(skill):
		skills[skill] = {"level": 10, "xp": 0}
	skills[skill]["xp"] += amount
	var need = skills[skill]["level"] * 100
	while skills[skill]["xp"] >= need:
		skills[skill]["xp"] -= need
		skills[skill]["level"] += 1
		need = skills[skill]["level"] * 100
		print("SKILL UP: ", skill, " nivel ", skills[skill]["level"])

func save_game() -> void:
	var data := {
		"player_name": player_name, "level": level, "xp": xp,
		"hp": hp, "hp_max": hp_max, "mana": mana, "mana_max": mana_max,
		"skills": skills, "current_map": current_map,
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
	hp = int(parsed.get("hp", 100))
	hp_max = int(parsed.get("hp_max", 100))
	mana = int(parsed.get("mana", 50))
	mana_max = int(parsed.get("mana_max", 50))
	skills = parsed.get("skills", skills)
	current_map = parsed.get("current_map", "city1")
	return true

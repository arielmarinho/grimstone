extends Node
## Loot tables por tipo de monstro (Tibia-style: raridade por valor)

const RARITY = preload("res://scripts/autoload/rarity.gd")
const ITEMS_DB = preload("res://scripts/autoload/items_db.gd")

const TABLES = {
	"rat": [
		{"id": "moeda", "chance": 1.0, "min": 3, "max": 8},
		{"id": "carne", "chance": 0.5, "min": 1, "max": 1},
		{"id": "queijo", "chance": 0.3, "min": 1, "max": 1},
		{"id": "pocao_vida_p", "chance": 0.15, "min": 1, "max": 1},
		{"id": "flecha", "chance": 0.2, "min": 1, "max": 3},
	],
	"slime": [
		{"id": "moeda", "chance": 1.0, "min": 5, "max": 12},
		{"id": "pocao_vida_p", "chance": 0.25, "min": 1, "max": 1},
		{"id": "pocao_mana_p", "chance": 0.15, "min": 1, "max": 1},
		{"id": "runa_cura", "chance": 0.04, "min": 1, "max": 1},
		{"id": "flecha", "chance": 0.2, "min": 1, "max": 3},
	],
	"bat": [
		{"id": "moeda", "chance": 1.0, "min": 6, "max": 14},
		{"id": "peixe", "chance": 0.25, "min": 1, "max": 1},
		{"id": "pocao_mana_p", "chance": 0.3, "min": 1, "max": 1},
		{"id": "flecha", "chance": 0.3, "min": 2, "max": 4},
	],
	"spider": [
		{"id": "moeda", "chance": 1.0, "min": 14, "max": 28},
		{"id": "pocao_vida_p", "chance": 0.4, "min": 1, "max": 2},
		{"id": "pocao_mana_p", "chance": 0.25, "min": 1, "max": 1},
		{"id": "flecha", "chance": 0.25, "min": 2, "max": 5},
	],
	"wolf": [
		{"id": "moeda", "chance": 1.0, "min": 28, "max": 55},
		{"id": "pocao_vida_m", "chance": 0.5, "min": 1, "max": 2},
		{"id": "carne", "chance": 0.7, "min": 1, "max": 2},
		{"id": "peixe", "chance": 0.2, "min": 1, "max": 1},
		{"id": "machado", "chance": 0.08, "min": 1, "max": 1},
	],
	"goblin": [
		{"id": "moeda", "chance": 1.0, "min": 20, "max": 40},
		{"id": "pocao_vida_p", "chance": 0.3, "min": 1, "max": 1},
		{"id": "pocao_vida_m", "chance": 0.12, "min": 1, "max": 1},
		{"id": "runa_trovoada", "chance": 0.05, "min": 1, "max": 1},
		{"id": "flecha", "chance": 0.35, "min": 2, "max": 5},
		{"id": "espada", "chance": 0.06, "min": 1, "max": 1},
	],
	"orc": [
		{"id": "moeda", "chance": 1.0, "min": 40, "max": 80},
		{"id": "pocao_vida_m", "chance": 0.5, "min": 1, "max": 2},
		{"id": "pocao_vida_g", "chance": 0.1, "min": 1, "max": 1},
		{"id": "machado", "chance": 0.1, "min": 1, "max": 1},
	],
	"skeleton": [
		{"id": "moeda", "chance": 1.0, "min": 35, "max": 70},
		{"id": "pocao_mana_m", "chance": 0.4, "min": 1, "max": 1},
		{"id": "pocao_mana_g", "chance": 0.1, "min": 1, "max": 1},
		{"id": "flecha", "chance": 0.4, "min": 3, "max": 6},
		{"id": "runa_fogo", "chance": 0.08, "min": 1, "max": 1},
		{"id": "runa_gelo", "chance": 0.06, "min": 1, "max": 1},
		{"id": "cajado", "chance": 0.08, "min": 1, "max": 1},
	],
}

static func roll_drop(mob_type: String, pos: Vector2, parent: Node) -> void:
	var table: Array = TABLES.get(mob_type, TABLES["rat"])
	var drop_scene = load("res://scripts/entities/drop.gd")
	# bonus de raridade por mob: mobs fortes dropam tiers mais altos
	var rb: int = RARITY_BONUS.get(mob_type, 0)
	for entry in table:
		if randf() <= entry["chance"]:
			var d = drop_scene.new()
			var id: String = entry["id"]
			# armas dropadas ganham tier de raridade sorteado
			if ITEMS_DB.ITEMS.get(id, {}).get("tipo", "") == "arma":
				id = RARITY.key_with_tier(id, RARITY.roll_tier(rb))
			d.setup(id, randi_range(entry["min"], entry["max"]))
			d.position = pos + Vector2(randf() * 72 - 36, randf() * 72 - 36)
			parent.add_child(d)

# ---------- MULTIPLAYER: loot serializável ----------
# bonus de raridade por mob (mobs fortes = tiers mais altos nas armas dropadas)
const RARITY_BONUS = {
	"rat": 0, "slime": 0, "bat": 0,
	"spider": 1, "goblin": 1, "wolf": 2,
	"orc": 3, "skeleton": 3,
}

static func roll_loot_list(mob_type: String) -> Array:
	# sorteia e devolve [{id, qty}] — vai por RPC pro cliente que matou
	var table: Array = TABLES.get(mob_type, TABLES["rat"])
	var rb: int = RARITY_BONUS.get(mob_type, 0)
	var out: Array = []
	for entry in table:
		if randf() <= entry["chance"]:
			var id: String = entry["id"]
			if ITEMS_DB.ITEMS.get(id, {}).get("tipo", "") == "arma":
				id = RARITY.key_with_tier(id, RARITY.roll_tier(rb))
			out.append({"id": id, "qty": randi_range(entry["min"], entry["max"])})
	return out

static func spawn_loot_list(loot: Array, pos: Vector2, parent: Node) -> void:
	# cliente: cria os drops/moedas a partir da lista recebida
	var drop_scene = load("res://scripts/entities/drop.gd")
	for entry in loot:
		var d = drop_scene.new()
		d.setup(entry["id"], entry["qty"])
		d.position = pos + Vector2(randf() * 72 - 36, randf() * 72 - 36)
		parent.add_child(d)

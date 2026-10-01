extends Node2D
## Loot tables por tipo de monstro (Tibia-style: raridade por valor)

const TABLES = {
	"rat": [
		{"id": "moeda", "chance": 1.0, "min": 3, "max": 8},
		{"id": "carne", "chance": 0.5, "min": 1, "max": 1},
		{"id": "pocao_vida", "chance": 0.15, "min": 1, "max": 1},
	],
	"slime": [
		{"id": "moeda", "chance": 1.0, "min": 5, "max": 12},
		{"id": "pocao_vida", "chance": 0.25, "min": 1, "max": 1},
		{"id": "pocao_mana", "chance": 0.15, "min": 1, "max": 1},
	],
	"bat": [
		{"id": "moeda", "chance": 1.0, "min": 6, "max": 14},
		{"id": "pocao_mana", "chance": 0.3, "min": 1, "max": 1},
	],
	"spider": [
		{"id": "moeda", "chance": 1.0, "min": 12, "max": 25},
		{"id": "pocao_vida", "chance": 0.4, "min": 1, "max": 2},
		{"id": "pocao_mana", "chance": 0.25, "min": 1, "max": 1},
	],
	"wolf": [
		{"id": "moeda", "chance": 1.0, "min": 20, "max": 40},
		{"id": "pocao_vida", "chance": 0.5, "min": 1, "max": 2},
		{"id": "carne", "chance": 0.7, "min": 1, "max": 2},
		{"id": "machado", "chance": 0.08, "min": 1, "max": 1},
	],
}

static func roll_drop(mob_type: String, pos: Vector2, parent: Node) -> void:
	var table: Array = TABLES.get(mob_type, TABLES["rat"])
	var drop_scene = load("res://scripts/entities/drop.gd")
	for entry in table:
		if randf() <= entry["chance"]:
			var d = drop_scene.new()
			d.setup(entry["id"], randi_range(entry["min"], entry["max"]))
			d.position = pos + Vector2(randf() * 72 - 36, randf() * 72 - 36)
			parent.add_child(d)

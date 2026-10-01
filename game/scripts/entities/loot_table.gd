extends Node2D
## Loot do rato — moedas + carne + ocasional pocao (estilo Rucoy)

const DROP_TABLE = [
	{"id": "moeda", "chance": 1.0, "min": 3, "max": 8},
	{"id": "carne", "chance": 0.5, "min": 1, "max": 1},
	{"id": "pocao_vida", "chance": 0.15, "min": 1, "max": 1},
]

static func roll_drop(pos: Vector2, parent: Node) -> void:
	var drop_scene = load("res://scripts/entities/drop.gd")
	for entry in DROP_TABLE:
		if randf() <= entry["chance"]:
			var d = drop_scene.new()
			d.setup(entry["id"], randi_range(entry["min"], entry["max"]))
			d.position = pos + Vector2(randf() * 36 - 18, randf() * 36 - 18)
			parent.add_child(d)

extends Node2D
## Spawners de mobs por mapa — cada tipo no SEU mapa, sempre em PARES (2 iguais)

var spawner_name: String = ""
var safe_zone: bool = false
var map_name: String = ""

const SETS = {
	"city1_mobs": [
		{"type": "rat", "pos": Vector2(700, 1500)},
		{"type": "rat", "pos": Vector2(900, 1500)},
		{"type": "slime", "pos": Vector2(1400, 1400)},
		{"type": "slime", "pos": Vector2(1600, 1400)},
	],
	"cave_mobs": [
		{"type": "rat", "pos": Vector2(600, 700)},
		{"type": "rat", "pos": Vector2(800, 700)},
		{"type": "rat", "pos": Vector2(1200, 1100)},
		{"type": "rat", "pos": Vector2(1400, 1100)},
		{"type": "rat", "pos": Vector2(900, 1600)},
		{"type": "rat", "pos": Vector2(1100, 1600)},
	],
	"city2_mobs": [
		{"type": "dummy", "pos": Vector2(1024, 1300)},
	],
	"forest_mobs": [
		{"type": "wolf", "pos": Vector2(600, 700)},
		{"type": "wolf", "pos": Vector2(800, 700)},
		{"type": "spider", "pos": Vector2(700, 1400)},
		{"type": "spider", "pos": Vector2(900, 1400)},
		{"type": "goblin", "pos": Vector2(1500, 900)},
		{"type": "goblin", "pos": Vector2(1700, 900)},
		{"type": "orc", "pos": Vector2(1000, 1800)},
		{"type": "orc", "pos": Vector2(1200, 1800)},
	],
}

func _ready() -> void:
	if NetworkManager.is_online() and not NetworkManager.is_server:
		return
	var mob_scene: PackedScene = load("res://scenes/entities/mobs/rat.tscn")
	for entry in SETS.get(spawner_name, []):
		if safe_zone and entry["type"] != "dummy":
			continue
		var mob = mob_scene.instantiate()
		mob.mob_type = entry["type"]
		mob.position = entry["pos"]
		add_child(mob)

extends Node2D
## Spawners de mobs por mapa — mobs diferentes em cada regiao

var spawner_name: String = ""

# posicoes em coordenadas de mundo 2X (mapa 1024 desenhado a escala 2)
const SETS = {
	"city1_mobs": [
		{"type": "rat", "pos": Vector2(400, 500)},
		{"type": "rat", "pos": Vector2(1700, 400)},
		{"type": "slime", "pos": Vector2(400, 1500)},
		{"type": "slime", "pos": Vector2(1700, 1700)},
	],
	"city2_mobs": [
		{"type": "dummy", "pos": Vector2(1024, 1300)},  # alvo de treino (perto do centro-sul)
		{"type": "bat", "pos": Vector2(500, 400)},
		{"type": "bat", "pos": Vector2(1600, 500)},
		{"type": "spider", "pos": Vector2(500, 1600)},
		{"type": "goblin", "pos": Vector2(1600, 1600)},
	],
	"forest_mobs": [
		{"type": "wolf", "pos": Vector2(500, 700)},
		{"type": "wolf", "pos": Vector2(1500, 900)},
		{"type": "spider", "pos": Vector2(700, 1500)},
		{"type": "goblin", "pos": Vector2(1400, 1600)},
		{"type": "goblin", "pos": Vector2(1700, 500)},
		{"type": "orc", "pos": Vector2(1000, 1800)},
	],
	"cave_mobs": [
		{"type": "rat", "pos": Vector2(600, 600)},
		{"type": "rat", "pos": Vector2(1200, 700)},
		{"type": "bat", "pos": Vector2(1000, 1100)},
		{"type": "spider", "pos": Vector2(700, 1400)},
		{"type": "skeleton", "pos": Vector2(1500, 1300)},
		{"type": "skeleton", "pos": Vector2(1700, 800)},
	],
}

func _ready() -> void:
	var mob_scene: PackedScene = load("res://scenes/entities/mobs/rat.tscn")
	for entry in SETS.get(spawner_name, []):
		var mob = mob_scene.instantiate()
		mob.mob_type = entry["type"]
		mob.position = entry["pos"]
		add_child(mob)

extends Node2D
## Spawners de mobs por mapa — mobs diferentes em cada regiao
## safe_zone (city2): so o dummy de treino spawna; mobs agressivos ficam fora

var spawner_name: String = ""
var safe_zone: bool = false
var map_name: String = ""  # mapa deste spawner (servidor precisa saber pra IA online)

# posicoes em coordenadas de mundo 2X (mapa 1024 desenhado a escala 2)
# TODAS as posicoes ficam FORA do alcance de aggro (280px) do spawn do player
const SETS = {
	# CITY1 (hub): ratos perto do portao sul/bueiro, slimes no lago — 2 de cada
	"city1_mobs": [
		{"type": "rat", "pos": Vector2(700, 1500)},
		{"type": "rat", "pos": Vector2(900, 1500)},
		{"type": "slime", "pos": Vector2(1400, 1400)},
		{"type": "slime", "pos": Vector2(1600, 1400)},
	],
	# CAVERNA (bueiro): SOMENTE ratos — 3 pares espalhados
	"cave_mobs": [
		{"type": "rat", "pos": Vector2(600, 700)},
		{"type": "rat", "pos": Vector2(800, 700)},
		{"type": "rat", "pos": Vector2(1200, 1100)},
		{"type": "rat", "pos": Vector2(1400, 1100)},
		{"type": "rat", "pos": Vector2(900, 1600)},
		{"type": "rat", "pos": Vector2(1100, 1600)},
	],
	# CITY2 (vila ana): zona segura — so o dummy de treino
	"city2_mobs": [
		{"type": "dummy", "pos": Vector2(1024, 1300)},
	],
	# FLORESTA: lobos no norte, aranhas no centro, goblins no leste, orcs no sul — 2 de cada
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
	# cliente online: NAO instancia mobs — espelhos vem do servidor (mob_state)
	if NetworkManager.is_online() and not NetworkManager.is_server:
		return
	var mob_scene: PackedScene = load("res://scenes/entities/mobs/rat.tscn")
	for entry in SETS.get(spawner_name, []):
		# zona segura: so o dummy de treino (imortal, nao revida) pode existir nela
		if safe_zone and entry["type"] != "dummy":
			continue
		var mob = mob_scene.instantiate()
		mob.mob_type = entry["type"]
		mob.position = entry["pos"]
		mob._net_map = map_name
		add_child(mob)

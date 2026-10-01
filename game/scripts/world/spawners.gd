extends Node2D
## Spawners de mobs por mapa — mobs diferentes em cada regiao
## safe_zone (city2): so o dummy de treino spawna; mobs agressivos ficam fora
## SPAWN RELATIVO AO PLAYER (estilo Rucoy): mobs nascem em anel FORA da tela

var spawner_name: String = ""
var safe_zone: bool = false
var map_name: String = ""  # mapa deste spawner (servidor precisa saber pra IA online)

# posicoes em coordenadas de mundo 2X (mapa 1024 desenhado a escala 2)
# base de cada tipo (mantem mobs na sua regiao do mapa)
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
	var player = _get_player()
	for entry in SETS.get(spawner_name, []):
		# zona segura: so o dummy de treino (imortal, nao revida) pode existir nela
		if safe_zone and entry["type"] != "dummy":
			continue
		var mob = mob_scene.instantiate()
		mob.mob_type = entry["type"]
		# SPAWN RELATIVO AO PLAYER (estilo Rucoy): mobs nascem em anel FORA da tela
		# (raio 500-700px) ao redor do player — nunca dentro da visao dele.
		# Sem player (servidor dedicado): usa a posicao fixa do SETS.
		if player != null:
			mob.position = _spawn_pos_near(player.global_position, entry["pos"])
		else:
			mob.position = entry["pos"]
		mob._net_map = map_name
		add_child(mob)

# anel de spawn ao redor do player: raio 500-700 (fora da tela com zoom 1.2),
# clampado dentro do mapa (120..1928) e perto da posicao-base do tipo
func _spawn_pos_near(player_pos: Vector2, base_pos: Vector2) -> Vector2:
	for attempt in range(12):
		var ang = randf() * TAU
		var r = 500.0 + randf() * 200.0
		var p = player_pos + Vector2(cos(ang), sin(ang)) * r
		p = p.clamp(Vector2(120, 120), Vector2(1928, 1928))
		# nao muito longe da base do tipo (mantem cada mob na sua regiao)
		if p.distance_to(base_pos) < 900.0:
			return p
	return base_pos

func _get_player():
	var nodes = get_tree().get_nodes_in_group("player")
	return nodes[0] if nodes.size() > 0 else null

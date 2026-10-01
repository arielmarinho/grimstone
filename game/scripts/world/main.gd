extends Node2D
## Main — 4 mapas: city1 (hub), city2 (leste), forest (sul da city2), rat_cave (bueiro)
## Lojas nas 2 cidades, mobs por mapa, transicoes por portoes
## CITY2: ao pisar pela 1a vez desbloqueia as skills avancadas (R/G)

const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")
const COLLIDERS = preload("res://scripts/world/colliders.gd")

const MAPS = {
	"city1": {
		"texture": "res://assets/maps/city1.png",
		"player_spawn": Vector2(1024, 1240),
		"exits": [
			{"pos": Vector2(1024, 1600), "radius": 84, "to": "rat_cave", "label": "BUEIRO ↓"},
			{"pos": Vector2(1990, 1024), "radius": 84, "to": "city2", "label": "VILA →"},
		],
		"shop": Vector2(580, 1340),
		"spawner": "city1_mobs",
	},
	"city2": {
		"texture": "res://assets/maps/city2.png",
		"player_spawn": Vector2(260, 1024),
		"exits": [
			{"pos": Vector2(60, 1024), "radius": 84, "to": "city1", "label": "← CIDADE"},
			{"pos": Vector2(1024, 1990), "radius": 84, "to": "forest", "label": "FLORESTA ↓"},
		],
		"shop": Vector2(1560, 660),
		"spawner": "city2_mobs",
	},
	"forest": {
		"texture": "res://assets/maps/forest.png",
		"player_spawn": Vector2(1024, 260),
		"exits": [
			{"pos": Vector2(1024, 60), "radius": 84, "to": "city2", "label": "↑ VILA"},
		],
		"spawner": "forest_mobs",
	},
	"rat_cave": {
		"texture": "res://assets/maps/rat_cave.png",
		"player_spawn": Vector2(1024, 800),
		"exits": [
			{"pos": Vector2(1024, 180), "radius": 84, "to": "city1", "label": "SAÍDA ↑"},
		],
		"spawner": "cave_mobs",
	},
}

@onready var map_layer: Node2D = $MapLayer
@onready var entities: Node2D = $Entities

var player: CharacterBody2D = null
var current: String = ""
var switching: bool = false
var _respawning: bool = false
var shop: Node2D = null

func _ready() -> void:
	GameManager.load_game()
	_create_player()
	switch_map(GameManager.current_map if GameManager.current_map in MAPS else "city1")
	if player != null:
		player.weapon = GameManager.weapon
		player.hair_color = GameManager.hair_color
		player.tunic_color = GameManager.tunic_color
		player.pants_color = GameManager.pants_color
		player._build_frames()
	$HUD.set_player(player)

func _create_player() -> void:
	var pscene: PackedScene = load("res://scenes/entities/player/player.tscn")
	if pscene == null:
		push_error("GRAVE: player.tscn nao carregou — verifique o arquivo")
		return
	player = pscene.instantiate()
	player.name = "Player"
	add_child(player)
	player.position = Vector2(1024, 1240)

func _physics_process(_delta: float) -> void:
	if switching or player == null:
		return
	if player.dead:
		if not _respawning:
			_respawning = true
			await get_tree().create_timer(3.0).timeout
			if is_instance_valid(player) and player.dead:
				GameManager.hp = GameManager.hp_max
				GameManager.mana = GameManager.mana_max
				player.dead = false
				player._play("idle")
				switch_map("city1")
			_respawning = false
		return
	for ex in MAPS[current].get("exits", []):
		if player.global_position.distance_to(ex["pos"]) < ex["radius"]:
			switching = true
			switch_map(ex["to"])
			switching = false
			return
	if shop != null and MAPS[current].has("shop"):
		var near = player.global_position.distance_to(MAPS[current]["shop"]) < 120.0
		if near and not shop.is_open() and Input.is_key_pressed(KEY_E):
			shop.open()
		elif not near and shop.is_open():
			shop.close()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and shop != null and shop.is_open():
			shop.close()

func _unlock_city2() -> void:
	if GameManager.city2_unlocked:
		return
	GameManager.city2_unlocked = true
	GameManager.save_game()
	if player != null:
		var l = Label.new()
		l.text = "NOVAS SKILLS DESBLOQUEADAS! (teclas R e G — veja na tela K)"
		l.position = player.global_position + Vector2(-260, -140)
		l.add_theme_font_size_override("font_size", 17)
		l.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
		l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		l.add_theme_constant_override("outline_size", 5)
		l.z_index = 60
		add_child(l)
		var tw = l.create_tween()
		tw.tween_interval(4.0)
		tw.tween_property(l, "modulate:a", 0.0, 1.0)
		tw.tween_callback(l.queue_free)
	print("CITY2: skills avancadas (R/G) desbloqueadas!")

func switch_map(name: String) -> void:
	if name == current or not MAPS.has(name):
		return
	current = name
	GameManager.current_map = name
	if name == "city2":
		_unlock_city2()
	for c in map_layer.get_children():
		c.queue_free()
	var sprite = Sprite2D.new()
	sprite.texture = TEXHELPER.load_map(MAPS[name]["texture"])
	sprite.centered = false
	sprite.scale = Vector2(2, 2)
	map_layer.add_child(sprite)
	if player != null:
		player.global_position = MAPS[name]["player_spawn"]
	for mob in get_tree().get_nodes_in_group("mobs"):
		mob.queue_free()
	var spawner_name = MAPS[name].get("spawner", "")
	if spawner_name != "":
		var spawner = load("res://scripts/world/spawners.gd")
		var node = spawner.new()
		node.spawner_name = spawner_name
		entities.add_child(node)
	COLLIDERS.build_colliders(name, map_layer)
	for ex in MAPS[current].get("exits", []):
		var marker = Label.new()
		marker.text = ex["label"]
		marker.position = ex["pos"] + Vector2(-45, -95)
		marker.add_theme_font_size_override("font_size", 16)
		marker.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
		marker.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		marker.add_theme_constant_override("outline_size", 4)
		map_layer.add_child(marker)
		var tw = marker.create_tween()
		tw.set_loops()
		tw.tween_property(marker, "position:y", marker.position.y - 8.0, 0.6)
		tw.tween_property(marker, "position:y", marker.position.y, 0.6)
	if shop != null:
		shop.queue_free()
		shop = null
	if MAPS[current].has("shop"):
		shop = load("res://scripts/world/shop.gd").new()
		add_child(shop)
		var sign_l = Label.new()
		sign_l.text = "LOJA [E]"
		sign_l.position = MAPS[current]["shop"] + Vector2(-40, -70)
		sign_l.add_theme_font_size_override("font_size", 15)
		sign_l.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
		sign_l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		sign_l.add_theme_constant_override("outline_size", 4)
		map_layer.add_child(sign_l)
	if player != null:
		GameManager.weapon = player.weapon
		GameManager.hair_color = player.hair_color
		GameManager.tunic_color = player.tunic_color
		GameManager.pants_color = player.pants_color
	GameManager.save_game()

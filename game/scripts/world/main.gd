extends Node2D
## Main — controla qual mapa está ativo e o spawn do player
## O player é criado POR CÓDIGO (a cena principal não depende mais do player.tscn no boot)

const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")
const COLLIDERS = preload("res://scripts/world/colliders.gd")

const MAPS = {
	"city1": {
		"texture": "res://assets/maps/city1.png",
		"player_spawn": Vector2(512, 620),
		"exit": {"pos": Vector2(512, 800), "radius": 42, "to": "rat_cave"},
	},
	"rat_cave": {
		"texture": "res://assets/maps/rat_cave.png",
		"player_spawn": Vector2(512, 400),
		"exit": {"pos": Vector2(512, 90), "radius": 42, "to": "city1"},
	},
}

@onready var map_layer: Node2D = $MapLayer
@onready var entities: Node2D = $Entities

var player: CharacterBody2D = null
var current: String = ""
var switching: bool = false
var _respawning: bool = false

func _ready() -> void:
	GameManager.load_game()
	_create_player()
	switch_map(GameManager.current_map if GameManager.current_map in MAPS else "city1")
	if player != null:
		player.weapon = GameManager.weapon
		player.hair_color = GameManager.hair_color
		player.tunic_color = GameManager.tunic_color
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
	player.position = Vector2(512, 620)

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
	var ex = MAPS[current].get("exit")
	if ex and player.global_position.distance_to(ex["pos"]) < ex["radius"]:
		switching = true
		var from = current
		switch_map(ex["to"])
		switching = false
		print("transicao: ", from, " -> ", ex["to"])

func switch_map(name: String) -> void:
	if name == current or not MAPS.has(name):
		return
	current = name
	GameManager.current_map = name
	for c in map_layer.get_children():
		c.queue_free()
	var sprite = Sprite2D.new()
	sprite.texture = TEXHELPER.load_map(MAPS[name]["texture"])
	sprite.centered = false
	map_layer.add_child(sprite)
	if player != null:
		player.global_position = MAPS[name]["player_spawn"]
	for mob in get_tree().get_nodes_in_group("mobs"):
		mob.queue_free()
	if name == "rat_cave":
		var spawner = load("res://scripts/world/rat_cave.gd").new()
		entities.add_child(spawner)
	COLLIDERS.build_colliders(name, map_layer)
	if player != null:
		GameManager.weapon = player.weapon
		GameManager.hair_color = player.hair_color
		GameManager.tunic_color = player.tunic_color
	GameManager.save_game()

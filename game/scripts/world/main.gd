extends Node2D
## Main — controla qual mapa está ativo e o spawn do player
## Cidade tem bueiro (sul); ao andar até ele, desce pra caverna. Na caverna, a grade (norte) sobe.

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
@onready var player = $Player

var current: String = ""
var switching: bool = false

func _ready() -> void:
	GameManager.load_game()
	switch_map(GameManager.current_map if GameManager.current_map in MAPS else "city1")

func _physics_process(_delta: float) -> void:
	if switching or player.dead:
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
	sprite.texture = TexHelper.load_map(MAPS[name]["texture"])
	sprite.centered = false
	map_layer.add_child(sprite)
	player.global_position = MAPS[name]["player_spawn"]
	for mob in get_tree().get_nodes_in_group("mobs"):
		mob.queue_free()
	if name == "rat_cave":
		var spawner = load("res://scripts/world/rat_cave.gd").new()
		entities.add_child(spawner)
	GameManager.save_game()

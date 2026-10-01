extends Node2D
## Main — controla qual mapa está ativo e o spawn do player

const MAPS = {
	"city1": {
		"texture": "res://assets/maps/city1.png",
		"player_spawn": Vector2(512, 620),
	},
	"rat_cave": {
		"texture": "res://assets/maps/rat_cave.png",
		"player_spawn": Vector2(512, 150),
	},
}

@onready var map_layer: Node2D = $MapLayer
@onready var entities: Node2D = $Entities
@onready var player = $Player

var current: String = ""

func _ready() -> void:
	GameManger_guard()

func GameManger_guard() -> void:
	# wrapper simples para não quebrar autoload em teste headless
	switch_map("city1")

func switch_map(name: String) -> void:
	if name == current or not MAPS.has(name):
		return
	current = name
	for c in map_layer.get_children():
		c.queue_free()
	var sprite = Sprite2D.new()
	var img = Image.load_from_file(ProjectSettings.globalize_path(MAPS[name]["texture"]))
	if img != null:
		sprite.texture = ImageTexture.create_from_image(img)
	sprite.centered = false
	map_layer.add_child(sprite)
	player.global_position = MAPS[name]["player_spawn"]
	if name == "rat_cave":
		var spawner = load("res://scripts/world/rat_cave.gd").new()
		entities.add_child(spawner)

func _unhandled_input(event: InputEvent) -> void:
	# tecla M alterna entre cidade e caverna (teste de transição)
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		switch_map("rat_cave" if current == "city1" else "city1")

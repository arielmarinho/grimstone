extends Node2D
## Caverna dos ratos — spawna rato, morcego e aranha (mundo 2x)

const RAT_SCENE = preload("res://scenes/entities/mobs/rat.tscn")

# [pos, tipo]
const SPAWNS = [
	[Vector2(600, 600), "rat"],
	[Vector2(1200, 700), "rat"],
	[Vector2(1000, 1100), "rat"],
	[Vector2(700, 1400), "rat"],
	[Vector2(1500, 1300), "rat"],
	[Vector2(400, 900), "bat"],
	[Vector2(1700, 900), "bat"],
	[Vector2(1300, 1700), "bat"],
	[Vector2(500, 1700), "spider"],
	[Vector2(1600, 500), "spider"],
]

func _ready() -> void:
	for entry in SPAWNS:
		var mob = RAT_SCENE.instantiate()
		mob.mob_type = entry[1]
		mob.position = entry[0]
		add_child(mob)

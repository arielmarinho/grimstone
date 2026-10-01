extends Node2D
## Caverna dos ratos — spawna os ratos (mundo 2x)

const RAT_SCENE = preload("res://scenes/entities/mobs/rat.tscn")

const SPAWNS = [
	Vector2(600, 600),
	Vector2(1200, 700),
	Vector2(1000, 1100),
	Vector2(700, 1400),
	Vector2(1500, 1300),
]

func _ready() -> void:
	for pos in SPAWNS:
		var rat = RAT_SCENE.instantiate()
		rat.position = pos
		add_child(rat)

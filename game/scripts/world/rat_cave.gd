extends Node2D
## Caverna dos ratos — spawna os ratos no início

const RAT_SCENE = preload("res://scenes/entities/mobs/rat.tscn")

const SPAWNS = [
	Vector2(300, 300),
	Vector2(600, 350),
	Vector2(500, 550),
]

func _ready() -> void:
	for pos in SPAWNS:
		var rat = RAT_SCENE.instantiate()
		rat.position = pos
		add_child(rat)

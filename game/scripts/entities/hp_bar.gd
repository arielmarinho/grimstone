extends ProgressBar
## Barra de vida flutuante do player

func _process(_delta: float) -> void:
	value = float(GameManager.hp) / float(GameManager.hp_max) * 100.0

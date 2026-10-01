extends Node2D
## Projétil (flecha ou bola de fogo) — viaja até o alvo e aplica dano
## Suporta critico (dano em dobro com feedback visual)

var damage: int = 10
var speed: float = 420.0
var target_pos: Vector2
var skill: String = "distancia"
var color: Color = Color(0.9, 0.85, 0.7)
var is_crit: bool = false
var big: bool = false

func setup(from: Vector2, to: Vector2, dmg: int, kind: String, crit: bool = false, projectile_big: bool = false) -> void:
	global_position = from
	target_pos = to
	damage = dmg
	is_crit = crit
	big = projectile_big
	match kind:
		"bow":
			color = Color(0.9, 0.85, 0.7)
			speed = 500.0
		"staff":
			color = Color(0.95, 0.55, 0.2)
			speed = 320.0

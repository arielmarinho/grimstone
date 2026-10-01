extends Node2D
## Projétil (flecha ou bola de fogo) — viaja até o alvo e aplica dano

var damage: int = 10
var speed: float = 420.0
var target_pos: Vector2
var skill: String = "distancia"
var color: Color = Color(0.9, 0.85, 0.7)

func setup(from: Vector2, to: Vector2, dmg: int, kind: String) -> void:
	global_position = from
	target_pos = to
	damage = dmg
	match kind:
		"bow":
			color = Color(0.9, 0.85, 0.7)
			speed = 500.0
		"staff":
			color = Color(0.95, 0.55, 0.2)
			speed = 320.0

func _ready() -> void:
	var sprite = Sprite2D.new()
	var img = Image.create(12, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(12):
		for y in range(2, 4):
			img.set_pixel(x, y, color)
	sprite.texture = ImageTexture.create_from_image(img)
	add_child(sprite)
	rotation = (target_pos - global_position).angle()

func _physics_process(delta: float) -> void:
	var dir = (target_pos - global_position)
	if dir.length() < 12.0:
		_hit()
		return
	global_position += dir.normalized() * speed * delta

func _hit() -> void:
	for mob in get_tree().get_nodes_in_group("mobs"):
		if not mob.dead and mob.global_position.distance_to(global_position) < 40.0:
			mob.take_damage(damage)
	queue_free()

extends Node2D
## Colisores do mapa — gerados por código a partir do layout conhecido

static func build_colliders(map_name: String, parent: Node) -> void:
	for c in parent.get_children():
		if c is StaticBody2D:
			c.queue_free()
	if map_name == "city1":
		_city(parent)
	else:
		_cave(parent)

static func _add_rect(parent: Node, pos: Vector2, size: Vector2) -> void:
	var body = StaticBody2D.new()
	body.position = pos
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	parent.add_child(body)

static func _city(parent: Node) -> void:
	_add_rect(parent, Vector2(512, 130), Vector2(1024, 40))
	_add_rect(parent, Vector2(130, 512), Vector2(40, 764))
	_add_rect(parent, Vector2(894, 512), Vector2(40, 764))
	_add_rect(parent, Vector2(265, 881), Vector2(270, 40))
	_add_rect(parent, Vector2(759, 881), Vector2(270, 40))
	var f = StaticBody2D.new()
	f.position = Vector2(512, 512)
	var cs = CollisionShape2D.new()
	var c = CircleShape2D.new()
	c.radius = 46.0
	cs.shape = c
	f.add_child(cs)
	parent.add_child(f)
	_add_rect(parent, Vector2(745, 715), Vector2(150, 130))

static func _cave(parent: Node) -> void:
	_add_rect(parent, Vector2(512, 35), Vector2(1024, 70))
	_add_rect(parent, Vector2(512, 989), Vector2(1024, 70))
	_add_rect(parent, Vector2(35, 512), Vector2(70, 1024))
	_add_rect(parent, Vector2(989, 512), Vector2(70, 1024))

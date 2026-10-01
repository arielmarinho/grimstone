extends Node2D
## Colisores do mapa — MUNDO 2X (2048x2048)

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
	_add_rect(parent, Vector2(1024, 260), Vector2(2048, 80))
	_add_rect(parent, Vector2(260, 1024), Vector2(80, 1528))
	_add_rect(parent, Vector2(1788, 1024), Vector2(80, 1528))
	_add_rect(parent, Vector2(530, 1762), Vector2(540, 80))
	_add_rect(parent, Vector2(1518, 1762), Vector2(540, 80))
	var f = StaticBody2D.new()
	f.position = Vector2(1024, 1024)
	var cs = CollisionShape2D.new()
	var c = CircleShape2D.new()
	c.radius = 92.0
	cs.shape = c
	f.add_child(cs)
	parent.add_child(f)
	_add_rect(parent, Vector2(1490, 1430), Vector2(300, 260))

static func _cave(parent: Node) -> void:
	_add_rect(parent, Vector2(1024, 70), Vector2(2048, 140))
	_add_rect(parent, Vector2(1024, 1978), Vector2(2048, 140))
	_add_rect(parent, Vector2(70, 1024), Vector2(140, 2048))
	_add_rect(parent, Vector2(1978, 1024), Vector2(140, 2048))

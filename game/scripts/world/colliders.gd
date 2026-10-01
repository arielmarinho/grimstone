extends Node2D
## Colisores dos 4 mapas — mundo 2X (2048x2048)

static func build_colliders(map_name: String, parent: Node) -> void:
	for c in parent.get_children():
		if c is StaticBody2D:
			c.queue_free()
	match map_name:
		"city1":
			_city1(parent)
		"city2":
			_city2(parent)
		"forest":
			_forest(parent)
		_:
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

static func _city1(parent: Node) -> void:
	_add_rect(parent, Vector2(1024, 260), Vector2(2048, 80))
	_add_rect(parent, Vector2(260, 1024), Vector2(80, 1528))
	# direita: 2 segmentos com abertura central (portao leste pra city2)
	_add_rect(parent, Vector2(1788, 540), Vector2(80, 840))
	_add_rect(parent, Vector2(1788, 1508), Vector2(80, 840))
	# baixo: 2 segmentos com abertura central (bueiro)
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

static func _city2(parent: Node) -> void:
	_add_rect(parent, Vector2(1024, 260), Vector2(2048, 80))
	_add_rect(parent, Vector2(1788, 1024), Vector2(80, 1528))
	# baixo: abertura central (floresta)
	_add_rect(parent, Vector2(530, 1762), Vector2(540, 80))
	_add_rect(parent, Vector2(1518, 1762), Vector2(540, 80))
	# esquerda: abertura central (city1)
	_add_rect(parent, Vector2(260, 540), Vector2(80, 840))
	_add_rect(parent, Vector2(260, 1508), Vector2(80, 840))
	var f = StaticBody2D.new()
	f.position = Vector2(1024, 1024)
	var cs = CollisionShape2D.new()
	var c = CircleShape2D.new()
	c.radius = 60.0
	cs.shape = c
	f.add_child(cs)
	parent.add_child(f)
	_add_rect(parent, Vector2(1560, 1560), Vector2(120, 120))

static func _forest(parent: Node) -> void:
	_add_rect(parent, Vector2(1024, 70), Vector2(2048, 140))
	_add_rect(parent, Vector2(1024, 1978), Vector2(2048, 140))
	_add_rect(parent, Vector2(70, 540), Vector2(140, 840))
	_add_rect(parent, Vector2(70, 1508), Vector2(140, 840))
	_add_rect(parent, Vector2(1978, 540), Vector2(140, 840))
	_add_rect(parent, Vector2(1978, 1508), Vector2(140, 840))
	var l = StaticBody2D.new()
	l.position = Vector2(500, 1400)
	var cs = CollisionShape2D.new()
	var c = CircleShape2D.new()
	c.radius = 130.0
	cs.shape = c
	l.add_child(cs)
	parent.add_child(l)

static func _cave(parent: Node) -> void:
	_add_rect(parent, Vector2(1024, 70), Vector2(2048, 140))
	_add_rect(parent, Vector2(1024, 1978), Vector2(2048, 140))
	_add_rect(parent, Vector2(70, 1024), Vector2(140, 2048))
	_add_rect(parent, Vector2(1978, 1024), Vector2(140, 2048))

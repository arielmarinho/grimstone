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
	# muralha (arte y 143-895 -> mundo 286-1790): topo, esquerda, direita e baixo
	# portao LESTE: abertura y 932-1156 (casando com a arte, largura 224)
	# portao SUL (bueiro): abertura x 932-1156 (casando com a arte)
	_add_rect(parent, Vector2(1024, 260), Vector2(2048, 80))
	_add_rect(parent, Vector2(260, 1011), Vector2(80, 1422))
	_add_rect(parent, Vector2(1788, 616), Vector2(80, 632))
	_add_rect(parent, Vector2(1788, 1439), Vector2(80, 566))
	_add_rect(parent, Vector2(596, 1762), Vector2(672, 80))
	_add_rect(parent, Vector2(1472, 1762), Vector2(632, 80))
	# fonte central
	var f = StaticBody2D.new()
	f.position = Vector2(1024, 1024)
	var cs = CollisionShape2D.new()
	var c = CircleShape2D.new()
	c.radius = 92.0
	cs.shape = c
	f.add_child(cs)
	parent.add_child(f)
	# lago
	_add_rect(parent, Vector2(1490, 1430), Vector2(300, 260))
	# predios (3 construcoes — player nao atravessa mais)
	_add_rect(parent, Vector2(580, 555), Vector2(320, 230))
	_add_rect(parent, Vector2(1440, 555), Vector2(320, 230))
	_add_rect(parent, Vector2(580, 1395), Vector2(320, 230))
	# decoracao solida (barris/caixotes/barraca — casando com decor.gd)
	_add_rect(parent, Vector2(480, 1300), Vector2(52, 52))
	_add_rect(parent, Vector2(500, 1420), Vector2(52, 52))
	_add_rect(parent, Vector2(680, 1500), Vector2(52, 52))
	_add_rect(parent, Vector2(1600, 1250), Vector2(140, 100))

static func _city2(parent: Node) -> void:
	# muralha (arte y 140-906 -> mundo 280-1812): topo, direita, baixo, esquerda
	# portao OESTE: abertura y 932-1156 (casando com a arte)
	# portao SUL (floresta): abertura x 932-1156 (casando com a arte)
	_add_rect(parent, Vector2(1024, 260), Vector2(2048, 80))
	_add_rect(parent, Vector2(1788, 1011), Vector2(80, 1422))
	_add_rect(parent, Vector2(596, 1762), Vector2(672, 80))
	_add_rect(parent, Vector2(1472, 1762), Vector2(632, 80))
	_add_rect(parent, Vector2(260, 616), Vector2(80, 632))
	_add_rect(parent, Vector2(260, 1439), Vector2(80, 566))
	# estatua central
	var f = StaticBody2D.new()
	f.position = Vector2(1024, 1024)
	var cs = CollisionShape2D.new()
	var c = CircleShape2D.new()
	c.radius = 60.0
	cs.shape = c
	f.add_child(cs)
	parent.add_child(f)
	# forja
	_add_rect(parent, Vector2(1560, 1560), Vector2(120, 120))
	# casas de pedra (4 — player nao atravessa mais)
	_add_rect(parent, Vector2(590, 560), Vector2(300, 220))
	_add_rect(parent, Vector2(1360, 560), Vector2(300, 220))
	_add_rect(parent, Vector2(590, 1380), Vector2(300, 220))
	_add_rect(parent, Vector2(1360, 1380), Vector2(300, 220))
	# decoracao solida (barris/caixotes/barraca — casando com decor.gd)
	_add_rect(parent, Vector2(1470, 1620), Vector2(52, 52))
	_add_rect(parent, Vector2(1650, 1500), Vector2(52, 52))
	_add_rect(parent, Vector2(1660, 720), Vector2(52, 52))
	_add_rect(parent, Vector2(1320, 420), Vector2(140, 100))

static func _forest(parent: Node) -> void:
	# bordas densas de arvore — ABERTURA NORTE (x 932-1156) pra city2
	_add_rect(parent, Vector2(516, 70), Vector2(1032, 140))
	_add_rect(parent, Vector2(1532, 70), Vector2(1032, 140))
	_add_rect(parent, Vector2(1024, 1978), Vector2(2048, 140))
	# esquerda/direita: 2 segmentos cada, sem abertura
	_add_rect(parent, Vector2(70, 540), Vector2(140, 840))
	_add_rect(parent, Vector2(70, 1508), Vector2(140, 840))
	_add_rect(parent, Vector2(1978, 540), Vector2(140, 840))
	_add_rect(parent, Vector2(1978, 1508), Vector2(140, 840))
	# lago
	var l = StaticBody2D.new()
	l.position = Vector2(500, 1400)
	var cs = CollisionShape2D.new()
	var c = CircleShape2D.new()
	c.radius = 130.0
	cs.shape = c
	l.add_child(cs)
	parent.add_child(l)
	# arvores do anel denso (as mesmas da arte — colisores individuais)
	for pos in [[380, 350], [560, 320], [760, 380], [300, 520], [820, 560], [260, 760], [900, 800], [400, 940], [700, 960], [560, 880]]:
		_add_rect(parent, Vector2(pos[0] * 2, pos[1] * 2 + 10), Vector2(50, 50))

static func _cave(parent: Node) -> void:
	_add_rect(parent, Vector2(1024, 70), Vector2(2048, 140))
	_add_rect(parent, Vector2(1024, 1978), Vector2(2048, 140))
	_add_rect(parent, Vector2(70, 1024), Vector2(140, 2048))
	_add_rect(parent, Vector2(1978, 1024), Vector2(140, 2048))

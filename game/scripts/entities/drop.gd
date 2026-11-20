extends Node2D
## Drop de item no chao — coletado ao andar por cima (estilo Rucoy)

const ITEMS_DB = preload("res://scripts/autoload/items_db.gd")
const RARITY = preload("res://scripts/autoload/rarity.gd")
const GROUND = preload("res://scripts/entities/ground_item.gd")

var item_id := "moeda"
var qty := 1

func setup(id: String, q: int) -> void:
	item_id = id
	qty = q

func _ready() -> void:
	var sprite = Sprite2D.new()
	sprite.texture = ITEMS_DB.draw_icon(item_id, 20)
	# Area 45: o node nasce no CENTRO da celula do monstro; sem este offset o icone
	# pousava 36px ACIMA da linha do chao (parecia flutuar). Ver ground_item.gd.
	sprite.position = Vector2(0.0, GROUND.base_offset(20.0))
	add_child(sprite)
	# armas com tier: aura colorida da raridade embaixo do icone
	var tier := RARITY.tier_of(item_id)
	if tier > 0:
		var aura = Sprite2D.new()
		aura.texture = _make_aura(RARITY.cor(tier))
		aura.position = Vector2(0, GROUND.aura_center_y())
		aura.z_index = -1
		add_child(aura)
		move_child(aura, 0)
	var tw = create_tween()
	tw.tween_property(sprite, "position:y", GROUND.bob_peak(20.0), 0.22)
	tw.tween_property(sprite, "position:y", GROUND.base_offset(20.0), 0.22)

func _make_aura(c: Color) -> ImageTexture:
	var img = Image.create(26, 26, false, Image.FORMAT_RGBA8)
	for y in range(26):
		for x in range(26):
			var dx = (x - 13.0) / 12.0
			var dy = (y - 13.0) / 12.0
			var d = dx * dx + dy * dy
			if d <= 1.0:
				img.set_pixel(x, y, Color(c.r, c.g, c.b, 0.55 * (1.0 - d)))
	return ImageTexture.create_from_image(img)

func _physics_process(_delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var p = players[0]
	if not is_instance_valid(p) or p.dead:
		return
	if p.global_position.distance_to(global_position) < 26.0:
		_pickup()

func _pickup() -> void:
	var base_id: String = item_id.split("#")[0]
	var it = ITEMS_DB.ITEMS.get(base_id, null)
	if it == null:
		queue_free()
		return
	if it["tipo"] == "moeda":
		GameManager.coins += qty
		FX.coin_gain(global_position, qty)
		AudioManager.play_sfx("coin")
	else:
		if not GameManager.add_item(item_id, qty):
			return
		AudioManager.play_sfx("pickup")
		# aviso de raridade ao pegar arma com tier
		var tier := RARITY.tier_of(item_id)
		if tier > 0 and it.get("tipo", "") == "arma":
			print("RARO! ", it["nome"], " ", RARITY.sufixo(tier))
	queue_free()

extends Node2D
## Drop de item no chao — coletado ao andar por cima (estilo Rucoy)

const ITEMS_DB = preload("res://scripts/autoload/items_db.gd")

var item_id := "moeda"
var qty := 1

func setup(id: String, q: int) -> void:
	item_id = id
	qty = q

func _ready() -> void:
	var sprite = Sprite2D.new()
	sprite.texture = ITEMS_DB.draw_icon(item_id, 20)
	add_child(sprite)
	var tw = create_tween()
	tw.tween_property(sprite, "position:y", -12.0, 0.22).as_relative()
	tw.tween_property(sprite, "position:y", 12.0, 0.22).as_relative()

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
	var it = ITEMS_DB.ITEMS.get(item_id, null)
	if it == null:
		queue_free()
		return
	if it["tipo"] == "moeda":
		GameManager.coins += qty
	else:
		if not GameManager.add_item(item_id, qty):
			return
	queue_free()

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
	if p.dead:
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
		_float_text("+%d moeda%s" % [qty, "s" if qty > 1 else ""])
	else:
		if not GameManager.add_item(item_id, qty):
			_float_text("Mochila cheia!")
			return
		_float_text("+%d %s" % [qty, it["nome"]])
	queue_free()

func _float_text(txt: String) -> void:
	var lbl = Label.new()
	lbl.text = txt
	lbl.position = global_position + Vector2(-30, -46)
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	lbl.add_theme_constant_override("outline_size", 3)
	get_parent().add_child(lbl)
	var tw = lbl.create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 24, 0.8)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.8)
	tw.tween_callback(lbl.queue_free)

extends Node2D
## Moeda de loot — cai do rato morto, player coleta andando por cima

var value: int = 5

func _ready() -> void:
	var sprite = Sprite2D.new()
	var img = Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in range(12):
		for x in range(12):
			var d = Vector2(x - 5.5, y - 5.5).length()
			if d < 5.5:
				img.set_pixel(x, y, Color(0.9, 0.75, 0.2))
			if d < 3.5:
				img.set_pixel(x, y, Color(0.95, 0.85, 0.4))
	sprite.texture = ImageTexture.create_from_image(img)
	add_child(sprite)
	var tw = create_tween()
	tw.tween_property(sprite, "position:y", -14.0, 0.25).as_relative()
	tw.tween_property(sprite, "position:y", 14.0, 0.25).as_relative()

func _physics_process(_delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0].global_position.distance_to(global_position) < 30.0:
		GameManager.coins += value
		print("moeda! total: ", GameManager.coins)
		queue_free()

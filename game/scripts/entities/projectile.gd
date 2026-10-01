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

func _ready() -> void:
	var sprite = Sprite2D.new()
	var w := 12 if not big else 22
	var h := 6 if not big else 14
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var core := Color(1.0, 0.95, 0.6) if is_crit else color
	for x in range(w):
		for y in range(h / 3, h * 2 / 3):
			img.set_pixel(x, y, core)
	if big:
		var cx := w / 2.0
		var cy := h / 2.0
		for j in range(h):
			for i in range(w):
				var d = Vector2(i - cx, j - cy).length()
				if d < w / 3.0:
					img.set_pixel(i, j, Color(1, 0.9, 0.5))
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
	var radius := 40.0 if not big else 70.0
	for mob in get_tree().get_nodes_in_group("mobs"):
		if not mob.dead and mob.global_position.distance_to(global_position) < radius:
			mob.take_damage(damage)
			if is_crit:
				_spawn_crit_text(mob.global_position)
	queue_free()

func _spawn_crit_text(pos: Vector2) -> void:
	var l = Label.new()
	l.text = "CRIT!"
	l.position = pos + Vector2(-20, -50)
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 4)
	get_parent().add_child(l)
	var tw = l.create_tween()
	tw.tween_property(l, "position:y", l.position.y - 24.0, 0.6)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.6)
	tw.tween_callback(l.queue_free)

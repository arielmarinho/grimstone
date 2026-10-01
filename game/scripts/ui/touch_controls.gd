extends CanvasLayer
## TouchControls (v0.5.6) — controles touch para Android (estilo Rucoy)
## Joystick virtual (canto inf. esquerdo) + 4 botoes de skill Q/E/R/G (inf. direito)
## + tap em qualquer outro lugar = mover/atacar (target do player).
## Invisivel em desktop (sem touchscreen) — zero impacto no jogo de PC.

var joy_vec := Vector2.ZERO
var _joy_center := Vector2.ZERO
var _joy_touch_idx := -1
var _panel: Control

const JOY_RADIUS := 90.0
const BTN_RADIUS := 52.0

func _ready() -> void:
	layer = 50
	if not DisplayServer.is_touchscreen_available():
		visible = false
		return
	_panel = TouchPanel.new()
	_panel.tc = self
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_panel)

func _btn_rects() -> Dictionary:
	var vp := _panel.get_viewport_rect().size
	var cx := vp.x - 70.0
	var cy := vp.y - 70.0
	return {
		"Q": Vector2(cx - 120.0, cy - 40.0),
		"E": Vector2(cx - 40.0, cy - 110.0),
		"R": Vector2(cx + 40.0, cy - 40.0),
		"G": Vector2(cx - 40.0, cy + 40.0),
	}

func _player():
	var pl = get_tree().get_nodes_in_group("player")
	return pl[0] if pl.size() > 0 else null

class TouchPanel extends Control:
	var tc
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		# joystick base
		var vp := get_viewport_rect().size
		var jc := Vector2(150.0, vp.y - 150.0)
		draw_circle(jc, tc.JOY_RADIUS, Color(0.1, 0.1, 0.1, 0.35))
		draw_circle(jc, tc.JOY_RADIUS - 6.0, Color(0.25, 0.25, 0.25, 0.35))
		var knob: Vector2 = jc + tc.joy_vec * (tc.JOY_RADIUS * 0.6)
		draw_circle(knob, 34.0, Color(0.9, 0.85, 0.6, 0.5))
		# botoes de skill
		var labels := {"Q": "Q", "E": "E", "R": "R", "G": "G"}
		for id in tc._btn_rects():
			var c: Vector2 = tc._btn_rects()[id]
			draw_circle(c, tc.BTN_RADIUS, Color(0.15, 0.12, 0.08, 0.45))
			draw_circle(c, tc.BTN_RADIUS - 4.0, Color(0.35, 0.28, 0.18, 0.5))
			var f := ThemeDB.fallback_font
			if f:
				draw_string(f, c + Vector2(-14, 10), labels[id], HORIZONTAL_ALIGNMENT_CENTER, 40, 26, Color(1, 0.95, 0.8, 0.9))
	func _input(event: InputEvent) -> void:
		var vp := get_viewport_rect().size
		var jc := Vector2(150.0, vp.y - 150.0)
		if event is InputEventScreenTouch:
			var t := event as InputEventScreenTouch
			var pl = tc._player()
			if t.pressed:
				if t.position.distance_to(jc) <= tc.JOY_RADIUS * 1.4:
					tc._joy_touch_idx = t.index
				else:
					var hit := false
					for id in tc._btn_rects():
						if t.position.distance_to(tc._btn_rects()[id]) <= tc.BTN_RADIUS:
							hit = true
							if pl:
								pl._use_skill(id)
							break
					if not hit:
						# tap em qualquer lugar = mover/atacar (estilo Rucoy)
						var world: Vector2 = get_canvas_transform().affine_inverse() * t.position
						if pl:
							pl.target = world
							pl.moving = true
			else:
				if t.index == tc._joy_touch_idx:
					tc._joy_touch_idx = -1
					tc.joy_vec = Vector2.ZERO
		elif event is InputEventScreenDrag:
			var d := event as InputEventScreenDrag
			if d.index == tc._joy_touch_idx:
				var v: Vector2 = (d.position - jc) / tc.JOY_RADIUS
				tc.joy_vec = v.limit_length(1.0)
		queue_redraw()

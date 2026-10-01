extends CanvasLayer
## HUD — barras hp/mana/XP, nível/mapa, classe atual (arma), skills, moedas e painel de roupas (C)

var hp_bar: ProgressBar
var mana_bar: ProgressBar
var xp_bar: ProgressBar
var map_label: Label
var class_label: Label
var skills_label: Label
var cloth_panel: Control
var preview: TextureRect
var player_ref: Node = null

const EQUIPS = preload("res://scripts/autoload/equips.gd")
const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")

func _ready() -> void:
	hp_bar = _make_bar(Color(0.85, 0.2, 0.2), Vector2(20, 16))
	mana_bar = _make_bar(Color(0.25, 0.45, 0.9), Vector2(20, 40))
	xp_bar = _make_bar(Color(0.95, 0.6, 0.15), Vector2(20, 64))
	map_label = _make_label(Vector2(20, 92), 15, Color(1, 1, 1))
	class_label = _make_label(Vector2(20, 114), 14, Color(1.0, 0.85, 0.4))
	skills_label = _make_label(Vector2(20, 136), 12, Color(0.8, 0.9, 1.0))
	var coins_label = _make_label(Vector2(20, 158), 14, Color(0.95, 0.8, 0.25))
	coins_label.name = "Coins"
	_build_cloth_panel()

func _make_label(pos: Vector2, size: int, color: Color) -> Label:
	var l = Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	add_child(l)
	return l

func set_player(p: Node) -> void:
	player_ref = p

func _process(_delta: float) -> void:
	hp_bar.value = float(GameManager.hp) / float(GameManager.hp_max) * 100.0
	mana_bar.value = float(GameManager.mana) / float(GameManager.mana_max) * 100.0
	var prev_xp = GameManager.xp_for_level(GameManager.level)
	var next_xp = GameManager.xp_for_level(GameManager.level + 1)
	xp_bar.value = float(GameManager.xp - prev_xp) / float(next_xp - prev_xp) * 100.0
	map_label.text = "Nivel %d  |  %s" % [GameManager.level, GameManager.current_map]
	if player_ref != null:
		var w = EQUIPS.WEAPONS[player_ref.weapon]
		class_label.text = "%s (arma: %s)  [1-4 arma | T tunica | Y cabelo | C painel]" % [w["classe"], w["nome"]]
		var parts = []
		for skill in GameManager.skills:
			parts.append("%s %d" % [skill.capitalize(), GameManager.skills[skill]["level"]])
		skills_label.text = " | ".join(parts)
		get_node("Coins").text = "Moedas: %d" % GameManager.coins
	if preview != null and player_ref != null and cloth_panel.visible:
		preview.texture = _make_preview(player_ref.weapon, player_ref.hair_color, player_ref.tunic_color)

func _make_bar(color: Color, pos: Vector2) -> ProgressBar:
	var bar = ProgressBar.new()
	bar.position = pos
	bar.size = Vector2(280, 20)
	bar.max_value = 100.0
	bar.show_percentage = false
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.12, 0.9)
	bg.set_corner_radius_all(4)
	var fg = StyleBoxFlat.new()
	fg.bg_color = color
	fg.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fg)
	add_child(bar)
	return bar

# ---------- PAINEL DE ROUPAS (tecla C) ----------
func _build_cloth_panel() -> void:
	cloth_panel = Control.new()
	cloth_panel.visible = false
	add_child(cloth_panel)
	var bg = ColorRect.new()
	bg.position = Vector2(400, 150)
	bg.size = Vector2(480, 420)
	bg.color = Color(0.1, 0.09, 0.12, 0.95)
	cloth_panel.add_child(bg)
	var title = _make_label(Vector2(430, 165), 20, Color(1, 1, 1))
	title.text = "CUSTOMIZAR ROUPAS"
	cloth_panel.add_child(title)
	preview = TextureRect.new()
	preview.position = Vector2(640, 210)
	preview.custom_minimum_size = Vector2(192, 192)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cloth_panel.add_child(preview)
	var lt = _make_label(Vector2(430, 210), 14, Color(1, 1, 1))
	lt.text = "TUNICA (clique a cor)"
	cloth_panel.add_child(lt)
	var lh = _make_label(Vector2(430, 330), 14, Color(1, 1, 1))
	lh.text = "CABELO (clique a cor)"
	cloth_panel.add_child(lh)
	var cores = EQUIPS.CLOTHES_COLORS.keys()
	for i in range(cores.size()):
		var c_name = cores[i]
		var sw = Button.new()
		sw.position = Vector2(430 + i * 34, 236)
		sw.size = Vector2(30, 30)
		var st = StyleBoxFlat.new()
		st.bg_color = EQUIPS.CLOTHES_COLORS[c_name]
		st.set_corner_radius_all(6)
		sw.add_theme_stylebox_override("normal", st)
		sw.pressed.connect(_set_tunic.bind(c_name))
		cloth_panel.add_child(sw)
		var sw2 = Button.new()
		sw2.position = Vector2(430 + i * 34, 356)
		sw2.size = Vector2(30, 30)
		var st2 = StyleBoxFlat.new()
		st2.bg_color = EQUIPS.CLOTHES_COLORS[c_name]
		st2.set_corner_radius_all(6)
		sw2.add_theme_stylebox_override("normal", st2)
		sw2.pressed.connect(_set_hair.bind(c_name))
		cloth_panel.add_child(sw2)
	var hint = _make_label(Vector2(430, 530), 12, Color(0.7, 0.7, 0.75))
	hint.text = "C para fechar"
	cloth_panel.add_child(hint)

func _make_preview(weapon: String, hair: String, tunic: String) -> Texture2D:
	var img = Image.create(96, 96, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	TEXHELPER._draw_knight(img, 0, false, false, false, weapon, hair, tunic)
	return ImageTexture.create_from_image(img)

func _set_tunic(c: String) -> void:
	if player_ref != null:
		player_ref.tunic_color = c
		player_ref._build_frames()

func _set_hair(c: String) -> void:
	if player_ref != null:
		player_ref.hair_color = c
		player_ref._build_frames()

func toggle_cloth_panel() -> void:
	cloth_panel.visible = not cloth_panel.visible

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_C:
		toggle_cloth_panel()

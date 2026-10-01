extends CanvasLayer
## HUD polido: barras com NUMEROS, moedas, classe, skills,
## mochila (B) exclusiva, hotbar (1-4), tela de morte, painel roupas (C)

const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")
const EQUIPS = preload("res://scripts/autoload/equips.gd")
const ITEMS_DB = preload("res://scripts/autoload/items_db.gd")

var hp_bar: ProgressBar
var mana_bar: ProgressBar
var xp_bar: ProgressBar
var hp_num: Label
var mana_num: Label
var xp_num: Label
var map_label: Label
var class_label: Label
var skills_label: Label
var coins_label: Label
var hint_label: Label
var bag_panel: Control
var bag_grid: GridContainer
var death_screen: Control
var cloth_panel: Control
var preview: TextureRect
var player_ref: Node = null
var hotbar_slots: Array = []

const WEAPON_KEYS = ["sword", "axe", "bow", "staff"]

func _ready() -> void:
	hp_bar = _make_bar(Color(0.85, 0.2, 0.2), Vector2(20, 16))
	mana_bar = _make_bar(Color(0.25, 0.45, 0.9), Vector2(20, 40))
	xp_bar = _make_bar(Color(0.95, 0.6, 0.15), Vector2(20, 64))
	hp_num = _make_label(Vector2(310, 16), 12, Color(1, 1, 1))
	mana_num = _make_label(Vector2(310, 40), 12, Color(1, 1, 1))
	xp_num = _make_label(Vector2(310, 64), 12, Color(1, 1, 1))
	map_label = _make_label(Vector2(20, 92), 15, Color(1, 1, 1))
	class_label = _make_label(Vector2(20, 114), 14, Color(1.0, 0.85, 0.4))
	skills_label = _make_label(Vector2(20, 136), 12, Color(0.8, 0.9, 1.0))
	coins_label = _make_label(Vector2(20, 158), 14, Color(0.95, 0.8, 0.25))
	hint_label = _make_label(Vector2(400, 600), 13, Color(1, 1, 1, 0.9))
	hint_label.text = "Objetivo: desca pelo BUEIRO (grade ao sul da fonte)"
	_build_hotbar()
	_build_bag()
	_build_death_screen()
	_build_cloth_panel()

func _make_label(pos: Vector2, size: int, color: Color) -> Label:
	var l = Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 3)
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
	hp_num.text = "%d / %d" % [GameManager.hp, GameManager.hp_max]
	mana_num.text = "%d / %d" % [GameManager.mana, GameManager.mana_max]
	xp_num.text = "%d XP" % (GameManager.xp - prev_xp)
	map_label.text = "Nivel %d  |  %s" % [GameManager.level, GameManager.current_map]
	if player_ref != null:
		var w = EQUIPS.WEAPONS[player_ref.weapon]
		class_label.text = "%s (arma: %s)  [1-4 arma | B mochila | C roupas]" % [w["classe"], w["nome"]]
		var parts = []
		for skill in GameManager.skills:
			parts.append("%s %d" % [skill.capitalize(), GameManager.skills[skill]["level"]])
		skills_label.text = " | ".join(parts)
		_process_hotbar_highlight()
		if player_ref.dead and not death_screen.visible:
			death_screen.visible = true
		elif not player_ref.dead and death_screen.visible:
			death_screen.visible = false
		if GameManager.current_map == "city1":
			hint_label.visible = player_ref.global_position.distance_to(Vector2(1024, 1600)) > 240.0
		else:
			hint_label.visible = false
	coins_label.text = "Moedas: %d" % GameManager.coins
	if bag_panel.visible:
		_refresh_bag()

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

# ---------- HOTBAR DE ARMAS (1-4) ----------
func _build_hotbar() -> void:
	for i in range(4):
		var slot = Button.new()
		slot.position = Vector2(560 + i * 46, 640)
		slot.size = Vector2(42, 42)
		var icon = TextureRect.new()
		icon.texture = ITEMS_DB.draw_icon(WEAPON_KEYS[i], 28)
		icon.position = Vector2(7, 7)
		icon.custom_minimum_size = Vector2(28, 28)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(icon)
		var num = Label.new()
		num.text = str(i + 1)
		num.position = Vector2(3, 2)
		num.add_theme_font_size_override("font_size", 10)
		num.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		num.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(num)
		slot.pressed.connect(_select_weapon.bind(WEAPON_KEYS[i]))
		add_child(slot)
		hotbar_slots.append(slot)

func _select_weapon(wid: String) -> void:
	if player_ref != null and not player_ref.dead:
		player_ref.weapon = wid
		player_ref._build_frames()

func _process_hotbar_highlight() -> void:
	for i in range(4):
		var slot = hotbar_slots[i]
		var stn = StyleBoxFlat.new()
		stn.bg_color = Color(0.12, 0.11, 0.14, 0.92)
		stn.set_corner_radius_all(8)
		stn.set_border_width_all(2)
		stn.border_color = Color(0.95, 0.8, 0.3) if player_ref.weapon == WEAPON_KEYS[i] else Color(0.35, 0.3, 0.25)
		slot.add_theme_stylebox_override("normal", stn)

# ---------- MOCHILA (tecla B) — centro, exclusiva ----------
func _build_bag() -> void:
	bag_panel = Control.new()
	bag_panel.visible = false
	add_child(bag_panel)
	var bg = ColorRect.new()
	bg.position = Vector2(495, 130)
	bg.size = Vector2(290, 380)
	bg.color = Color(0.1, 0.09, 0.12, 0.95)
	bag_panel.add_child(bg)
	var title = _make_label(Vector2(510, 140), 18, Color(1, 1, 1))
	title.text = "MOCHILA"
	bag_panel.add_child(title)
	bag_grid = GridContainer.new()
	bag_grid.columns = 5
	bag_grid.position = Vector2(510, 175)
	bag_grid.add_theme_constant_override("h_separation", 6)
	bag_grid.add_theme_constant_override("v_separation", 6)
	bag_panel.add_child(bag_grid)
	var hint = _make_label(Vector2(510, 480), 12, Color(0.7, 0.7, 0.75))
	hint.text = "Clique para usar/equipar | B fecha"
	bag_panel.add_child(hint)

func _refresh_bag() -> void:
	for c in bag_grid.get_children():
		c.queue_free()
	var ids = GameManager.bag.keys()
	for i in range(GameManager.BAG_MAX):
		var slot = Button.new()
		slot.custom_minimum_size = Vector2(46, 46)
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.16, 0.15, 0.18, 0.9)
		st.set_corner_radius_all(6)
		st.set_border_width_all(1)
		st.border_color = Color(0.3, 0.28, 0.25)
		slot.add_theme_stylebox_override("normal", st)
		if i < ids.size():
			var id = ids[i]
			var icon = TextureRect.new()
			icon.texture = ITEMS_DB.draw_icon(id, 32)
			icon.custom_minimum_size = Vector2(32, 32)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(icon)
			var qty = Label.new()
			qty.text = str(GameManager.bag[id])
			qty.position = Vector2(30, 28)
			qty.add_theme_font_size_override("font_size", 11)
			qty.add_theme_color_override("font_color", Color(1, 1, 0.8))
			qty.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(qty)
			slot.tooltip_text = ITEMS_DB.ITEMS[id]["nome"]
			slot.pressed.connect(_use_bag_item.bind(id))
		bag_grid.add_child(slot)

func _use_bag_item(id: String) -> void:
	if player_ref == null or player_ref.dead:
		return
	var it = ITEMS_DB.ITEMS.get(id, null)
	if it == null:
		return
	if it["tipo"] == "arma":
		player_ref.weapon = it["arma"]
		player_ref._build_frames()
	elif it["tipo"] == "uso":
		GameManager.use_item(id)

# ---------- TELA DE MORTE ----------
func _build_death_screen() -> void:
	death_screen = Control.new()
	death_screen.visible = false
	add_child(death_screen)
	var dim = ColorRect.new()
	dim.color = Color(0.3, 0.0, 0.0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	death_screen.add_child(dim)
	var title = Label.new()
	title.text = "VOCE MORREU"
	title.position = Vector2(540, 260)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.95, 0.25, 0.2))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	title.add_theme_constant_override("outline_size", 8)
	death_screen.add_child(title)
	var sub = Label.new()
	sub.text = "Suas moedas e itens estao salvos. Renasca para continuar."
	sub.position = Vector2(500, 330)
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	death_screen.add_child(sub)
	var btn = Button.new()
	btn.text = "Renascer na cidade"
	btn.position = Vector2(560, 380)
	btn.size = Vector2(200, 44)
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.5, 0.15, 0.12)
	st.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("normal", st)
	btn.pressed.connect(_respawn)
	death_screen.add_child(btn)

func _respawn() -> void:
	if player_ref == null:
		return
	GameManager.hp = GameManager.hp_max
	GameManager.mana = GameManager.mana_max
	player_ref.dead = false
	player_ref._play("idle")
	var main = get_parent()
	if main.has_method("switch_map"):
		main.switch_map("city1")
	death_screen.visible = false

# ---------- PAINEL DE ROUPAS (tecla C) — centro, exclusivo ----------
func _build_cloth_panel() -> void:
	cloth_panel = Control.new()
	cloth_panel.visible = false
	add_child(cloth_panel)
	var bg = ColorRect.new()
	bg.position = Vector2(400, 130)
	bg.size = Vector2(480, 420)
	bg.color = Color(0.1, 0.09, 0.12, 0.95)
	cloth_panel.add_child(bg)
	var title = _make_label(Vector2(430, 145), 20, Color(1, 1, 1))
	title.text = "CUSTOMIZAR ROUPAS"
	cloth_panel.add_child(title)
	preview = TextureRect.new()
	preview.position = Vector2(620, 180)
	preview.custom_minimum_size = Vector2(192, 192)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cloth_panel.add_child(preview)
	var lt = _make_label(Vector2(430, 190), 14, Color(1, 1, 1))
	lt.text = "TUNICA (clique a cor)"
	cloth_panel.add_child(lt)
	var lh = _make_label(Vector2(430, 310), 14, Color(1, 1, 1))
	lh.text = "CABELO (clique a cor)"
	cloth_panel.add_child(lh)
	var cores = EQUIPS.CLOTHES_COLORS.keys()
	for i in range(cores.size()):
		var c_name = cores[i]
		var sw = Button.new()
		sw.position = Vector2(430 + i * 34, 216)
		sw.size = Vector2(30, 30)
		var st = StyleBoxFlat.new()
		st.bg_color = EQUIPS.CLOTHES_COLORS[c_name]
		st.set_corner_radius_all(6)
		sw.add_theme_stylebox_override("normal", st)
		sw.pressed.connect(_set_tunic.bind(c_name))
		cloth_panel.add_child(sw)
		var sw2 = Button.new()
		sw2.position = Vector2(430 + i * 34, 336)
		sw2.size = Vector2(30, 30)
		var st2 = StyleBoxFlat.new()
		st2.bg_color = EQUIPS.CLOTHES_COLORS[c_name]
		st2.set_corner_radius_all(6)
		sw2.add_theme_stylebox_override("normal", st2)
		sw2.pressed.connect(_set_hair.bind(c_name))
		cloth_panel.add_child(sw2)
	var hint = _make_label(Vector2(430, 520), 12, Color(0.7, 0.7, 0.75))
	hint.text = "C para fechar"
	cloth_panel.add_child(hint)

func _make_preview(weapon: String, hair: String, tunic: String) -> Texture2D:
	var texs = TEXHELPER.load_sheet_custom(TEXHELPER.KNIGHT_IDLE, weapon, hair, tunic)
	if texs.size() > 0:
		return texs[0]
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
	if cloth_panel.visible:
		bag_panel.visible = false

func toggle_bag() -> void:
	bag_panel.visible = not bag_panel.visible
	if bag_panel.visible:
		cloth_panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C:
			toggle_cloth_panel()
		elif event.keycode == KEY_B:
			toggle_bag()

extends CanvasLayer
## HUD: barras, hotbar (1-4), SKILLS Q/E com botões (estilo Rucoy), flechas,
## mochila (B), roupas+calça (C), tela de skills (K), morte

const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")
const EQUIPS = preload("res://scripts/autoload/equips.gd")
const ITEMS_DB = preload("res://scripts/autoload/items_db.gd")
const SKILLS = preload("res://scripts/autoload/skills_db.gd")

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
var arrows_label: Label
var bag_panel: Control
var bag_grid: GridContainer
var death_screen: Control
var cloth_panel: Control
var skills_panel: Control
var preview: TextureRect
var player_ref: Node = null
var hotbar_slots: Array = []
var skill_btns := {}
var _bag_sig: String = ""
var feedback_label: Label
var _feedback_tween: Tween

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
	arrows_label = _make_label(Vector2(20, 180), 14, Color(0.8, 0.7, 0.5))
	_build_hotbar()
	_build_skill_buttons()
	_build_bag()
	_build_death_screen()
	_build_cloth_panel()
	_build_skills_panel()
	_build_feedback()

func _build_feedback() -> void:
	feedback_label = _make_label(Vector2(0, 590), 16, Color(1.0, 0.75, 0.3))
	feedback_label.size = Vector2(1280, 30)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.visible = false
	add_child(feedback_label)

func show_feedback(msg: String) -> void:
	feedback_label.text = msg
	feedback_label.visible = true
	feedback_label.modulate.a = 1.0
	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()
	_feedback_tween = create_tween()
	_feedback_tween.tween_interval(2.0)
	_feedback_tween.tween_property(feedback_label, "modulate:a", 0.0, 0.6)
	_feedback_tween.tween_callback(func(): feedback_label.visible = false)

func _make_label(pos: Vector2, size: int, color: Color) -> Label:
	var l = Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 3)
	return l

func set_player(p: Node) -> void:
	player_ref = p
	if p != null and not p.feedback.is_connected(show_feedback):
		p.feedback.connect(show_feedback)

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
	arrows_label.text = "Flechas: %d" % GameManager.arrows
	arrows_label.visible = player_ref != null and player_ref.weapon == "bow"
	if player_ref != null:
		var w = EQUIPS.WEAPONS[player_ref.weapon]
		class_label.text = "%s (arma: %s)  [1-4 arma | Q/E/R/G skills | B mochila | C roupas | K skills]" % [w["classe"], w["nome"]]
		var parts = []
		for skill in GameManager.skills:
			parts.append("%s %d" % [skill.capitalize(), GameManager.skills[skill]["level"]])
		skills_label.text = " | ".join(parts)
		_process_hotbar_highlight()
		_process_skill_buttons()
		if player_ref.dead and not death_screen.visible:
			death_screen.visible = true
		elif not player_ref.dead and death_screen.visible:
			death_screen.visible = false
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

# ---------- BOTÕES DE SKILL (Q/E, estilo Rucoy) ----------
func _build_skill_buttons() -> void:
	var slots = ["Q", "E", "R", "G"]
	for i in range(slots.size()):
		var slot: String = slots[i]
		var btn = Button.new()
		btn.position = Vector2(710 + i * 50, 640)
		btn.size = Vector2(46, 46)
		var key_l = Label.new()
		key_l.text = slot
		key_l.position = Vector2(4, 2)
		key_l.add_theme_font_size_override("font_size", 13)
		key_l.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
		key_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(key_l)
		var name_l = Label.new()
		name_l.name = "SkillName"
		name_l.position = Vector2(2, 26)
		name_l.add_theme_font_size_override("font_size", 8)
		name_l.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
		name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(name_l)
		var cd_l = Label.new()
		cd_l.name = "CdLabel"
		cd_l.position = Vector2(14, 12)
		cd_l.add_theme_font_size_override("font_size", 14)
		cd_l.add_theme_color_override("font_color", Color(1, 1, 1))
		cd_l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		cd_l.add_theme_constant_override("outline_size", 4)
		cd_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(cd_l)
		btn.pressed.connect(_press_skill.bind(slot))
		add_child(btn)
		skill_btns[slot] = btn

func _press_skill(slot: String) -> void:
	if player_ref != null and not player_ref.dead:
		player_ref._use_skill(slot)

func _process_skill_buttons() -> void:
	var list = SKILLS.SKILLS.get(player_ref.weapon, [])
	var slots = ["Q", "E", "R", "G"]
	for i in range(slots.size()):
		var slot: String = slots[i]
		var btn = skill_btns[slot]
		var name_l = btn.get_node("SkillName")
		var cd_l = btn.get_node("CdLabel")
		var sk: Dictionary = {}
		for s2 in list:
			if s2["tecla"] == slot:
				sk = s2
				break
		if not sk.is_empty():
			if SKILLS.skill_unlocked(sk):
				name_l.text = sk["nome"].split(" ")[0]
			else:
				name_l.text = "???"
		# cooldown numerico no centro do botao (estilo MMO)
		if not player_ref.skill_ready[slot]:
			cd_l.text = str(int(ceil(player_ref.skill_cd[slot])))
			cd_l.visible = true
		else:
			cd_l.visible = false
		var stn = StyleBoxFlat.new()
		stn.bg_color = Color(0.12, 0.11, 0.14, 0.92)
		stn.set_corner_radius_all(8)
		stn.set_border_width_all(2)
		if not sk.is_empty() and not SKILLS.skill_unlocked(sk):
			stn.border_color = Color(0.45, 0.45, 0.5)
		else:
			stn.border_color = Color(0.4, 0.8, 0.4) if player_ref.skill_ready[slot] else Color(0.6, 0.2, 0.2)
		btn.add_theme_stylebox_override("normal", stn)

# ---------- MOCHILA (tecla B) ----------
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

func _refresh_bag() -> void:
	var sig = str(GameManager.bag)
	if sig == _bag_sig:
		return
	_bag_sig = sig
	for c in bag_grid.get_children():
		c.queue_free()
	var ids = GameManager.bag.keys()
	for id in ids:
		var qty: int = GameManager.bag[id]
		var slot = Button.new()
		slot.custom_minimum_size = Vector2(48, 48)
		var icon = TextureRect.new()
		icon.texture = ITEMS_DB.draw_icon(id, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(icon)
		var q = Label.new()
		q.text = "x%d" % qty
		q.position = Vector2(2, 2)
		q.add_theme_font_size_override("font_size", 10)
		q.add_theme_color_override("font_color", Color(1, 1, 1))
		q.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		q.add_theme_constant_override("outline_size", 3)
		q.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(q)
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
		if GameManager.use_item(id):
			AudioManager.play_sfx("potion")

# ---------- TELA DE MORTE ----------
func _build_death_screen() -> void:
	death_screen = Control.new()
	death_screen.visible = false
	add_child(death_screen)
	var dim = ColorRect.new()
	dim.color = Color(0.3, 0.0, 0.0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	death_screen.add_child(dim)
	var txt = Label.new()
	txt.text = "VOCE MORREU"
	txt.position = Vector2(0, 280)
	txt.size = Vector2(1280, 60)
	txt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	txt.add_theme_font_size_override("font_size", 48)
	txt.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	txt.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	txt.add_theme_constant_override("outline_size", 8)
	death_screen.add_child(txt)
	var hint = Label.new()
	hint.text = "Renascendo na cidade..."
	hint.position = Vector2(0, 350)
	hint.size = Vector2(1280, 30)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	death_screen.add_child(hint)

# ---------- ROUPAS (tecla C) ----------
func _build_cloth_panel() -> void:
	cloth_panel = Control.new()
	cloth_panel.visible = false
	add_child(cloth_panel)
	var bg = ColorRect.new()
	bg.position = Vector2(820, 130)
	bg.size = Vector2(300, 420)
	bg.color = Color(0.1, 0.09, 0.12, 0.95)
	cloth_panel.add_child(bg)
	var title = _make_label(Vector2(835, 140), 18, Color(1, 1, 1))
	title.text = "ROUPAS"
	cloth_panel.add_child(title)
	# preview do personagem
	preview = TextureRect.new()
	preview.position = Vector2(920, 170)
	preview.custom_minimum_size = Vector2(96, 96)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cloth_panel.add_child(preview)
	var y := 280.0
	var t_label = _make_label(Vector2(835, y), 13, Color(1.0, 0.85, 0.4))
	t_label.text = "TUNICA (T):"
	cloth_panel.add_child(t_label)
	y += 24
	for c_name in EQUIPS.CLOTHES_COLORS.keys():
		var sw = Button.new()
		sw.text = c_name
		sw.position = Vector2(835, y)
		sw.size = Vector2(130, 26)
		sw.add_theme_font_size_override("font_size", 11)
		sw.pressed.connect(_set_tunic.bind(c_name))
		cloth_panel.add_child(sw)
		y += 30
	var h_label = _make_label(Vector2(835, y), 13, Color(1.0, 0.85, 0.4))
	h_label.text = "CABELO (Y):"
	cloth_panel.add_child(h_label)
	y += 24
	for c_name in EQUIPS.CLOTHES_COLORS.keys():
		var sw2 = Button.new()
		sw2.text = c_name
		sw2.position = Vector2(835, y)
		sw2.size = Vector2(130, 26)
		sw2.add_theme_font_size_override("font_size", 11)
		sw2.pressed.connect(_set_hair.bind(c_name))
		cloth_panel.add_child(sw2)
		y += 30
	var p_label = _make_label(Vector2(835, y), 13, Color(1.0, 0.85, 0.4))
	p_label.text = "CALCA (U):"
	cloth_panel.add_child(p_label)
	y += 24
	for p_name in EQUIPS.PANTS_COLORS.keys():
		var sw3 = Button.new()
		sw3.text = p_name
		sw3.position = Vector2(835, y)
		sw3.size = Vector2(130, 26)
		sw3.add_theme_font_size_override("font_size", 11)
		sw3.pressed.connect(_set_pants.bind(p_name))
		cloth_panel.add_child(sw3)
		y += 30

func _set_tunic(c_name: String) -> void:
	if player_ref != null:
		player_ref.tunic_color = c_name
		player_ref._build_frames()

func _set_hair(c_name: String) -> void:
	if player_ref != null:
		player_ref.hair_color = c_name
		player_ref._build_frames()

func _set_pants(p_name: String) -> void:
	if player_ref != null:
		player_ref.pants_color = p_name
		player_ref._build_frames()

# ---------- TELA DE SKILLS (tecla K) ----------
func _build_skills_panel() -> void:
	skills_panel = Control.new()
	skills_panel.visible = false
	add_child(skills_panel)
	var bg = ColorRect.new()
	bg.position = Vector2(240, 100)
	bg.size = Vector2(800, 480)
	bg.color = Color(0.08, 0.08, 0.11, 0.97)
	skills_panel.add_child(bg)
	var title = _make_label(Vector2(260, 115), 22, Color(1.0, 0.85, 0.4))
	title.text = "SKILLS (por arma)"
	skills_panel.add_child(title)
	var hint = _make_label(Vector2(260, 145), 13, Color(0.7, 0.7, 0.75))
	hint.text = "Q/E basicas em toda arma | R/G avancadas desbloqueiam na VILA (city2)"
	skills_panel.add_child(hint)
	var body = _make_label(Vector2(260, 175), 13, Color(0.9, 0.9, 0.9))
	body.name = "SkillsBody"
	body.size = Vector2(760, 380)
	skills_panel.add_child(body)

func _toggle_panels() -> void:
	if Input.is_key_pressed(KEY_B):
		bag_panel.visible = not bag_panel.visible
		if bag_panel.visible:
			cloth_panel.visible = false
			skills_panel.visible = false
	if Input.is_key_pressed(KEY_C):
		cloth_panel.visible = not cloth_panel.visible
		if cloth_panel.visible:
			bag_panel.visible = false
			skills_panel.visible = false
	if Input.is_key_pressed(KEY_K):
		skills_panel.visible = not skills_panel.visible
		if skills_panel.visible:
			bag_panel.visible = false
			cloth_panel.visible = false
			var body = skills_panel.get_node("SkillsBody")
			var lines = []
			for wname in SKILLS.SKILLS.keys():
				var w = EQUIPS.WEAPONS[wname]
				lines.append("== %s ==" % w["nome"])
				for sk in SKILLS.SKILLS[wname]:
					if SKILLS.skill_unlocked(sk):
						lines.append("  [%s] %s — %s (mana %d, cd %.0fs)" % [sk["tecla"], sk["nome"], sk["desc"], sk["mana"], sk["cd"]])
					else:
						lines.append("  [%s] ??? — desbloqueia na VILA" % sk["tecla"])
			body.text = "\n".join(lines)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_toggle_panels()

extends CanvasLayer
## HUD — barras hp/mana/xp, hotbar armas 1-4, skills Q/E/R/G, mochila (B),
## roupas (C), skills (K), loja (E na cidade), tela de morte, feedback central

const ITEMS_DB = preload("res://scripts/autoload/items_db.gd")
const SKILLS = preload("res://scripts/autoload/skills_db.gd")
const EQUIPS = preload("res://scripts/autoload/equips.gd")

const WEAPON_KEYS = ["sword", "axe", "bow", "staff"]

var player_ref = null
var hotbar_slots: Array = []
var skill_btns := {}
var bag_panel: Panel
var cloth_panel: Panel
var skills_panel: Panel
var bag_grid: GridContainer
var cloth_grid: GridContainer
var skills_grid: GridContainer
var bag_sig := ""
var feedback_label: Label
var feedback_time: float = 0.0
var death_screen: Control
var hp_bar: ProgressBar
var mana_bar: ProgressBar
var xp_bar: ProgressBar
var lvl_label: Label
var coins_label: Label
var hint_label: Label

callable _dummy_guard

func _ready() -> void:
	build_bars()
	_build_hotbar()
	_build_skill_buttons()
	build_bag()
	build_cloth_panel()
	build_skills_panel()
	build_death_screen()
	build_feedback()
	build_hint()

func set_player(p) -> void:
	player_ref = p
	if p != null:
		p.feedback.connect(_on_feedback)

func _process(delta: float) -> void:
	if player_ref == null:
		return
	hp_bar.value = float(GameManager.hp) / float(GameManager.hp_max) * 100.0
	mana_bar.value = float(GameManager.mana) / float(GameManager.mana_max) * 100.0
	xp_bar.value = float(GameManager.xp) / float(GameManager.xp_next) * 100.0
	lvl_label.text = "Nv %d" % GameManager.level
	coins_label.text = "%d moedas" % GameManager.coins
	_process_skill_buttons()
	# feedback central some depois de 2s
	if feedback_time > 0.0:
		feedback_time -= delta
		if feedback_time <= 0.0:
			feedback_label.visible = false
	# refresh da mochila so quando o conteudo muda (assinatura id:qty)
	if bag_panel.visible:
		var sig := ""
		for id in GameManager.bag:
			if GameManager.bag[id] > 0:
				sig += "%s:%d," % [id, GameManager.bag[id]]
		if sig != bag_sig:
			bag_sig = sig
			refresh_bag()

func build_bars() -> void:
	# painel de barras topo-esquerda
	var panel = Panel.new()
	panel.position = Vector2(10, 10)
	panel.size = Vector2(240, 92)
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.08, 0.07, 0.1, 0.85)
	st.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", st)
	add_child(panel)
	hp_bar = _bar(panel, Color(0.75, 0.2, 0.2), Vector2(10, 8))
	mana_bar = _bar(panel, Color(0.25, 0.4, 0.85), Vector2(10, 32))
	xp_bar = _bar(panel, Color(0.2, 0.7, 0.3), Vector2(10, 56))
	lvl_label = _make_label("Nv 1", 16)
	lvl_label.position = Vector2(190, 8)
	panel.add_child(lvl_label)
	coins_label = _make_label("0 moedas", 12)
	coins_label.position = Vector2(190, 34)
	panel.add_child(coins_label)

func _bar(parent: Control, color: Color, pos: Vector2) -> ProgressBar:
	var b = ProgressBar.new()
	b.position = pos
	b.size = Vector2(170, 18)
	b.min_value = 0
	b.max_value = 100
	b.value = 100
	b.show_percentage = false
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.12)
	bg.set_corner_radius_all(4)
	var fg = StyleBoxFlat.new()
	fg.bg_color = color
	fg.set_corner_radius_all(4)
	b.add_theme_stylebox_override("background", bg)
	b.add_theme_stylebox_override("fill", fg)
	parent.add_child(b)
	return b

func _make_label(txt: String, fsize: int) -> Label:
	var l = Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 4)
	return l

# ---------- HOTBAR DE ARMAS (1-4) ----------
func _build_hotbar() -> void:
	for i in range(4):
		var slot = Button.new()
		slot.position = Vector2(10 + i * 58, 560)
		slot.size = Vector2(52, 52)
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.12, 0.11, 0.14, 0.9)
		st.set_corner_radius_all(8)
		st.set_border_width_all(2)
		st.border_color = Color(0.4, 0.35, 0.25)
		slot.add_theme_stylebox_override("normal", st)
		var sth = st.duplicate()
		sth.border_color = Color(0.9, 0.75, 0.3)
		slot.add_theme_stylebox_override("hover", sth)
		slot.add_theme_stylebox_override("pressed", sth)
		slot.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		var ic = TextureRect.new()
		ic.name = "Icon"
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.position = Vector2(8, 8)
		ic.size = Vector2(36, 36)
		ic.texture = ITEMS_DB.get_icon(WEAPON_KEYS[i])
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(ic)
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

# ---------- SKILLS Q/E/R/G ----------
func _build_skill_buttons() -> void:
	var slots = ["Q", "E", "R", "G"]
	for i in range(slots.size()):
		var btn = Button.new()
		btn.position = Vector2(10 + i * 58, 620)
		btn.size = Vector2(52, 52)
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.12, 0.11, 0.14, 0.92)
		st.set_corner_radius_all(8)
		st.set_border_width_all(2)
		st.border_color = Color(0.35, 0.4, 0.55)
		btn.add_theme_stylebox_override("normal", st)
		var sth = st.duplicate()
		sth.border_color = Color(0.6, 0.7, 1.0)
		btn.add_theme_stylebox_override("hover", sth)
		btn.add_theme_stylebox_override("pressed", sth)
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		var name_l = Label.new()
		name_l.name = "SkillName"
		name_l.text = "???"
		name_l.position = Vector2(2, 4)
		name_l.size = Vector2(48, 20)
		name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_l.add_theme_font_size_override("font_size", 9)
		name_l.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(name_l)
		var key_l = Label.new()
		key_l.name = "KeyLabel"
		key_l.text = slots[i]
		key_l.position = Vector2(2, 22)
		key_l.size = Vector2(48, 18)
		key_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key_l.add_theme_font_size_override("font_size", 12)
		key_l.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
		key_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(key_l)
		var cd_l = Label.new()
		cd_l.name = "CdLabel"
		cd_l.text = ""
		cd_l.position = Vector2(2, 14)
		cd_l.size = Vector2(48, 24)
		cd_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cd_l.add_theme_font_size_override("font_size", 16)
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
		if sk.is_empty() or not SKILLS.skill_unlocked(sk):
			stn.border_color = Color(0.3, 0.3, 0.3)
		else:
			stn.border_color = Color(0.35, 0.4, 0.55)
		btn.add_theme_stylebox_override("normal", stn)

# ---------- MOCHILA (B) ----------
func build_bag() -> void:
	bag_panel = Panel.new()
	bag_panel.position = Vector2(340, 100)
	bag_panel.size = Vector2(280, 320)
	bag_panel.visible = false
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.1, 0.09, 0.12, 0.95)
	st.set_corner_radius_all(10)
	st.set_border_width_all(2)
	st.border_color = Color(0.45, 0.38, 0.22)
	bag_panel.add_theme_stylebox_override("panel", st)
	add_child(bag_panel)
	var title = _make_label("MOCHILA (B)", 16)
	title.position = Vector2(12, 8)
	bag_panel.add_child(title)
	bag_grid = GridContainer.new()
	bag_grid.columns = 5
	bag_grid.position = Vector2(12, 40)
	bag_panel.add_child(bag_grid)

func refresh_bag() -> void:
	for c in bag_grid.get_children():
		c.queue_free()
	for id in GameManager.bag:
		var qty: int = GameManager.bag[id]
		if qty <= 0:
			continue
		var slot = Button.new()
		slot.custom_minimum_size = Vector2(46, 46)
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.16, 0.14, 0.18, 0.95)
		st.set_corner_radius_all(6)
		slot.add_theme_stylebox_override("normal", st)
		slot.add_theme_stylebox_override("hover", st.duplicate())
		slot.add_theme_stylebox_override("pressed", st.duplicate())
		slot.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		var ic = TextureRect.new()
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.position = Vector2(5, 5)
		ic.size = Vector2(36, 36)
		ic.texture = ITEMS_DB.draw_icon(id)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(ic)
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
		if GameManager.use_item(id):
			AudioManager.play_sfx("potion")

# ---------- TELA DE MORTE ----------
func _build_death_screen() -> void:
	death_screen = Control.new()
	death_screen.visible = false
	death_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim = ColorRect.new()
	dim.color = Color(0.4, 0.05, 0.05, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	death_screen.add_child(dim)
	var msg = _make_label("VOCE MORREU", 42)
	msg.position = Vector2(440, 260)
	msg.add_theme_color_override("font_color", Color(0.95, 0.25, 0.2))
	death_screen.add_child(msg)
	var btn = Button.new()
	btn.text = "RENASCER NA CIDADE"
	btn.position = Vector2(540, 360)
	btn.size = Vector2(200, 50)
	btn.pressed.connect(_respawn)
	death_screen.add_child(btn)
	add_child(death_screen)

func _respawn() -> void:
	death_screen.visible = false
	if player_ref != null:
		GameManager.hp = GameManager.hp_max
		GameManager.mana = GameManager.mana_max
		player_ref.dead = false
		player_ref._play("idle")
		get_parent().switch_map("city1")

# ---------- ROUPAS (C) ----------
func build_cloth_panel() -> void:
	cloth_panel = Panel.new()
	cloth_panel.position = Vector2(340, 100)
	cloth_panel.size = Vector2(280, 380)
	cloth_panel.visible = false
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.1, 0.09, 0.12, 0.95)
	st.set_corner_radius_all(10)
	st.set_border_width_all(2)
	st.border_color = Color(0.3, 0.4, 0.55)
	cloth_panel.add_theme_stylebox_override("panel", st)
	add_child(cloth_panel)
	var title = _make_label("APARENCIA (C)", 16)
	title.position = Vector2(12, 8)
	cloth_panel.add_child(title)
	# preview do knight com as cores atuais
	var prev = TextureRect.new()
	prev.name = "Preview"
	prev.position = Vector2(90, 40)
	prev.size = Vector2(96, 96)
	prev.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	prev.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cloth_panel.add_child(prev)
	var t_label = _make_label("Tunica (T):", 12)
	t_label.position = Vector2(12, 150)
	cloth_panel.add_child(t_label)
	cloth_grid = GridContainer.new()
	cloth_grid.columns = 4
	cloth_grid.position = Vector2(12, 172)
	cloth_panel.add_child(cloth_grid)
	var h_label = _make_label("Cabelo (Y):", 12)
	h_label.position = Vector2(12, 240)
	cloth_panel.add_child(h_label)
	var hair_grid = GridContainer.new()
	hair_grid.name = "HairGrid"
	hair_grid.columns = 4
	hair_grid.position = Vector2(12, 262)
	cloth_panel.add_child(hair_grid)
	var p_label = _make_label("Calca (U):", 12)
	p_label.position = Vector2(12, 310)
	cloth_panel.add_child(p_label)
	var pants_grid = GridContainer.new()
	pants_grid.name = "PantsGrid"
	pants_grid.columns = 4
	pants_grid.position = Vector2(12, 332)
	cloth_panel.add_child(pants_grid)
	refresh_cloth()

func refresh_cloth() -> void:
	# preview: knight com as cores atuais
	var prev: TextureRect = cloth_panel.get_node("Preview")
	var texs = TEXHELPER.load_sheet_custom("res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png", player_ref.weapon if player_ref else "sword", player_ref.hair_color if player_ref else "castanho", player_ref.tunic_color if player_ref else "castanho", player_ref.pants_color if player_ref else "marrom")
	if texs.size() > 0:
		prev.texture = texs[0]
	for c in cloth_grid.get_children():
		c.queue_free()
	for c in cloth_panel.get_node("HairGrid").get_children():
		c.queue_free()
	for c in cloth_panel.get_node("PantsGrid").get_children():
		c.queue_free()
	for c_name in EQUIPS.CLOTHES_COLORS:
		var sw = Button.new()
		sw.custom_minimum_size = Vector2(40, 30)
		sw.text = c_name.substr(0, 4)
		var col: Color = EQUIPS.CLOTHES_COLORS[c_name]
		var st = StyleBoxFlat.new()
		st.bg_color = Color(col.r, col.g, col.b, 0.9)
		st.set_corner_radius_all(5)
		sw.add_theme_stylebox_override("normal", st)
		sw.add_theme_stylebox_override("hover", st.duplicate())
		sw.add_theme_stylebox_override("pressed", st.duplicate())
		sw.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		sw.pressed.connect(_set_tunic.bind(c_name))
		cloth_grid.add_child(sw)
	for c_name in EQUIPS.CLOTHES_COLORS:
		var sw2 = Button.new()
		sw2.custom_minimum_size = Vector2(40, 30)
		sw2.text = c_name.substr(0, 4)
		var col2: Color = EQUIPS.CLOTHES_COLORS[c_name]
		var st2 = StyleBoxFlat.new()
		st2.bg_color = Color(col2.r, col2.g, col2.b, 0.9)
		st2.set_corner_radius_all(5)
		sw2.add_theme_stylebox_override("normal", st2)
		sw2.add_theme_stylebox_override("hover", st2.duplicate())
		sw2.add_theme_stylebox_override("pressed", st2.duplicate())
		sw2.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		sw2.pressed.connect(_set_hair.bind(c_name))
		cloth_panel.get_node("HairGrid").add_child(sw2)
	for p_name in EQUIPS.PANTS_COLORS:
		var sw3 = Button.new()
		sw3.custom_minimum_size = Vector2(40, 30)
		sw3.text = p_name.substr(0, 4)
		var col3: Color = EQUIPS.PANTS_COLORS[p_name]
		var st3 = StyleBoxFlat.new()
		st3.bg_color = Color(col3.r, col3.g, col3.b, 0.9)
		st3.set_corner_radius_all(5)
		sw3.add_theme_stylebox_override("normal", st3)
		sw3.add_theme_stylebox_override("hover", st3.duplicate())
		sw3.add_theme_stylebox_override("pressed", st3.duplicate())
		sw3.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		sw3.pressed.connect(_set_pants.bind(p_name))
		cloth_panel.get_node("PantsGrid").add_child(sw3)

func _set_tunic(c_name: String) -> void:
	if player_ref != null:
		player_ref.tunic_color = c_name
		player_ref._build_frames()
		refresh_cloth()

func _set_hair(c_name: String) -> void:
	if player_ref != null:
		player_ref.hair_color = c_name
		player_ref._build_frames()
		refresh_cloth()

func _set_pants(p_name: String) -> void:
	if player_ref != null:
		player_ref.pants_color = p_name
		player_ref._build_frames()
		refresh_cloth()

# ---------- SKILLS (K) ----------
func build_skills_panel() -> void:
	skills_panel = Panel.new()
	skills_panel.position = Vector2(340, 100)
	skills_panel.size = Vector2(320, 400)
	skills_panel.visible = false
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.1, 0.09, 0.12, 0.95)
	st.set_corner_radius_all(10)
	st.set_border_width_all(2)
	st.border_color = Color(0.55, 0.45, 0.2)
	skills_panel.add_theme_stylebox_override("panel", st)
	add_child(skills_panel)
	var title = _make_label("SKILLS (K)", 16)
	title.position = Vector2(12, 8)
	skills_panel.add_child(title)
	skills_grid = GridContainer.new()
	skills_grid.columns = 2
	skills_grid.position = Vector2(12, 40)
	skills_panel.add_child(skills_grid)
	refresh_skills_panel()

func refresh_skills_panel() -> void:
	for c in skills_grid.get_children():
		c.queue_free()
	if player_ref == null:
		return
	var list = SKILLS.SKILLS.get(player_ref.weapon, [])
	for sk in list:
		var unlocked = SKILLS.skill_unlocked(sk)
		var l = _make_label("")
		l.add_theme_font_size_override("font_size", 12)
		if unlocked:
			l.text = "%s [%s] — %s" % [sk["nome"], sk["tecla"], sk["desc"]]
			l.add_theme_color_override("font_color", Color(0.85, 0.85, 0.7))
		else:
			l.text = "??? [%s] — desbloqueia na VILA" % sk["tecla"]
			l.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		skills_grid.add_child(l)

# ---------- FEEDBACK CENTRAL ----------
func build_feedback() -> void:
	feedback_label = _make_label("", 15)
	feedback_label.position = Vector2(400, 500)
	feedback_label.size = Vector2(480, 30)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	feedback_label.visible = false
	add_child(feedback_label)

func _on_feedback(msg: String) -> void:
	feedback_label.text = msg
	feedback_label.visible = true
	feedback_time = 2.0

# ---------- DICA DE OBJETIVO ----------
func build_hint() -> void:
	hint_label = _make_label("", 12)
	hint_label.position = Vector2(400, 680)
	hint_label.size = Vector2(480, 24)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	add_child(hint_label)

func set_hint(txt: String) -> void:
	hint_label.text = txt

# ---------- TOGGLES (exclusivos + centralizados) ----------
func toggle_bag() -> void:
	var opening = not bag_panel.visible
	cloth_panel.visible = false
	skills_panel.visible = false
	bag_panel.visible = opening
	if opening:
		refresh_bag()

func toggle_cloth_panel() -> void:
	var opening = not cloth_panel.visible
	bag_panel.visible = false
	skills_panel.visible = false
	cloth_panel.visible = opening
	if opening:
		refresh_cloth()

func toggle_skills_panel() -> void:
	var opening = not skills_panel.visible
	bag_panel.visible = false
	cloth_panel.visible = false
	skills_panel.visible = opening
	if opening:
		refresh_skills_panel()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C:
			AudioManager.play_sfx("ui_click")
			toggle_cloth_panel()
		elif event.keycode == KEY_B:
			AudioManager.play_sfx("ui_click")
			toggle_bag()
		elif event.keycode == KEY_K:
			AudioManager.play_sfx("ui_click")
			toggle_skills_panel()

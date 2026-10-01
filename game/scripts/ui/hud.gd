extends CanvasLayer
## HUD: barras, hotbar (1-4), SKILLS Q/E com botões (estilo Rucoy), flechas,
## mochila (B), roupas+calça (C), tela de skills (K), morte

const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")
const EQUIPS = preload("res://scripts/autoload/equips.gd")
const ITEMS_DB = preload("res://scripts/autoload/items_db.gd")
const SKILLS = preload("res://scripts/autoload/skills_db.gd")
const RARITY = preload("res://scripts/autoload/rarity.gd")

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
var fed_label: Label
var bag_panel: Control
var bag_grid: GridContainer
var fuse_grid: GridContainer
var _fuse_sig: String = ""
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
	fed_label = _make_label(Vector2(20, 202), 12, Color(0.55, 0.9, 0.5))
	fed_label.visible = false
	_build_hotbar()
	_build_skill_buttons()
	_build_bag()
	_build_death_screen()
	_build_cloth_panel()
	_build_skills_panel()
	_build_bestiary_panel()
	_build_feedback()
	_build_chat()
	GameManager.quest_ready.connect(_on_quest_ready)

# quest concluida (falta entregar): aviso fixo no HUD
var quest_alert: Label

func _on_quest_ready(id: String) -> void:
	if quest_alert == null:
		quest_alert = _make_label(Vector2(0, 560), 15, Color(0.4, 1.0, 0.5))
		quest_alert.size = Vector2(1280, 26)
		quest_alert.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(quest_alert)
	var q: Dictionary = GameManager.QUESTS.get(id, {})
	quest_alert.text = "MISSAO PRONTA: %s — entregue no Mestre das Missoes [J]!" % q.get("desc", id)
	quest_alert.visible = true
	var tw = quest_alert.create_tween()
	tw.tween_interval(6.0)
	tw.tween_property(quest_alert, "modulate:a", 0.0, 1.0)
	tw.tween_callback(func(): quest_alert.visible = false)

# ---------- CHAT (Area 9 multiplayer) ----------
var chat_panel: Control
var chat_log: RichTextLabel
var chat_input: LineEdit
var chat_open: bool = false
var _chat_lines: int = 0

func _build_chat() -> void:
	chat_panel = Control.new()
	chat_panel.position = Vector2(20, 420)
	chat_panel.size = Vector2(360, 200)
	chat_panel.visible = false
	add_child(chat_panel)
	var bg = ColorRect.new()
	bg.position = Vector2(0, 0)
	bg.size = Vector2(360, 200)
	bg.color = Color(0.05, 0.05, 0.08, 0.72)
	chat_panel.add_child(bg)
	chat_log = RichTextLabel.new()
	chat_log.position = Vector2(6, 4)
	chat_log.size = Vector2(348, 160)
	chat_log.scroll_following = true
	chat_log.bbcode_enabled = true
	chat_log.add_theme_font_size_override("normal_font_size", 12)
	chat_panel.add_child(chat_log)
	chat_input = LineEdit.new()
	chat_input.position = Vector2(6, 168)
	chat_input.size = Vector2(348, 26)
	chat_input.placeholder_text = "Enter p/ abrir chat, Enter envia, Esc fecha..."
	chat_input.add_theme_font_size_override("font_size", 12)
	chat_panel.add_child(chat_input)
	chat_input.text_submitted.connect(_on_chat_submit)
	NetworkManager.chat_message.connect(_on_chat_message)
	_append_chat("system", "Bem-vindo ao Grimstone! Enter = chat global.")

func _on_chat_message(sender: String, text: String, kind: String) -> void:
	match kind:
		"msg":
			_append_chat("msg", "[color=#9fd4ff]%s:[/color] %s" % [sender, text])
		"join":
			_append_chat("join", "[color=#7fd47f]* %s %s[/color]" % [sender, text])
		"leave":
			_append_chat("leave", "[color=#c9a06a]* %s %s[/color]" % [sender, text])
		_:
			_append_chat("system", "[color=#d8c88a]%s[/color]" % text)

func _append_chat(kind: String, bbcode: String) -> void:
	chat_log.append_text(bbcode + "\n")
	_chat_lines += 1

func toggle_chat() -> void:
	chat_open = not chat_open
	chat_panel.visible = chat_open
	if chat_open:
		AudioManager.play_sfx("ui_click")
		chat_input.grab_focus()
	else:
		chat_input.release_focus()
		chat_input.text = ""

func _on_chat_submit(text: String) -> void:
	text = text.strip_edges()
	if text != "":
		NetworkManager.send_chat(text)
	chat_input.text = ""
	# fecha o chat depois de enviar (estilo Rucoy)
	toggle_chat()

func chat_is_typing() -> bool:
	return chat_open

func _build_feedback() -> void:
	feedback_label = _make_label(Vector2(0, 590), 16, Color(1.0, 0.75, 0.3))
	feedback_label.size = Vector2(1280, 30)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.visible = false
	add_child(feedback_label)

func _show_feedback(msg: String) -> void:
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
	if p != null and not p.feedback.is_connected(_show_feedback):
		p.feedback.connect(_show_feedback)

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
	# comida/energia: indicador "BEM ALIMENTADO" com minutos restantes
	if GameManager.well_fed_time > 0.0:
		fed_label.text = "BEM ALIMENTADO (%s) — regen 2x" % GameManager.fmt_time_min(GameManager.well_fed_time / 60.0)
		fed_label.visible = true
	else:
		fed_label.visible = false
	if player_ref != null:
		var w = EQUIPS.WEAPONS[player_ref.weapon]
		class_label.text = "%s (arma: %s)  [1-4 arma | Q/E/R/G skills | B mochila | C roupas | K skills | N bestiario | J missoes | T banco | F loja | Enter chat]" % [w["classe"], w["nome"]]
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
	if NetworkManager.is_online():
		map_label.text = "Nivel %d  |  %s  |  [ONLINE %d]" % [GameManager.level, GameManager.current_map, NetworkManager.online_count()]
	if bag_panel.visible:
		_refresh_bag()
		_refresh_fuse()

# ---------- FUSAO (v0.6.1): 3 iguais do mesmo tier -> 1 do tier seguinte ----------
func _refresh_fuse() -> void:
	# so reconstrói quando as opcoes de fusao mudam
	var sig := "%d|" % GameManager.coins
	for id in GameManager.bag.keys():
		if GameManager.bag[id] >= 3:
			sig += "%s:%d," % [id, GameManager.bag[id]]
	if sig == _fuse_sig:
		return
	_fuse_sig = sig
	for c in fuse_grid.get_children():
		c.queue_free()
	for id in GameManager.bag.keys():
		if not GameManager.can_fuse(id):
			continue
		var tier := RARITY.tier_of(id)
		var slot = Button.new()
		slot.custom_minimum_size = Vector2(46, 46)
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.16, 0.15, 0.18, 0.9)
		st.set_corner_radius_all(6)
		st.set_border_width_all(2)
		st.border_color = RARITY.cor(tier)
		slot.add_theme_stylebox_override("normal", st)
		var icon = TextureRect.new()
		icon.texture = ITEMS_DB.draw_icon(id, 32)
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(icon)
		var qty = Label.new()
		qty.text = "x%d" % GameManager.bag[id]
		qty.position = Vector2(24, 28)
		qty.add_theme_font_size_override("font_size", 10)
		qty.add_theme_color_override("font_color", Color(1, 1, 0.8))
		qty.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(qty)
		slot.tooltip_text = "%s -> %s (50 moedas)" % [_item_display_name(id), _item_display_name(RARITY.key_with_tier(id.split("#")[0], tier + 1))]
		slot.pressed.connect(_fuse_click.bind(id))
		fuse_grid.add_child(slot)

func _item_display_name(id: String) -> String:
	var base: String = id.split("#")[0]
	var nome: String = ITEMS_DB.ITEMS.get(base, {}).get("nome", base)
	var tier := RARITY.tier_of(id)
	if tier > 0:
		nome += " " + RARITY.NAMES[tier]
	return nome

func _fuse_click(id: String) -> void:
	if GameManager.fuse_item(id):
		_show_feedback("FUSAO! %s fundido!" % _item_display_name(id))
		GameManager.save_game()
	else:
		_show_feedback("Nao foi possivel fundir (3 iguais + 50 moedas)")
	_refresh_fuse()

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

# ---------- BOTÕES DE SKILL (Q/E/R/G, estilo Rucoy) ----------
func _build_skill_buttons() -> void:
	for i in range(4):
		var slot = ["Q", "E", "R", "G"][i]
		var btn = Button.new()
		btn.position = Vector2(760 + i * 50, 640)
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
		btn.pressed.connect(_press_skill.bind(slot))
		add_child(btn)
		skill_btns[slot] = btn

func _press_skill(slot: String) -> void:
	if player_ref != null and not player_ref.dead:
		player_ref._use_skill(slot)

func _process_skill_buttons() -> void:
	var list = SKILLS.SKILLS.get(player_ref.weapon, [])
	for i in range(4):
		var slot = ["Q", "E", "R", "G"][i]
		var btn = skill_btns[slot]
		var name_l = btn.get_node("SkillName")
		if i < list.size():
			name_l.text = list[i]["nome"].split(" ")[0]
		elif GameManager.city2_unlocked:
			name_l.text = "—"
		else:
			name_l.text = "🔒"
		var stn = StyleBoxFlat.new()
		stn.bg_color = Color(0.12, 0.11, 0.14, 0.92)
		stn.set_corner_radius_all(8)
		stn.set_border_width_all(2)
		if i >= list.size() and not GameManager.city2_unlocked:
			stn.border_color = Color(0.4, 0.4, 0.45)
		elif player_ref.skill_ready[slot]:
			stn.border_color = Color(0.4, 0.8, 0.4)
		else:
			stn.border_color = Color(0.6, 0.2, 0.2)
		btn.add_theme_stylebox_override("normal", stn)

# ---------- MOCHILA (tecla B) ----------
func _build_bag() -> void:
	bag_panel = Control.new()
	bag_panel.visible = false
	add_child(bag_panel)
	var bg = ColorRect.new()
	bg.position = Vector2(495, 130)
	bg.size = Vector2(290, 460)
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
	var fuse_title = _make_label(Vector2(510, 420), 13, Color(0.95, 0.8, 0.3))
	fuse_title.text = "FUSAO (3 iguais -> tier seguinte):"
	bag_panel.add_child(fuse_title)
	fuse_grid = GridContainer.new()
	fuse_grid.columns = 5
	fuse_grid.position = Vector2(510, 445)
	fuse_grid.add_theme_constant_override("h_separation", 6)
	fuse_grid.add_theme_constant_override("v_separation", 6)
	bag_panel.add_child(fuse_grid)
	var hint = _make_label(Vector2(510, 560), 12, Color(0.7, 0.7, 0.75))
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
			slot.tooltip_text = _item_display_name(id)
			slot.pressed.connect(_use_bag_item.bind(id))
		bag_grid.add_child(slot)

func _use_bag_item(id: String) -> void:
	if player_ref == null or player_ref.dead:
		return
	var base: String = id.split("#")[0]
	var it = ITEMS_DB.ITEMS.get(base, null)
	if it == null:
		return
	if it["tipo"] == "arma":
		player_ref.weapon = id
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

# ---------- PAINEL DE ROUPAS (tecla C) — tunica, cabelo E CALCA ----------
func _build_cloth_panel() -> void:
	cloth_panel = Control.new()
	cloth_panel.visible = false
	add_child(cloth_panel)
	var bg = ColorRect.new()
	bg.position = Vector2(400, 130)
	bg.size = Vector2(480, 460)
	bg.color = Color(0.1, 0.09, 0.12, 0.95)
	cloth_panel.add_child(bg)
	var title = _make_label(Vector2(430, 145), 20, Color(1, 1, 1))
	title.text = "CUSTOMIZAR PERSONAGEM"
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
	var lp = _make_label(Vector2(430, 430), 14, Color(1, 1, 1))
	lp.text = "CALCA (clique a cor)"
	cloth_panel.add_child(lp)
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
	var pcores = EQUIPS.PANTS_COLORS.keys()
	for i in range(pcores.size()):
		var p_name = pcores[i]
		var sw3 = Button.new()
		sw3.position = Vector2(430 + i * 34, 456)
		sw3.size = Vector2(30, 30)
		var st3 = StyleBoxFlat.new()
		st3.bg_color = EQUIPS.PANTS_COLORS[p_name]
		st3.set_corner_radius_all(6)
		sw3.add_theme_stylebox_override("normal", st3)
		sw3.pressed.connect(_set_pants.bind(p_name))
		cloth_panel.add_child(sw3)
	var hint = _make_label(Vector2(430, 520), 12, Color(0.7, 0.7, 0.75))
	hint.text = "C para fechar"
	cloth_panel.add_child(hint)

func _set_tunic(c: String) -> void:
	if player_ref != null:
		player_ref.tunic_color = c
		player_ref._build_frames()

func _set_hair(c: String) -> void:
	if player_ref != null:
		player_ref.hair_color = c
		player_ref._build_frames()

func _set_pants(c: String) -> void:
	if player_ref != null:
		player_ref.pants_color = c
		player_ref._build_frames()

# ---------- TELA DE SKILLS (tecla K) — estilo Rucoy ----------
func _build_skills_panel() -> void:
	skills_panel = Control.new()
	skills_panel.visible = false
	add_child(skills_panel)
	var bg = ColorRect.new()
	bg.position = Vector2(340, 120)
	bg.size = Vector2(600, 480)
	bg.color = Color(0.08, 0.08, 0.11, 0.97)
	skills_panel.add_child(bg)
	var title = Label.new()
	title.text = "SKILLS"
	title.position = Vector2(370, 135)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	skills_panel.add_child(title)

func toggle_skills_panel() -> void:
	skills_panel.visible = not skills_panel.visible
	if skills_panel.visible:
		_refresh_skills_panel()
		bag_panel.visible = false
		cloth_panel.visible = false

func _refresh_skills_panel() -> void:
	for c in skills_panel.get_children():
		if c is Label and c.text != "SKILLS":
			c.queue_free()
	var y := 180.0
	var combat = {"espada": "Espada", "machado": "Machado", "distancia": "Distancia", "magia": "Magia", "defesa": "Defesa"}
	for sk in combat:
		if GameManager.skills.has(sk):
			var l = _make_label(Vector2(370, y), 15, Color(0.9, 0.9, 0.95))
			l.text = "%s: nivel %d  (%d/%d xp)  — up em ~%s" % [combat[sk], GameManager.skills[sk]["level"], GameManager.skills[sk]["xp"], GameManager.skill_xp_need(sk), GameManager.skill_time_left(sk)]
			y += 26
	y += 10
	var ll = _make_label(Vector2(370, y), 15, Color(0.95, 0.8, 0.3))
	ll.text = "Proximo LEVEL em ~%s" % GameManager.level_time_left()
	y += 30
	if player_ref != null:
		var st = _make_label(Vector2(370, y), 16, Color(0.6, 0.9, 1.0))
		st.text = "Skills de %s (tecla ou botao no HUD):" % EQUIPS.WEAPONS[player_ref.weapon]["classe"]
		y += 30
		var list = SKILLS.SKILLS.get(player_ref.weapon, [])
		for i in range(list.size()):
			var sk = list[i]
			var ready := player_ref.skill_ready[sk["tecla"]]
			var l = _make_label(Vector2(370, y), 14, Color(0.4, 0.8, 0.4) if ready else Color(0.7, 0.3, 0.3))
			l.text = "[%s] %s  (mana %d, recarga %.0fs) — %s" % [sk["tecla"], sk["nome"], sk["mana"], sk["cd"], sk["desc"]]
			y += 24
		y += 10
		var crit_lv = GameManager.skills.get(player_ref.weapon, {"level": 10})["level"]
		var lc = _make_label(Vector2(370, y), 14, Color(1.0, 0.85, 0.3))
		lc.text = "Chance de critico: %.1f%% (dano x2)" % (SKILLS.crit_chance(crit_lv) * 100.0)
	var hint = _make_label(Vector2(370, 570), 12, Color(0.7, 0.7, 0.75))
	hint.text = "K para fechar"
	skills_panel.add_child(hint)

# ---------- BESTIARIO (tecla N) ----------
var bestiary_panel: Control
var bestiary_grid: GridContainer

func _build_bestiary_panel() -> void:
	bestiary_panel = Control.new()
	bestiary_panel.visible = false
	add_child(bestiary_panel)
	var bg = ColorRect.new()
	bg.position = Vector2(340, 120)
	bg.size = Vector2(600, 500)
	bg.color = Color(0.1, 0.08, 0.1, 0.97)
	bestiary_panel.add_child(bg)
	var title = Label.new()
	title.text = "BESTIARIO"
	title.position = Vector2(370, 135)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.9, 0.5, 0.5))
	bestiary_panel.add_child(title)
	bestiary_grid = GridContainer.new()
	bestiary_grid.columns = 1
	bestiary_grid.position = Vector2(370, 180)
	bestiary_grid.add_theme_constant_override("v_separation", 6)
	bestiary_panel.add_child(bestiary_grid)
	var hint = _make_label(Vector2(370, 590), 12, Color(0.7, 0.7, 0.75))
	hint.text = "N ou ESC fecha"
	bestiary_panel.add_child(hint)

func toggle_bestiary_panel() -> void:
	bestiary_panel.visible = not bestiary_panel.visible
	if bestiary_panel.visible:
		_refresh_bestiary()
		bag_panel.visible = false
		cloth_panel.visible = false
		skills_panel.visible = false

func _refresh_bestiary() -> void:
	for c in bestiary_grid.get_children():
		c.queue_free()
	for t in GameManager.BESTIARY_INFO:
		var info = GameManager.BESTIARY_INFO[t]
		var kills = GameManager.bestiary_count(t)
		var l = Label.new()
		if kills == 0:
			l.text = "???  — %s" % info["onde"]
			l.add_theme_color_override("font_color", Color(0.45, 0.45, 0.5))
		else:
			l.text = "%s  x%d  — %s\n%s" % [info["nome"], kills, info["onde"], info["desc"]]
			l.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		l.add_theme_font_size_override("font_size", 13)
		bestiary_grid.add_child(l)

func toggle_cloth_panel() -> void:
	cloth_panel.visible = not cloth_panel.visible
	if cloth_panel.visible:
		bag_panel.visible = false
		skills_panel.visible = false
		bestiary_panel.visible = false

func toggle_bag() -> void:
	bag_panel.visible = not bag_panel.visible
	if bag_panel.visible:
		cloth_panel.visible = false
		skills_panel.visible = false
		bestiary_panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C:
			toggle_cloth_panel()
		elif event.keycode == KEY_B:
			toggle_bag()
		elif event.keycode == KEY_K:
			toggle_skills_panel()
		elif event.keycode == KEY_N:
			toggle_bestiary_panel()
		elif event.keycode == KEY_ENTER:
			toggle_chat()
		elif event.keycode == KEY_ESCAPE:
			if chat_open:
				toggle_chat()
			else:
				close_all_panels()

func close_all_panels() -> void:
	bag_panel.visible = false
	cloth_panel.visible = false
	skills_panel.visible = false
	bestiary_panel.visible = false

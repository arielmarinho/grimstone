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

func _fuse_click(id: String) -> void:
	if player_ref == null or player_ref.dead:
		return
	var nome_antes := _item_display_name(id)
	var tier := RARITY.tier_of(id)
	if not GameManager.fuse_item(id):
		return
	AudioManager.play_sfx("level_up")
	var novo_id := RARITY.key_with_tier(id.split("#")[0], tier + 1)
	_show_feedback("FUSAO! %s -> %s!" % [nome_antes, _item_display_name(novo_id)])
	# se a arma equipada era uma das fundidas e sumiu, re-equipa a base
	if not GameManager.EQUIPS_OK(GameManager.weapon):
		GameManager.weapon = GameManager.weapon_base()
		if player_ref != null:
			player_ref.weapon = GameManager.weapon
			player_ref._build_frames()

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
		GameManager.weapon = wid
		player_ref._build_frames()

func _process_hotbar_highlight() -> void:
	for i in range(4):
		var slot = hotbar_slots[i]
		var stn = StyleBoxFlat.new()
		stn.bg_color = Color(0.12, 0.11, 0.14, 0.92)
		stn.set_corner_radius_all(8)
		stn.set_border_width_all(2)
		stn.border_color = Color(0.95, 0.8, 0.3) if GameManager.weapon_base() == WEAPON_KEYS[i] else Color(0.35, 0.3, 0.25)
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
	var hint = _make_label(Vector2(510, 480), 12, Color(0.7, 0.7, 0.75))
	hint.text = "Clique para usar/equipar | B fecha"
	bag_panel.add_child(hint)
	# --- secao de FUSAO (3 iguais do mesmo tier -> 1 do tier seguinte, 50 moedas) ---
	var ftitle = _make_label(Vector2(800, 140), 16, Color(1.0, 0.82, 0.25))
	ftitle.text = "FUSAO DE ITENS"
	bag_panel.add_child(ftitle)
	var fdesc = _make_label(Vector2(800, 162), 11, Color(0.75, 0.75, 0.8))
	fdesc.text = "3 iguais do mesmo tier + 50 moedas\n= 1 do tier seguinte (Lendario nao funde)"
	bag_panel.add_child(fdesc)
	fuse_grid = GridContainer.new()
	fuse_grid.columns = 4
	fuse_grid.position = Vector2(800, 200)
	fuse_grid.add_theme_constant_override("h_separation", 6)
	fuse_grid.add_theme_constant_override("v_separation", 6)
	bag_panel.add_child(fuse_grid)
	var fhint = _make_label(Vector2(800, 480), 12, Color(0.7, 0.7, 0.75))
	fhint.text = "Clique para fundir"
	bag_panel.add_child(fhint)
func _refresh_bag() -> void:
	# so reconstrói quando o conteudo da mochila muda (antes: a cada frame = 20 botoes novos por frame)
	var ids = GameManager.bag.keys()
	var sig := ""
	for id in ids:
		sig += "%s:%d," % [id, GameManager.bag[id]]
	if sig == _bag_sig:
		return
	_bag_sig = sig
	for c in bag_grid.get_children():
		c.queue_free()
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

func _item_display_name(id: String) -> String:
	var base: String = id.split("#")[0]
	var it = ITEMS_DB.ITEMS.get(base, null)
	if it == null:
		return base
	var tier := RARITY.tier_of(id)
	if tier > 0 and it.get("tipo", "") == "arma":
		return "%s %s" % [it["nome"], RARITY.sufixo(tier)]
	return it["nome"]

func _use_bag_item(id: String) -> void:
	if player_ref == null or player_ref.dead:
		return
	var base: String = id.split("#")[0]
	var it = ITEMS_DB.ITEMS.get(base, null)
	if it == null:
		return
	if it["tipo"] == "arma":
		# equipar arma da mochila — pode ter tier de raridade ("espada#2")
		player_ref.weapon = id
		GameManager.weapon = id
		player_ref._build_frames()
		if RARITY.tier_of(id) > 0:
			_show_feedback("Equipada: %s!" % _item_display_name(id))
	elif it["tipo"] == "uso":
		if GameManager.use_item(id):
			AudioManager.play_sfx("potion")
			if it.has("comida"):
				_show_feedback("Nham! Bem alimentado — regen 2x por %s" % GameManager.fmt_time_min(float(it["comida"]) / 60.0))
			elif it.has("hp") or it.has("mana"):
				_show_feedback("Usou %s" % it["nome"])
	elif it["tipo"] == "runa":
		_use_runa_item(id)

# ---------- RUNAS (v0.6.7) ----------
## usa a runa da mochila: consome a pedra e aplica o efeito no mundo.
## Se a runa precisa de alvo e nao ha monstro, devolve a pedra pra mochila.
func _use_runa_item(id: String) -> void:
	if player_ref == null or player_ref.dead:
		return
	var r = GameManager.RUNAS.get(id, null)
	if r == null:
		return
	var dmg: int = GameManager.runa_dano(id)
	match r["efeito"]:
		"fogo":
			var mob = player_ref._mob_in_range(400.0)
			if mob == null:
				_show_feedback("Nenhum monstro por perto para a %s" % it_name_of(id))
				return
			GameManager.remove_item(id, 1)
			var proj = preload("res://scripts/entities/projectile.gd").new()
			proj.setup(player_ref.global_position, mob.global_position, dmg, "staff", false, true)
			get_parent().add_child(proj)
			AudioManager.play_sfx("cast")
			_show_feedback("Runa de Fogo! %d de dano" % dmg)
		"gelo":
			var mob2 = player_ref._mob_in_range(400.0)
			if mob2 == null:
				_show_feedback("Nenhum monstro por perto para a %s" % it_name_of(id))
				return
			GameManager.remove_item(id, 1)
			mob2.stunned = 2.0
			mob2.take_damage(dmg)
			AudioManager.play_sfx("cast")
			_show_feedback("Runa de Gelo! Congelou por 2s (%d de dano)" % dmg)
		"trovoada":
			var hits := _runa_aoe(dmg, Color(0.95, 0.9, 0.3))
			if hits == 0:
				_show_feedback("Nenhum monstro por perto para a %s" % it_name_of(id))
				return
			GameManager.remove_item(id, 1)
			AudioManager.play_sfx("cast")
			_show_feedback("Runa da Trovoada! %d atingidos (%d de dano)" % [hits, dmg])
		"cura":
			GameManager.remove_item(id, 1)
			var cura := int(GameManager.hp_max * 0.4)
			GameManager.hp = min(GameManager.hp_max, GameManager.hp + cura)
			AudioManager.play_sfx("potion")
			_show_feedback("Runa de Cura! +%d HP" % cura)

## dano em area ao redor do player (runa da trovoada); retorna quantos foram atingidos
func _runa_aoe(dmg: int, cor: Color) -> int:
	var hits := 0
	for mob in get_tree().get_nodes_in_group("mobs"):
		if mob.dead:
			continue
		if player_ref.global_position.distance_to(mob.global_position) < 220.0:
			mob.take_damage(dmg)
			hits += 1
	# anel de energia no chao
	var ring = Sprite2D.new()
	ring.texture = _make_runa_ring(cor)
	ring.global_position = player_ref.global_position
	ring.z_index = 5
	get_parent().add_child(ring)
	var tw = ring.create_tween()
	tw.tween_property(ring, "scale", Vector2(2.2, 2.2), 0.4)
	tw.parallel().tween_property(ring, "modulate:a", 0.0, 0.4)
	tw.tween_callback(ring.queue_free)
	return hits

func _make_runa_ring(c: Color) -> ImageTexture:
	var img = Image.create(220, 220, false, Image.FORMAT_RGBA8)
	for y in range(220):
		for x in range(220):
			var d = Vector2(x - 110.0, y - 110.0).length()
			if d > 96.0 and d < 108.0:
				img.set_pixel(x, y, Color(c.r, c.g, c.b, 0.7))
	return ImageTexture.create_from_image(img)

func it_name_of(id: String) -> String:
	var base: String = id.split("#")[0]
	var it2 = ITEMS_DB.ITEMS.get(base, null)
	return it2["nome"] if it2 != null else id

# ---------- TELA DE MORTE ----------
func _build_death_screen() -> void:
	death_screen = Control.new()
	death_screen.visible = false
	add_child(death_screen)
	var dim = ColorRect.new()
	dim.color = Color(0.3, 0.0, 0.0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.size = Vector2(1280, 720)
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
	preview.size = Vector2(192, 192)
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
		sw3.pressed.connect(_set_pants.bind(p_name))
		cloth_panel.add_child(sw3)
	var hint = _make_label(Vector2(430, 560), 12, Color(0.7, 0.7, 0.75))
	hint.text = "C para fechar"
	cloth_panel.add_child(hint)

func _set_tunic(c: String) -> void:
	if player_ref != null:
		player_ref.tunic_color = c
		player_ref._build_frames()
	_update_preview()

func _set_hair(c: String) -> void:
	if player_ref != null:
		player_ref.hair_color = c
		player_ref._build_frames()
	_update_preview()

func _set_pants(c: String) -> void:
	if player_ref != null:
		player_ref.pants_color = c
		player_ref._build_frames()
	_update_preview()

func _update_preview() -> void:
	# preview do knight com as cores atuais (idle down, frame 0) — antes NUNCA era renderizado
	if player_ref == null:
		return
	var texs = TEXHELPER.load_sheet_custom(
		"res://assets/sprites/animation/player/knight/idle/down/knight_idle_down_base.png",
		player_ref.weapon, player_ref.hair_color, player_ref.tunic_color, player_ref.pants_color)
	if not texs.is_empty():
		preview.texture = texs[0]

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
		elif c is Button:
			c.queue_free()
	var y := 180.0
	var combat = {"espada": "Espada", "machado": "Machado", "distancia": "Distancia", "magia": "Magia", "defesa": "Defesa"}
	for sk in combat:
		if GameManager.skills.has(sk):
			var lv: int = GameManager.skills[sk]["level"]
			var need: int = GameManager.skill_xp_need(sk)
			var l = _make_label(Vector2(370, y), 15, Color(0.9, 0.9, 0.95))
			l.text = "%s: nivel %d  (%d/%d xp) — up em ~%s" % [combat[sk], lv, GameManager.skills[sk]["xp"], need, GameManager.skill_time_left(sk)]
			skills_panel.add_child(l)
			y += 26
	y += 10
	if player_ref != null:
		var st = _make_label(Vector2(370, y), 16, Color(0.6, 0.9, 1.0))
		st.text = "Skills de %s (aperte a tecla ou clique o botao no HUD):" % EQUIPS.WEAPONS[player_ref.weapon]["classe"]
		skills_panel.add_child(st)
		y += 30
		var list = SKILLS.SKILLS.get(player_ref.weapon, [])
		for i in range(list.size()):
			var sk = list[i]
			if not SKILLS.skill_unlocked(sk):
				var lb = _make_label(Vector2(370, y), 14, Color(0.55, 0.55, 0.6))
				lb.text = "[%s] ??? — desbloqueia ao chegar na VILA (city2)" % sk["tecla"]
				skills_panel.add_child(lb)
				y += 24
				continue
			var ready: bool = player_ref.skill_ready[sk["tecla"]]
			var l = _make_label(Vector2(370, y), 14, Color(0.4, 0.8, 0.4) if ready else Color(0.7, 0.3, 0.3))
			l.text = "[%s] %s  (mana %d, recarga %.0fs) — %s" % [sk["tecla"], sk["nome"], sk["mana"], sk["cd"], sk["desc"]]
			skills_panel.add_child(l)
			y += 24
		y += 10
		var crit_lv = GameManager.skills.get(EQUIPS.WEAPONS[player_ref.weapon]["skill"], {"level": 10})["level"]
		var lc = _make_label(Vector2(370, y), 14, Color(1.0, 0.85, 0.3))
		lc.text = "Chance de critico: %.1f%% (dano x2)" % (SKILLS.crit_chance(crit_lv) * 100.0)
		skills_panel.add_child(lc)
	var hint = _make_label(Vector2(370, 570), 12, Color(0.7, 0.7, 0.75))
	hint.text = "K para fechar"
	skills_panel.add_child(hint)
	# estimativas de progresso (estilo Tibia: o player sabe quanto falta)
	if player_ref != null:
		var est = _make_label(Vector2(370, 545), 13, Color(0.95, 0.75, 0.4))
		est.text = "Proximo LEVEL %d em ~%s (mata ~1 mob a cada 8s)" % [GameManager.level + 1, GameManager.level_time_left()]
		skills_panel.add_child(est)

# ---------- BESTIARIO (v0.6.6, tecla N): registro de caca estilo Tibia ----------
var bestiary_panel: Control

func _build_bestiary_panel() -> void:
	bestiary_panel = Control.new()
	bestiary_panel.visible = false
	add_child(bestiary_panel)
	var bg = ColorRect.new()
	bg.position = Vector2(340, 120)
	bg.size = Vector2(600, 480)
	bg.color = Color(0.08, 0.08, 0.11, 0.97)
	bestiary_panel.add_child(bg)
	var title = Label.new()
	title.text = "BESTIARIO"
	title.position = Vector2(370, 135)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	bestiary_panel.add_child(title)

func toggle_bestiary_panel() -> void:
	bestiary_panel.visible = not bestiary_panel.visible
	if bestiary_panel.visible:
		_refresh_bestiary_panel()
		bag_panel.visible = false
		cloth_panel.visible = false
		skills_panel.visible = false

func _refresh_bestiary_panel() -> void:
	for c in bestiary_panel.get_children():
		if c is Label and c.text != "BESTIARIO":
			c.queue_free()
	var y := 180.0
	var seen := 0
	for t in GameManager.BESTIARY_INFO:
		var info: Dictionary = GameManager.BESTIARY_INFO[t]
		var kills: int = GameManager.bestiary_count(t)
		if kills > 0:
			seen += 1
			var l = _make_label(Vector2(370, y), 14, Color(0.9, 0.9, 0.95))
			l.text = "%s — %d derrotado(s)   (%s)" % [info["nome"], kills, info["onde"]]
			bestiary_panel.add_child(l)
			y += 22
			var d = _make_label(Vector2(384, y), 12, Color(0.6, 0.65, 0.7))
			d.text = info["desc"]
			bestiary_panel.add_child(d)
			y += 24
		else:
			# nunca derrotado: fica oculto (estilo Tibia — descobre cacando)
			var l = _make_label(Vector2(370, y), 14, Color(0.45, 0.45, 0.5))
			l.text = "??? — monstro ainda nao enfrentado"
			bestiary_panel.add_child(l)
			y += 24
	var foot = _make_label(Vector2(370, y + 8), 13, Color(0.95, 0.75, 0.4))
	foot.text = "Descobertos: %d de %d" % [seen, GameManager.BESTIARY_INFO.size()]
	bestiary_panel.add_child(foot)
	var hint = _make_label(Vector2(370, 570), 12, Color(0.7, 0.7, 0.75))
	hint.text = "N para fechar"
	bestiary_panel.add_child(hint)

func toggle_cloth_panel() -> void:
	cloth_panel.visible = not cloth_panel.visible
	if cloth_panel.visible:
		_update_preview()
		bag_panel.visible = false
		skills_panel.visible = false

func toggle_bag() -> void:
	bag_panel.visible = not bag_panel.visible
	if bag_panel.visible:
		cloth_panel.visible = false
		skills_panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if not chat_open and player_ref != null and not player_ref.dead:
				toggle_chat()
			get_viewport().set_input_as_handled()
			return
		if chat_open:
			if event.keycode == KEY_ESCAPE:
				toggle_chat()
				get_viewport().set_input_as_handled()
			return  # enquanto digita, NAO passa teclas pro jogo
		if event.keycode == KEY_C:
			AudioManager.play_sfx("ui_click")
			toggle_cloth_panel()
		elif event.keycode == KEY_B:
			AudioManager.play_sfx("ui_click")
			toggle_bag()
		elif event.keycode == KEY_K:
			AudioManager.play_sfx("ui_click")
			toggle_skills_panel()
		elif event.keycode == KEY_J:
			# J: abre o painel de missoes se estiver perto do NPC (feedback se longe)
			var qnpc = get_tree().get_first_node_in_group("quest_npc")
			if qnpc != null and qnpc.has_method("open"):
				var pl = player_ref.global_position if player_ref != null else Vector2.ZERO
				if pl.distance_to(qnpc.global_position) < 120.0:
					qnpc.open()
				else:
					_show_feedback("Procure o MESTRE DAS MISSOES na cidade (marcado no mapa)!")
		elif event.keycode == KEY_N:
			AudioManager.play_sfx("ui_click")
			toggle_bestiary_panel()

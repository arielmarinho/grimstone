extends CanvasLayer
## HUD: barras, hotbar (1-4), SKILLS Q/E/R/G com botões (estilo Rucoy), flechas,
## mochila (B), roupas+calça (C), tela de skills (K), morte

const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")
const ITEMSDB = preload("res://scripts/autoload/items_db.gd")
const SKILLSDB = preload("res://scripts/autoload/skills_db.gd")
const EQUIPS = preload("res://scripts/autoload/equips.gd")

var player_ref: Node = null
var hotbar_slots: Array = []
var skill_btns := {}
var preview: TextureRect

const WEAPON_KEYS = ["sword", "axe", "bow", "staff"]

# construído por código (sem .tscn)
var hp_bar: ProgressBar
var mp_bar: ProgressBar
var xp_bar: ProgressBar
var lvl_label: Label
var coins_label: Label
var arrows_label: Label
var hint_label: Label
var inv_panel: Control
var death_screen: Control
var cloth_panel: Control
var skills_panel: Control

func setup(p: Node) -> void:
	player_ref = p
	_build_bars()
	_build_hotbar()
	_build_skill_buttons()
	_build_labels()
	_build_inventory()
	_build_clothes()
	_build_skills_panel()
	_build_death_screen()

func _process(_d: float) -> void:
	if player_ref == null or not is_instance_valid(player_ref):
		return
	hp_bar.value = player_ref.hp
	hp_bar.max_value = player_ref.max_hp
	mp_bar.value = player_ref.mp
	mp_bar.max_value = player_ref.max_mp
	xp_bar.value = player_ref.xp
	xp_bar.max_value = player_ref.xp_next
	lvl_label.text = "Lv %d" % player_ref.level
	coins_label.text = "%d" % player_ref.coins
	arrows_label.text = "%d" % player_ref.arrows
	for i in range(WEAPON_KEYS.size()):
		var slot = hotbar_slots[i]
		var stn: StyleBoxFlat = slot.get_theme_stylebox("normal")
		stn.border_color = Color(0.95, 0.8, 0.3) if player_ref.weapon == WEAPON_KEYS[i] else Color(0.35, 0.3, 0.25)
	# botões de skill: cooldown visual
	for tecla in skill_btns:
		var btn = skill_btns[tecla]
		var ready: bool = player_ref.skill_ready.get(tecla, false)
		btn.modulate = Color(1, 1, 1, 1.0) if ready else Color(0.5, 0.5, 0.5, 0.7)
	# dica de objetivo
	if hint_label != null:
		hint_label.text = _objetivo_atual()

func _objetivo_atual() -> String:
	var mapa: String = player_ref.current_map
	if mapa == "city":
		if not GameManager.city2_visited:
			return "Objetivo: atravesse o portao LESTE e chegue na VILA (city2) pra desbloquear skills avancadas!"
		return "Objetivo: cace na floresta (SUL da city2) ou explore a caverna (bueiro)."
	if mapa == "city2":
		return "Objetivo: treine no DUMMY, compre pocoes melhores e va pra FLORESTA (portao SUL)."
	if mapa == "forest":
		return "Objetivo: cace lobos e aranhas. Volte pra city2 pra comprar."
	if mapa == "cave":
		return "Objetivo: derrote os ratos e colete loot. Escada no fim = volta."
	return ""

# ---------- BARRAS ----------
func _build_bars() -> void:
	hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(16, 16)
	hp_bar.size = Vector2(220, 22)
	hp_bar.max_value = 100
	hp_bar.show_percentage = false
	var hpf := StyleBoxFlat.new()
	hpf.bg_color = Color(0.75, 0.15, 0.15)
	hp_bar.add_theme_stylebox_override("fill", hpf)
	add_child(hp_bar)
	var hpl = Label.new()
	hpl.name = "HpLabel"
	hpl.position = Vector2(24, 18)
	hp_bar.add_child(hpl)

	mp_bar = ProgressBar.new()
	mp_bar.position = Vector2(16, 42)
	mp_bar.size = Vector2(220, 16)
	mp_bar.max_value = 100
	mp_bar.show_percentage = false
	var mpf := StyleBoxFlat.new()
	mpf.bg_color = Color(0.2, 0.35, 0.8)
	mp_bar.add_theme_stylebox_override("fill", mpf)
	add_child(mp_bar)

	xp_bar = ProgressBar.new()
	xp_bar.position = Vector2(16, 62)
	xp_bar.size = Vector2(220, 8)
	xp_bar.max_value = 100
	xp_bar.show_percentage = false
	var xpf := StyleBoxFlat.new()
	xpf.bg_color = Color(0.85, 0.7, 0.2)
	xp_bar.add_theme_stylebox_override("fill", xpf)
	add_child(xp_bar)

	lvl_label = Label.new()
	lvl_label.position = Vector2(244, 16)
	lvl_label.text = "Lv 1"
	add_child(lvl_label)

func _build_labels() -> void:
	coins_label = Label.new()
	coins_label.position = Vector2(16, 78)
	coins_label.text = "0"
	add_child(coins_label)
	var coin_icon = TextureRect.new()
	coin_icon.texture = ITEMSDB.draw_icon("moeda")
	coin_icon.position = Vector2(16, 76)
	coin_icon.custom_minimum_size = Vector2(16, 16)
	coin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(coin_icon)
	coins_label.position = Vector2(38, 78)

	arrows_label = Label.new()
	arrows_label.position = Vector2(90, 78)
	arrows_label.text = "0"
	add_child(arrows_label)
	var arrow_icon = Label.new()
	arrow_icon.text = "^"
	arrow_icon.position = Vector2(76, 76)
	add_child(arrow_icon)

	hint_label = Label.new()
	hint_label.position = Vector2(16, 100)
	hint_label.add_theme_font_size_override("font_size", 12)
	hint_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.6))
	add_child(hint_label)

# ---------- HOTBAR (1-4) ----------
func _build_hotbar() -> void:
	for i in range(4):
		var slot = Panel.new()
		slot.position = Vector2(16 + i * 40, 640)
		slot.size = Vector2(36, 36)
		var stn := StyleBoxFlat.new()
		stn.bg_color = Color(0.15, 0.13, 0.1, 0.85)
		stn.border_color = Color(0.35, 0.3, 0.25)
		stn.set_border_width_all(2)
		slot.add_theme_stylebox_override("normal", stn)
		add_child(slot)
		var ic = TextureRect.new()
		ic.texture = ITEMSDB.draw_icon(WEAPON_KEYS[i])
		ic.position = Vector2(2, 2)
		ic.custom_minimum_size = Vector2(32, 32)
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.add_child(ic)
		var num = Label.new()
		num.text = str(i + 1)
		num.position = Vector2(2, 0)
		num.add_theme_font_size_override("font_size", 10)
		slot.add_child(num)
		hotbar_slots.append(slot)

# ---------- BOTÕES DE SKILL (Q/E/R/G, estilo Rucoy) ----------
func _build_skill_buttons() -> void:
	var slots = ["Q", "E", "R", "G"]
	for i in range(slots.size()):
		var btn = Button.new()
		btn.text = slots[i]
		btn.position = Vector2(180 + i * 44, 640)
		btn.size = Vector2(40, 40)
		var stn := StyleBoxFlat.new()
		stn.bg_color = Color(0.2, 0.16, 0.12, 0.9)
		stn.border_color = Color(0.6, 0.5, 0.3)
		stn.set_border_width_all(2)
		btn.add_theme_stylebox_override("normal", stn)
		btn.pressed.connect(_on_skill_btn.bind(slots[i]))
		add_child(btn)
		skill_btns[slots[i]] = btn
	# cadeado no R/G até desbloquear
	for tecla in ["R", "G"]:
		var lock = Label.new()
		lock.text = "\U+1F512".replace("\\U+1F512", "")
		lock.name = "Lock" + tecla
		lock.add_theme_font_size_override("font_size", 14)
		add_child(lock)
	_update_locks()

func _update_locks() -> void:
	for tecla in ["R", "G"]:
		var btn = skill_btns.get(tecla)
		if btn == null:
			continue
		if GameManager.city2_unlocked:
			btn.tooltip_text = "Skill avancada (desbloqueada!)"
		else:
			btn.tooltip_text = "Desbloqueia ao chegar na VILA (city2)"

func _on_skill_btn(tecla: String) -> void:
	if player_ref == null or not is_instance_valid(player_ref):
		return
	player_ref.try_skill(tecla)

# ---------- MOCHILA (B) ----------
func _build_inventory() -> void:
	inv_panel = Panel.new()
	inv_panel.position = Vector2(500, 100)
	inv_panel.size = Vector2(260, 320)
	var stn := StyleBoxFlat.new()
	stn.bg_color = Color(0.12, 0.1, 0.08, 0.95)
	stn.border_color = Color(0.5, 0.4, 0.25)
	stn.set_border_width_all(2)
	inv_panel.add_theme_stylebox_override("normal", stn)
	inv_panel.visible = false
	add_child(inv_panel)
	var title = Label.new()
	title.text = "MOCHILA (B fecha)"
	title.position = Vector2(10, 6)
	inv_panel.add_child(title)

func toggle_inventory() -> void:
	if inv_panel == null:
		return
	inv_panel.visible = not inv_panel.visible
	if inv_panel.visible:
		_refresh_inventory()

func _refresh_inventory() -> void:
	for c in inv_panel.get_children():
		if c is Label and c.text.begins_with("MOCHILA"):
			continue
		c.queue_free()
	var inv: Array = player_ref.inventory
	for i in range(inv.size()):
		var slot = inv[i]
		if slot == null:
			continue
		var ic = TextureRect.new()
		ic.texture = ITEMSDB.draw_icon(slot["id"])
		ic.position = Vector2(10 + (i % 5) * 48, 40 + int(i / 5.0) * 48)
		ic.custom_minimum_size = Vector2(32, 32)
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		inv_panel.add_child(ic)
		var q = Label.new()
		q.text = "x%d" % slot.get("qtd", 1)
		q.position = Vector2(10 + (i % 5) * 48 + 20, 40 + int(i / 5.0) * 48 + 20)
		q.add_theme_font_size_override("font_size", 10)
		inv_panel.add_child(q)
		var btn = Button.new()
		btn.flat = true
		btn.position = ic.position
		btn.size = Vector2(40, 40)
		btn.pressed.connect(_use_item.bind(i))
		inv_panel.add_child(btn)

func _use_item(idx: int) -> void:
	if player_ref and is_instance_valid(player_ref):
		player_ref.use_item(idx)
		_refresh_inventory()

# ---------- ROUPAS (C) ----------
func _build_clothes() -> void:
	cloth_panel = Panel.new()
	cloth_panel.position = Vector2(500, 100)
	cloth_panel.size = Vector2(260, 300)
	var stn := StyleBoxFlat.new()
	stn.bg_color = Color(0.12, 0.1, 0.08, 0.95)
	stn.border_color = Color(0.5, 0.4, 0.25)
	stn.set_border_width_all(2)
	cloth_panel.add_theme_stylebox_override("normal", stn)
	cloth_panel.visible = false
	add_child(cloth_panel)
	var title = Label.new()
	title.text = "ROUPAS (C fecha)"
	title.position = Vector2(10, 6)
	cloth_panel.add_child(title)
	# preview
	preview = TextureRect.new()
	preview.position = Vector2(90, 40)
	preview.custom_minimum_size = Vector2(96, 96)
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cloth_panel.add_child(preview)
	# cabelo
	var lh = Label.new()
	lh.text = "Cabelo [T]"
	lh.position = Vector2(10, 150)
	cloth_panel.add_child(lh)
	var bt = Button.new()
	bt.text = "Trocar"
	bt.position = Vector2(10, 175)
	bt.pressed.connect(func(): player_ref.cycle_hair())
	cloth_panel.add_child(bt)
	# tunica
	var ly = Label.new()
	ly.text = "Tunica [Y]"
	ly.position = Vector2(140, 150)
	cloth_panel.add_child(ly)
	var by = Button.new()
	by.text = "Trocar"
	by.position = Vector2(140, 175)
	by.pressed.connect(func(): player_ref.cycle_tunic())
	cloth_panel.add_child(by)
	# calca
	var lp = Label.new()
	lp.text = "Calca [P]"
	lp.position = Vector2(10, 215)
	cloth_panel.add_child(lp)
	var bp = Button.new()
	bp.text = "Trocar"
	bp.position = Vector2(10, 240)
	bp.pressed.connect(func(): player_ref.cycle_pants())
	cloth_panel.add_child(bp)

func toggle_clothes() -> void:
	if cloth_panel == null:
		return
	cloth_panel.visible = not cloth_panel.visible
	if inv_panel != null and cloth_panel.visible:
		inv_panel.visible = false
	if cloth_panel.visible:
		_refresh_clothes()

func _refresh_clothes() -> void:
	if player_ref and is_instance_valid(player_ref):
		preview.texture = TEXHELPER.get_knight_texture(player_ref.hair, player_ref.tunic, player_ref.pants, "down", 0, player_ref.weapon)

# ---------- TELA DE SKILLS (K) ----------
func _build_skills_panel() -> void:
	skills_panel = Panel.new()
	skills_panel.position = Vector2(240, 80)
	skills_panel.size = Vector2(720, 480)
	var stn := StyleBoxFlat.new()
	stn.bg_color = Color(0.1, 0.09, 0.07, 0.97)
	stn.border_color = Color(0.65, 0.55, 0.3)
	stn.set_border_width_all(3)
	skills_panel.add_theme_stylebox_override("normal", stn)
	skills_panel.visible = false
	add_child(skills_panel)
	var title = Label.new()
	title.text = "SKILLS (K fecha)"
	title.position = Vector2(16, 10)
	title.add_theme_font_size_override("font_size", 20)
	skills_panel.add_child(title)

func toggle_skills() -> void:
	if skills_panel == null:
		return
	skills_panel.visible = not skills_panel.visible
	if skills_panel.visible:
		_refresh_skills()

func _refresh_skills() -> void:
	for c in skills_panel.get_children():
		if c is Label and c.text.begins_with("SKILLS"):
			continue
		c.queue_free()
	var y := 50.0
	var cls: String = EQUIPS.WEAPONS[player_ref.weapon]["classe"]
	var header = Label.new()
	header.text = "Classe: %s" % cls
	header.position = Vector2(16, y)
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
	skills_panel.add_child(header)
	y += 34
	var skills = SKILLSDB.for_class(player_ref.weapon)
	for sk in skills:
		var unlocked: bool = not sk.get("city2", false) or GameManager.city2_unlocked
		if not unlocked:
			var lb0 = _make_label(Vector2(370, y), 14, Color(0.5, 0.5, 0.5))
			lb0.text = "[%s] ??? — desbloqueia ao chegar na VILA (city2)" % sk["tecla"]
			y += 24
			continue
		var ready: bool = player_ref.skill_ready[sk["tecla"]]
		var l = _make_label(Vector2(370, y), 14, Color(0.4, 0.8, 0.4) if ready else Color(0.7, 0.3, 0.3))
		l.text = "[%s] %s  (mana %d, recarga %.0fs) — %s" % [sk["tecla"], sk["nome"], sk["mana"], sk["cd"], sk["desc"]]
		y += 24

func _make_label(pos: Vector2, size: int, color: Color) -> Label:
	var l = Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	skills_panel.add_child(l)
	return l

# ---------- MORTE ----------
func _build_death_screen() -> void:
	death_screen = ColorRect.new()
	death_screen.color = Color(0.3, 0.0, 0.0, 0.75)
	death_screen.size = Vector2(1280, 720)
	death_screen.visible = false
	add_child(death_screen)
	var msg = Label.new()
	msg.text = "VOCE MORREU\n\nRespawn na cidade em 3s..."
	msg.position = Vector2(490, 300)
	msg.add_theme_font_size_override("font_size", 28)
	death_screen.add_child(msg)

func show_death() -> void:
	death_screen.visible = true

func hide_death() -> void:
	death_screen.visible = false

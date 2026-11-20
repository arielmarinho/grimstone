extends Node2D
## NPC do BANCO/DEPÓSITO — nas 2 cidades (tecla T perto dele), estilo Tibia:
## deposita itens da mochila pra liberar slots (BAG_MAX 20) e saca de volta.
## Moedas ficam no bolso (Tibia clássico não guarda moedas no banco).

const NA := preload("res://scripts/world/npc_art.gd")

var city: String = "city1"

var panel: Control
var msg_label: Label
var dep_grid: GridContainer
var bank_grid: GridContainer
var bank_count_label: Label
var npc_sprite: Sprite2D
var _sig: String = ""

const ITEMS_DB = preload("res://scripts/autoload/items_db.gd")
const RARITY = preload("res://scripts/autoload/rarity.gd")

func _ready() -> void:
	_build_npc()
	_build_panel()

# ---------- NPC VISUAL (sprite procedural — banqueiro de túnica dourada) ----------
func _build_npc() -> void:
	npc_sprite = Sprite2D.new()
	npc_sprite.texture = _make_npc_tex()
	npc_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	npc_sprite.scale = Vector2(NA.SPRITE_SCALE, NA.SPRITE_SCALE)
	npc_sprite.offset = Vector2(0.0, NA.sprite_offset_y())
	add_child(npc_sprite)
	var name_l = Label.new()
	name_l.text = "BANCO [T]"
	name_l.position = Vector2(-40, -58)
	name_l.add_theme_font_size_override("font_size", 14)
	name_l.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	name_l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	name_l.add_theme_constant_override("outline_size", 4)
	add_child(name_l)
	var tw = name_l.create_tween()
	tw.set_loops()
	tw.tween_property(name_l, "position:y", name_l.position.y - 6.0, 0.7)
	tw.tween_property(name_l, "position:y", name_l.position.y, 0.7)

func _make_npc_tex() -> ImageTexture:
	return ImageTexture.create_from_image(NA.bank_image())

# ---------- PAINEL (mesmo estilo da loja/quests) ----------
func _build_panel() -> void:
	panel = Control.new()
	panel.visible = false
	panel.z_index = 100
	add_child(panel)
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.09, 0.07, 0.97)
	bg.offset_left = 400
	bg.offset_top = 110
	bg.offset_right = 880
	bg.offset_bottom = 610
	panel.add_child(bg)
	var title = Label.new()
	title.text = "BANCO — DEPOSITO"
	title.position = Vector2(430, 125)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	panel.add_child(title)
	# coluna esquerda: mochila (depositar)
	var l1 = Label.new()
	l1.text = "MOCHILA (clique = depositar)"
	l1.position = Vector2(430, 165)
	l1.add_theme_font_size_override("font_size", 13)
	l1.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	panel.add_child(l1)
	dep_grid = GridContainer.new()
	dep_grid.columns = 5
	dep_grid.position = Vector2(430, 190)
	dep_grid.add_theme_constant_override("h_separation", 6)
	dep_grid.add_theme_constant_override("v_separation", 6)
	panel.add_child(dep_grid)
	# coluna direita: banco (sacar)
	var l2 = Label.new()
	l2.text = "DEPOSITO (clique = sacar)"
	l2.position = Vector2(680, 165)
	l2.add_theme_font_size_override("font_size", 13)
	l2.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	panel.add_child(l2)
	bank_grid = GridContainer.new()
	bank_grid.columns = 4
	bank_grid.position = Vector2(680, 190)
	bank_grid.add_theme_constant_override("h_separation", 6)
	bank_grid.add_theme_constant_override("v_separation", 6)
	panel.add_child(bank_grid)
	bank_count_label = Label.new()
	bank_count_label.position = Vector2(680, 400)
	bank_count_label.add_theme_font_size_override("font_size", 12)
	bank_count_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	panel.add_child(bank_count_label)
	msg_label = Label.new()
	msg_label.position = Vector2(430, 560)
	msg_label.add_theme_font_size_override("font_size", 13)
	msg_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.3))
	panel.add_child(msg_label)
	var hint = Label.new()
	hint.text = "ESC fecha | itens guardados ficam salvos no save"
	hint.position = Vector2(430, 580)
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	panel.add_child(hint)

func is_open() -> bool:
	return panel != null and panel.visible

func open() -> void:
	AudioManager.play_sfx("ui_click")
	# painel exclusivo (regra gs-ui-ux): abrir o banco fecha os outros paineis
	get_tree().call_group("hud", "close_all_panels")
	add_to_group("npc_panel")
	_sig = ""  # força refresh
	_refresh()
	panel.visible = true

func close() -> void:
	panel.visible = false
	remove_from_group("npc_panel")
	msg_label.text = ""

func _refresh() -> void:
	# só reconstrói quando mochila ou banco mudam (evita botões novos por frame)
	var sig := ""
	for id in GameManager.bag:
		sig += "b%s:%d," % [id, GameManager.bag[id]]
	for id in GameManager.bank:
		sig += "k%s:%d," % [id, GameManager.bank[id]]
	if sig == _sig:
		return
	_sig = sig
	for c in dep_grid.get_children():
		c.queue_free()
	for c in bank_grid.get_children():
		c.queue_free()
	# mochila -> depositar
	for id in GameManager.bag.keys():
		var slot = _make_slot(id, GameManager.bag[id], false)
		slot.pressed.connect(_on_deposit.bind(id))
		dep_grid.add_child(slot)
	if GameManager.bag.is_empty():
		dep_grid.add_child(_make_empty_label("mochila vazia"))
	# banco -> sacar
	for id in GameManager.bank.keys():
		var slot = _make_slot(id, GameManager.bank[id], true)
		slot.pressed.connect(_on_withdraw.bind(id))
		bank_grid.add_child(slot)
	if GameManager.bank.is_empty():
		bank_grid.add_child(_make_empty_label("deposito vazio"))
	var total := 0
	for id in GameManager.bank:
		total += GameManager.bank[id]
	bank_count_label.text = "%d tipos guardados" % total

func _make_slot(id: String, qty: int, from_bank: bool) -> Button:
	var slot = Button.new()
	slot.custom_minimum_size = Vector2(46, 46)
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.16, 0.15, 0.12, 0.9)
	st.set_corner_radius_all(6)
	st.set_border_width_all(1)
	st.border_color = Color(0.85, 0.7, 0.2) if from_bank else Color(0.3, 0.28, 0.25)
	slot.add_theme_stylebox_override("normal", st)
	var icon = TextureRect.new()
	icon.texture = ITEMS_DB.draw_icon(id, 32)
	icon.custom_minimum_size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(icon)
	var qty_l = Label.new()
	qty_l.text = str(qty)
	qty_l.position = Vector2(30, 28)
	qty_l.add_theme_font_size_override("font_size", 11)
	qty_l.add_theme_color_override("font_color", Color(1, 1, 0.8))
	qty_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(qty_l)
	var base: String = id.split("#")[0]
	var it = ITEMS_DB.ITEMS.get(base, null)
	slot.tooltip_text = (it["nome"] if it != null else base)
	return slot

func _make_empty_label(txt: String) -> Label:
	var l = Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6))
	return l

func _on_deposit(id: String) -> void:
	if GameManager.bank_deposit(id, 1):
		AudioManager.play_sfx("coin")
		msg_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
		msg_label.text = "Depositado: %s" % _display(id)
		_sig = ""  # força refresh
		_refresh()

func _on_withdraw(id: String) -> void:
	if GameManager.bank_withdraw(id, 1):
		AudioManager.play_sfx("pickup")
		msg_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
		msg_label.text = "Sacado: %s" % _display(id)
		_sig = ""
		_refresh()
	else:
		msg_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.3))
		msg_label.text = "Mochila cheia!"

func _display(id: String) -> String:
	var base: String = id.split("#")[0]
	var it = ITEMS_DB.ITEMS.get(base, null)
	var nome: String = it["nome"] if it != null else base
	var tier := RARITY.tier_of(id)
	if tier > 0 and it != null and it.get("tipo", "") == "arma":
		return "%s %s" % [nome, RARITY.sufixo(tier)]
	return nome

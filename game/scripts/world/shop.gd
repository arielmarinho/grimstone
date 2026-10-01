extends Node2D
## Loja — NPC/loja nas cidades: pocoes, armas e FLECHAS com moedas

const ITEMS_DB = preload("res://scripts/autoload/items_db.gd")

# catalogo por cidade: city1 = base, city2 = tiers melhores + bulk
const CATALOG_CITY1 = {
	"pocao_vida_p": 20,
	"pocao_mana_p": 25,
	"flecha": 2,
	"espada": 50,
	"machado": 120,
	"arco": 150,
	"cajado": 180,
}
const CATALOG_CITY2 = {
	"pocao_vida_m": 60,
	"pocao_vida_g": 110,
	"pocao_mana_m": 70,
	"pocao_mana_g": 130,
	"flecha": 1,
	"machado": 100,
	"arco": 130,
	"cajado": 160,
}

var city: String = "city1"

var panel: Control
var grid: GridContainer
var coins_label: Label
var msg_label: Label

func _ready() -> void:
	_build_panel()

func _build_panel() -> void:
	panel = Control.new()
	panel.visible = false
	panel.z_index = 100
	add_child(panel)
	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.1, 0.09, 0.97)
	bg.offset_left = 400
	bg.offset_top = 130
	bg.offset_right = 880
	bg.offset_bottom = 590
	panel.add_child(bg)
	var title = Label.new()
	title.text = "LOJA — " + ("CIDADE" if city == "city1" else "VILA")
	title.position = Vector2(430, 145)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	panel.add_child(title)
	coins_label = Label.new()
	coins_label.position = Vector2(700, 150)
	coins_label.add_theme_font_size_override("font_size", 15)
	coins_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.25))
	panel.add_child(coins_label)
	grid = GridContainer.new()
	grid.columns = 4
	grid.position = Vector2(430, 195)
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	panel.add_child(grid)
	msg_label = Label.new()
	msg_label.position = Vector2(430, 540)
	msg_label.add_theme_font_size_override("font_size", 13)
	msg_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.3))
	panel.add_child(msg_label)
	var hint = Label.new()
	hint.text = "ESC fecha"
	hint.position = Vector2(430, 560)
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	panel.add_child(hint)
	refresh()

func _catalog() -> Dictionary:
	return CATALOG_CITY2 if city == "city2" else CATALOG_CITY1

func refresh() -> void:
	coins_label.text = "Moedas: %d" % GameManager.coins
	for c in grid.get_children():
		c.queue_free()
	var ids = _catalog().keys()
	for id in ids:
		var slot = Button.new()
		slot.custom_minimum_size = Vector2(100, 90)
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.16, 0.15, 0.18, 0.95)
		st.set_corner_radius_all(8)
		st.set_border_width_all(1)
		st.border_color = Color(0.35, 0.3, 0.25)
		slot.add_theme_stylebox_override("normal", st)
		var icon = TextureRect.new()
		icon.texture = ITEMS_DB.draw_icon(id, 40)
		icon.position = Vector2(30, 8)
		icon.custom_minimum_size = Vector2(40, 40)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(icon)
		var name_l = Label.new()
		name_l.text = ITEMS_DB.ITEMS[id]["nome"]
		name_l.position = Vector2(6, 52)
		name_l.add_theme_font_size_override("font_size", 11)
		name_l.add_theme_color_override("font_color", Color(1, 1, 1))
		name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(name_l)
		var price = Label.new()
		price.text = "%d moedas" % _catalog()[id]
		price.position = Vector2(6, 68)
		price.add_theme_font_size_override("font_size", 11)
		price.add_theme_color_override("font_color", Color(0.95, 0.8, 0.25))
		price.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(price)
		slot.pressed.connect(_buy.bind(id))
		grid.add_child(slot)

func _buy(id: String) -> void:
	var price: int = _catalog()[id]
	if GameManager.coins < price:
		msg_label.text = "Moedas insuficientes!"
		return
	# flechas vao direto pro contador de municao
	if id == "flecha":
		GameManager.coins -= price
		GameManager.arrows += 10
		msg_label.text = "+10 flechas!"
		refresh()
		return
	if not GameManager.add_item(id, 1):
		msg_label.text = "Mochila cheia!"
		return
	GameManager.coins -= price
	msg_label.text = ""
	refresh()

func open() -> void:
	panel.visible = true
	refresh()

func close() -> void:
	panel.visible = false
	msg_label.text = ""

func is_open() -> bool:
	return panel.visible

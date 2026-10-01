extends Node2D
## NPC de quests — nas 2 cidades (tecla J perto dele): aceita/entrega missoes de caca
## Cadeia de 6 quests (GameManager.QUESTS): recompensa em moedas + XP

var city: String = "city1"
var QUESTS: Dictionary = {}  # preenchido no _ready (GameManager.QUESTS)

var panel: Control
var title_label: Label
var msg_label: Label
var rows := {}  # quest_id -> Label (status dinâmico)
var npc_sprite: Sprite2D

func _ready() -> void:
	QUESTS = GameManager.QUESTS
	_build_npc()
	_build_panel()

# ---------- NPC VISUAL (sprite procedural, estilo mob mas humano) ----------
func _build_npc() -> void:
	npc_sprite = Sprite2D.new()
	npc_sprite.texture = _make_npc_tex()
	npc_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	npc_sprite.scale = Vector2(2, 2)
	add_child(npc_sprite)
	var name_l = Label.new()
	name_l.text = "MESTRE DAS MISSOES [J]"
	name_l.position = Vector2(-70, -95)
	name_l.add_theme_font_size_override("font_size", 14)
	name_l.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	name_l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	name_l.add_theme_constant_override("outline_size", 4)
	add_child(name_l)
	var tw = name_l.create_tween()
	tw.set_loops()
	tw.tween_property(name_l, "position:y", name_l.position.y - 6.0, 0.7)
	tw.tween_property(name_l, "position:y", name_l.position.y, 0.7)

func _make_npc_tex() -> ImageTexture:
	var img = Image.create(96, 96, false, Image.FORMAT_RGBA8)
	var skin := Color(0.9, 0.72, 0.55)
	var robe := Color(0.25, 0.45, 0.75)   # tunica azul de mestre
	var robe_d := Color(0.18, 0.33, 0.58)
	var beard := Color(0.85, 0.85, 0.85)
	# sombra
	for x in range(30, 66):
		for y in range(90, 94):
			img.set_pixel(x, y, Color(0, 0, 0, 0.25))
	# pernas
	for x in range(40, 44):
		for y in range(72, 90):
			img.set_pixel(x, y, Color(0.25, 0.2, 0.15))
	for x in range(52, 56):
		for y in range(72, 90):
			img.set_pixel(x, y, Color(0.25, 0.2, 0.15))
	# tunica (corpo)
	for x in range(36, 60):
		for y in range(42, 74):
			var c := robe if x < 40 else robe_d if x >= 56 else robe
			img.set_pixel(x, y, c)
	# cinto
	for x in range(36, 60):
		img.set_pixel(x, 66, Color(0.35, 0.25, 0.12))
	# bracos
	for x in range(30, 36):
		for y in range(46, 66):
			img.set_pixel(x, y, robe_d)
	for x in range(60, 66):
		for y in range(46, 66):
			img.set_pixel(x, y, robe_d)
	# maos
	for x in range(30, 36):
		for y in range(66, 70):
			img.set_pixel(x, y, skin)
	for x in range(60, 66):
		for y in range(66, 70):
			img.set_pixel(x, y, skin)
	# cabeca
	for x in range(40, 56):
		for y in range(22, 42):
			img.set_pixel(x, y, skin)
	# cabelo (topo)
	for x in range(38, 58):
		for y in range(18, 26):
			img.set_pixel(x, y, Color(0.35, 0.25, 0.15))
	# barba branca (mestre)
	for x in range(42, 54):
		for y in range(38, 50):
			img.set_pixel(x, y, beard)
	# olhos
	img.set_pixel(44, 32, Color(0.1, 0.1, 0.1))
	img.set_pixel(51, 32, Color(0.1, 0.1, 0.1))
	# pergaminho na mao direita
	for x in range(58, 68):
		for y in range(60, 68):
			img.set_pixel(x, y, Color(0.92, 0.88, 0.7))
	return ImageTexture.create_from_image(img)

# ---------- PAINEL (mesmo estilo da loja) ----------
func _build_panel() -> void:
	panel = Control.new()
	panel.visible = false
	panel.z_index = 100
	add_child(panel)
	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.1, 0.12, 0.97)
	bg.offset_left = 420
	bg.offset_top = 120
	bg.offset_right = 860
	bg.offset_bottom = 600
	panel.add_child(bg)
	var title = Label.new()
	title.text = "MESTRE DAS MISSOES"
	title.position = Vector2(450, 135)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	panel.add_child(title)
	title_label = title
	msg_label = Label.new()
	msg_label.position = Vector2(450, 555)
	msg_label.add_theme_font_size_override("font_size", 13)
	msg_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.3))
	panel.add_child(msg_label)
	var hint = Label.new()
	hint.text = "ESC fecha"
	hint.position = Vector2(450, 578)
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	panel.add_child(hint)

func is_open() -> bool:
	return panel != null and panel.visible

func open() -> void:
	AudioManager.play_sfx("ui_click")
	_refresh()
	panel.visible = true

func close() -> void:
	panel.visible = false

func _refresh() -> void:
	# limpa linhas antigas
	for id in rows:
		if is_instance_valid(rows[id]):
			rows[id].queue_free()
	rows.clear()
	var y := 175.0
	var any_shown := false
	for id in QUESTS:
		var q: Dictionary = QUESTS[id]
		if q["npc"] != city:
			continue
		if not GameManager.quest_available(id):
			continue
		any_shown = true
		var st: Dictionary = GameManager.quest_state(id)
		var done: bool = st.get("done", false)
		var prog: int = int(st.get("progress", 0))
		var l = Label.new()
		l.position = Vector2(450, y)
		var status: String
		if done:
			status = "[ENTREGAR] +%d moedas, +%d xp" % [q["coins"], q["xp"]]
			l.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
		elif prog > 0:
			status = "em progresso: %d/%d" % [prog, q["qtd"]]
			l.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		else:
			status = "[ACEITAR] recompensa: %d moedas, %d xp" % [q["coins"], q["xp"]]
			l.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		l.text = "%s\n  %s — %s" % [id.trim_prefix("q_").capitalize(), q["desc"], status]
		l.add_theme_font_size_override("font_size", 15)
		panel.add_child(l)
		rows[id] = l
		# botao clicavel por cima da linha
		var btn = Button.new()
		btn.flat = true
		btn.position = Vector2(450, y - 4)
		btn.size = Vector2(390, 46)
		btn.pressed.connect(_on_quest_clicked.bind(id))
		panel.add_child(btn)
		y += 62.0
	if not any_shown:
		var l = Label.new()
		l.text = "Nenhuma missao disponivel agora.\nVolte quando completar as anteriores!"
		l.position = Vector2(450, 200)
		l.add_theme_font_size_override("font_size", 15)
		l.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
		panel.add_child(l)
		rows["_none"] = l

func _on_quest_clicked(id: String) -> void:
	var st: Dictionary = GameManager.quest_state(id)
	if st.get("done", false) and not st.get("claimed", false):
		if GameManager.quest_claim(id):
			AudioManager.play_sfx("coin")
			msg_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
			msg_label.text = "Missao concluida! +%d moedas, +%d xp" % [QUESTS[id]["coins"], QUESTS[id]["xp"]]
			_refresh()
		return
	if not st.get("done", false):
		AudioManager.play_sfx("ui_click")
		msg_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		msg_label.text = "Missao aceita: %s" % QUESTS[id]["desc"]

extends Control
## Tela de título — JOGAR continua o save (ou comeca novo), NOVO JOGO zera o save

func _ready() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.08)
	add_child(bg)
	# teste de rede/lag: pula direto pro jogo (main.gd injeta o harness)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--nettest=") or a.begins_with("--netlag=") or a == "--server":
			change_scene_to_file.call_deferred("res://scenes/main.tscn")
			return
	var title = Label.new()
	title.text = "GRIMSTONE"
	title.position = Vector2(0, 180)
	title.size = Vector2(1280, 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(0.85, 0.75, 0.5))
	title.add_theme_color_override("font_outline_color", Color(0.2, 0.1, 0.05))
	title.add_theme_constant_override("outline_size", 10)
	add_child(title)
	var sub = Label.new()
	sub.text = "um RPG de aventura"
	sub.position = Vector2(0, 260)
	sub.size = Vector2(1280, 30)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", Color(0.6, 0.55, 0.45))
	add_child(sub)
	var has_save := GameManager.load_game()  # carrega o save (se existir) pra saber se ha CONTINUAR
	var y := 380.0
	if has_save:
		var btn_play = _make_button("JOGAR (nivel %d)" % GameManager.level, Vector2(540, y))
		btn_play.pressed.connect(_start_game)
		add_child(btn_play)
		y += 70
	var btn_new = _make_button("NOVO JOGO", Vector2(540, y))
	btn_new.pressed.connect(_new_game)
	add_child(btn_new)
	y += 70
	var btn_host = _make_button("HOSPEDAR PARTIDA", Vector2(540, y))
	btn_host.pressed.connect(_host_game)
	add_child(btn_host)
	y += 70
	var ip_box = LineEdit.new()
	ip_box.name = "IpBox"
	ip_box.position = Vector2(540, y)
	ip_box.size = Vector2(200, 44)
	ip_box.placeholder_text = "IP do host"
	ip_box.text = "127.0.0.1"
	ip_box.alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(ip_box)
	var btn_join = _make_button("CONECTAR", Vector2(750, y))
	btn_join.pressed.connect(_join_game)
	add_child(btn_join)
	var hint = Label.new()
	hint.text = " multiplayer: HOSPEDAR cria a partida, amigos conectam pelo seu IP"
	hint.position = Vector2(0, y + 60)
	hint.size = Vector2(1280, 24)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	add_child(hint)
	AudioManager.play_music("title")

func _make_button(txt: String, pos: Vector2) -> Button:
	var btn = Button.new()
	btn.text = txt
	btn.position = pos
	btn.size = Vector2(200, 50)
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.16, 0.13, 0.1)
	st.border_color = Color(0.55, 0.45, 0.3)
	st.set_border_width_all(2)
	st.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("normal", st)
	var st_h = st.duplicate()
	st_h.bg_color = Color(0.25, 0.2, 0.15)
	btn.add_theme_stylebox_override("hover", st_h)
	btn.add_theme_stylebox_override("pressed", st_h)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	btn.pressed.connect(func(): AudioManager.play_sfx("ui_click"))
	return btn

func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _new_game() -> void:
	# zera o save e comeca do zero
	GameManager.level = 1
	GameManager.xp = 0
	GameManager.hp = 100
	GameManager.hp_max = 100
	GameManager.mana = 50
	GameManager.mana_max = 50
	GameManager.coins = 0
	GameManager.bag = {}
	GameManager.current_map = "city1"
	GameManager.arrows = 50
	GameManager.skills = {"espada": {"level": 10, "xp": 0}, "defesa": {"level": 10, "xp": 0}}
	GameManager.city2_visited = false
	GameManager.city2_unlocked = false
	GameManager.quests = {}
	GameManager.well_fed_time = 0.0
	GameManager.bank = {}
	GameManager.bestiary = {}
	GameManager.save_game()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _host_game() -> void:
	NetworkManager.start_server()
	if NetworkManager.active:
		_start_game()

func _join_game() -> void:
	var ip_box = get_node_or_null("IpBox")
	var ip := "127.0.0.1"
	if ip_box != null and str(ip_box.text).strip_edges() != "":
		ip = str(ip_box.text).strip_edges()
	NetworkManager.start_client(ip)
	if NetworkManager.active:
		_start_game()

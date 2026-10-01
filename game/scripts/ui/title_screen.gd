extends Control
## Tela de título — GRIMSTONE, estilo Rucoy/Tibia
## JOGAR continua o save (ou comeca novo), NOVO JOGO zera o save

var ip_input: LineEdit

func _ready() -> void:
	# headless (servidor dedicado / NetTest): pula o titulo e vai direto pro jogo
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--nettest=") or a == "--server" or a.begins_with("--netlag="):
			get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")
			return
	AudioManager.play_music("title")
	var bg = ColorRect.new()
	bg.color = Color(0.06, 0.05, 0.08)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	# estrelas no fundo
	for i in range(60):
		var star = ColorRect.new()
		var sx = randf() * 1280
		var sy = randf() * 720
		star.position = Vector2(sx, sy)
		star.size = Vector2(2, 2)
		var br = 0.4 + randf() * 0.6
		star.color = Color(br, br, br * 1.05, 0.9)
		add_child(star)
	# lua
	var moon = ColorRect.new()
	moon.position = Vector2(1050, 90)
	moon.size = Vector2(90, 90)
	moon.color = Color(0.92, 0.9, 0.8, 0.95)
	# lua redonda via estilo
	var moon_st = StyleBoxFlat.new()
	moon_st.bg_color = Color(0.92, 0.9, 0.8, 0.95)
	moon_st.set_corner_radius_all(45)
	var moon_p = Panel.new()
	moon_p.position = Vector2(1050, 90)
	moon_p.size = Vector2(90, 90)
	moon_p.add_theme_stylebox_override("panel", moon_st)
	add_child(moon_p)
	# titulo
	var title = Label.new()
	title.text = "GRIMSTONE"
	title.position = Vector2(0, 150)
	title.size = Vector2(1280, 100)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 84)
	title.add_theme_color_override("font_color", Color(0.85, 0.75, 0.45))
	title.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.02))
	title.add_theme_constant_override("outline_size", 12)
	add_child(title)
	var sub = Label.new()
	sub.text = "Um RPG de aventura"
	sub.position = Vector2(0, 250)
	sub.size = Vector2(1280, 40)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 20)
	sub.add_theme_color_override("font_color", Color(0.7, 0.65, 0.55))
	add_child(sub)
	# tem save?
	var has_save := GameManager.level > 1 or GameManager.coins > 0 or not GameManager.bag.is_empty()
	var y := 340.0
	if has_save:
		var btn_play = _make_button("CONTINUAR (Nivel %d)" % GameManager.level, Vector2(540, y))
		btn_play.pressed.connect(_start_game)
		add_child(btn_play)
		y += 70
		var btn_new = _make_button("NOVO JOGO", Vector2(540, y))
		btn_new.pressed.connect(_new_game)
		add_child(btn_new)
		y += 70
	else:
		var btn_play = _make_button("JOGAR", Vector2(540, y))
		btn_play.pressed.connect(_start_game)
		add_child(btn_play)
		y += 70
	var btn_quit = _make_button("SAIR", Vector2(540, y))
	btn_quit.pressed.connect(_quit)
	add_child(btn_quit)
	y += 70
	# ---------- ONLINE (Area 9) ----------
	var btn_host = _make_button("HOSPEDAR JOGO", Vector2(540, y))
	btn_host.pressed.connect(_host_game)
	add_child(btn_host)
	y += 70
	var btn_join = _make_button("CONECTAR (IP)", Vector2(540, y))
	btn_join.pressed.connect(_join_game)
	add_child(btn_join)
	y += 70
	var ip_label = Label.new()
	ip_label.text = "IP do servidor:"
	ip_label.position = Vector2(490, y + 4)
	ip_label.add_theme_font_size_override("font_size", 14)
	ip_label.add_theme_color_override("font_color", Color(0.7, 0.65, 0.55))
	add_child(ip_label)
	ip_input = LineEdit.new()
	ip_input.position = Vector2(620, y)
	ip_input.size = Vector2(170, 34)
	ip_input.text = "127.0.0.1"
	ip_input.add_theme_font_size_override("font_size", 14)
	add_child(ip_input)
	# versao
	var ver = Label.new()
	ver.text = "v0.6.15"
	ver.position = Vector2(1220, 690)
	ver.add_theme_font_size_override("font_size", 12)
	ver.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
	add_child(ver)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _make_button(text: String, pos: Vector2) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = Vector2(200, 52)
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.16, 0.13, 0.1, 0.95)
	st.set_corner_radius_all(10)
	st.set_border_width_all(2)
	st.border_color = Color(0.7, 0.58, 0.3)
	var st_h = st.duplicate()
	st_h.bg_color = Color(0.25, 0.2, 0.14, 0.95)
	st_h.border_color = Color(0.95, 0.8, 0.4)
	btn.add_theme_stylebox_override("normal", st)
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
	GameManager.belt = {"z": "", "x": ""}
	GameManager.save_game()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _quit() -> void:
	get_tree().quit()

# ---------- ONLINE (Area 9) ----------
func _host_game() -> void:
	AudioManager.play_sfx("ui_click")
	NetworkManager.start_server()
	# servidor dedicado roda headless; aqui o host TAMBEM joga (listen server)
	_start_game()

func _join_game() -> void:
	AudioManager.play_sfx("ui_click")
	var host = ip_input.text.strip_edges()
	if host == "":
		host = "127.0.0.1"
	NetworkManager.start_client(host)
	_start_game()
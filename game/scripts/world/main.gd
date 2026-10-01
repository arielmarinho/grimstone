extends Node2D
## Main — 4 mapas: city1 (hub), city2 (leste), forest (sul da city2), rat_cave (bueiro)
## Lojas nas 2 cidades, mobs por mapa, transicoes por portoes
## CITY2: ao pisar pela 1a vez desbloqueia as skills avancadas (R/G)

const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")
const COLLIDERS = preload("res://scripts/world/colliders.gd")
const REMOTE_PLAYER = preload("res://scripts/entities/remote_player.gd")

const MAPS = {
	"city1": {
		"texture": "res://assets/maps/city1.png",
		"player_spawn": Vector2(1024, 1240),
		"exits": [
			{"pos": Vector2(1024, 1600), "radius": 84, "to": "rat_cave", "label": "BUEIRO ↓", "arrive": Vector2(1024, 1000)},
			{"pos": Vector2(1990, 1024), "radius": 84, "to": "city2", "label": "VILA →", "arrive": Vector2(340, 1024)},
		],
		"shop": Vector2(580, 1340),
		"spawner": "city1_mobs",
	},
	"city2": {
		"texture": "res://assets/maps/city2.png",
		"player_spawn": Vector2(260, 1024),
		"exits": [
			{"pos": Vector2(60, 1024), "radius": 84, "to": "city1", "label": "← CIDADE", "arrive": Vector2(1690, 1024)},
			{"pos": Vector2(1024, 1990), "radius": 84, "to": "forest", "label": "FLORESTA ↓", "arrive": Vector2(1024, 300)},
		],
		"shop": Vector2(1560, 660),
		"spawner": "city2_mobs",
		"safe_zone": true,
	},
	"forest": {
		"texture": "res://assets/maps/forest.png",
		"player_spawn": Vector2(1024, 260),
		"exits": [
			{"pos": Vector2(1024, 60), "radius": 84, "to": "city2", "label": "↑ VILA", "arrive": Vector2(1024, 1690)},
		],
		"spawner": "forest_mobs",
	},
	"rat_cave": {
		"texture": "res://assets/maps/rat_cave.png",
		"player_spawn": Vector2(1024, 800),
		"exits": [
			{"pos": Vector2(1024, 180), "radius": 84, "to": "city1", "label": "SAÍDA ↑", "arrive": Vector2(1024, 1560)},
		],
		"spawner": "cave_mobs",
	},
}

@onready var map_layer: Node2D = $MapLayer
@onready var entities: Node2D = $Entities

var player: CharacterBody2D = null
var current: String = ""
var switching: bool = false
var _respawning: bool = false
var shop: Node2D = null

# ---------- MULTIPLAYER (Area 9) ----------
var remote_players := {}  # peer_id -> RemotePlayer
var _net_accum: float = 0.0
const NET_SEND_HZ := 15.0

func _ready() -> void:
	# teste de rede (gs-netcode): --nettest=server|clientA|clientB injeta o harness
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--nettest="):
			var nt = load("res://scripts/tests/net_test.gd").new()
			nt.name = "NetTest"
			add_child(nt)
			break
	GameManager.load_game()
	_create_player()
	switch_map(GameManager.current_map if GameManager.current_map in MAPS else "city1")
	if player != null:
		player.weapon = GameManager.weapon
		player.hair_color = GameManager.hair_color
		player.tunic_color = GameManager.tunic_color
		player.pants_color = GameManager.pants_color
		player._build_frames()
	$HUD.set_player(player)
	# multiplayer: conecta os sinais do NetworkManager
	NetworkManager.player_joined.connect(_on_net_player_joined)
	NetworkManager.player_left.connect(_on_net_player_left)
	NetworkManager.player_state.connect(_on_net_player_state)
	NetworkManager.server_lost.connect(_clear_remote_players)
	NetworkManager.server_lost.connect(_on_net_offline_mobs)
	# mobs autoritativos: espelhos no cliente + mapa do servidor nos snapshots
	NetworkManager.mob_state.connect(_on_net_mob_state)
	NetworkManager.mob_removed.connect(_on_net_mob_removed)
	NetworkManager.damage_local_player.connect(_on_net_damage_local)
	NetworkManager.mob_reward.connect(_on_net_mob_reward)
	# servidor DEDICADO (--server): roda mundo+mobs, sem player local
	if NetworkManager.dedicated:
		if player != null:
			player.queue_free()
			player = null
		$HUD.visible = false

func _on_net_player_joined(id: int, info: Dictionary) -> void:
	if id == NetworkManager.my_id or remote_players.has(id):
		return
	var rp = REMOTE_PLAYER.new()
	rp.name = "Remote_%d" % id
	entities.add_child(rp)
	rp.setup(id, info)
	remote_players[id] = rp
	# so mostra se estiver no MESMO mapa que eu
	rp.visible = rp.map_name == current
	if rp.map_name == current:
		_net_chat_local(str(info.get("name", "???")), "entrou no jogo.", "join")

func _on_net_player_left(id: int) -> void:
	if remote_players.has(id):
		var rp = remote_players[id]
		remote_players.erase(id)
		if is_instance_valid(rp):
			rp.queue_free()

func _on_net_player_state(id: int, pos: Vector2, map: String, anim: String) -> void:
	if not remote_players.has(id):
		# player desconhecido (chegou estado antes do sync) — cria com dados basicos
		var info = NetworkManager.players.get(id, {"name": "???", "map": map})
		_on_net_player_joined(id, info)
		if not remote_players.has(id):
			return
	var rp = remote_players[id]
	if not is_instance_valid(rp):
		return
	rp.apply_state(pos, map, anim)
	# troca de mapa: esconde/mostra conforme o MEU mapa atual
	rp.visible = map == current

func _clear_remote_players() -> void:
	for id in remote_players.keys():
		var rp = remote_players[id]
		if is_instance_valid(rp):
			rp.queue_free()
	remote_players.clear()

func _on_net_offline_mobs() -> void:
	# caiu a conexão: espelhos de mob somem e o spawner local volta a valer
	_on_net_offline_mobs_clear()
	# re-spawna mobs locais do mapa atual
	var spawner_name = MAPS[current].get("spawner", "")
	if spawner_name != "" and player != null:
		var spawner = load("res://scripts/world/spawners.gd")
		var node = spawner.new()
		node.spawner_name = spawner_name
		node.map_name = current
		entities.add_child(node)

func _on_net_offline_mobs_clear() -> void:
	for id in net_mobs.keys():
		var m = net_mobs[id]
		if is_instance_valid(m):
			m.queue_free()
	net_mobs.clear()

func _net_chat_local(sender: String, text: String, kind: String) -> void:
	NetworkManager.chat_message.emit(sender, text, kind)

func _net_send_position() -> void:
	if player == null or player.dead or not NetworkManager.is_online():
		return
	var anim = "idle:" + player.facing
	if player.moving:
		anim = "walk:" + player.facing
	elif player.attacking:
		anim = "attack:" + player.facing
	NetworkManager.send_position(player.global_position, current, anim)

# ---------- MOBS AUTORITATIVOS (fase 2) ----------
var net_mobs := {}  # mob_id -> espelho Mob no cliente

func _on_net_mob_state(id: int, data: Dictionary) -> void:
	if NetworkManager.is_server:
		return
	# cliente: cria/atualiza espelho do mob; so mostra no MEU mapa
	if data.get("m", "") != current:
		if net_mobs.has(id):
			var old = net_mobs[id]
			net_mobs.erase(id)
			if is_instance_valid(old):
				old.queue_free()
		return
	if not net_mobs.has(id):
		var mob_scene: PackedScene = load("res://scenes/entities/mobs/rat.tscn")
		var m = mob_scene.instantiate()
		m.mob_type = str(data.get("t", "rat"))
		m.net_id = id
		m.net_authority = false
		m.position = data["p"]
		entities.add_child(m)
		net_mobs[id] = m
	var mob = net_mobs[id]
	if is_instance_valid(mob):
		mob.apply_net_state(data)

func _on_net_mob_removed(id: int) -> void:
	if net_mobs.has(id):
		var m = net_mobs[id]
		net_mobs.erase(id)
		if is_instance_valid(m):
			m.queue_free()

func _on_net_damage_local(dmg: int) -> void:
	# servidor dedicado mandou dano de mob pro meu player
	if player != null and not player.dead:
		player.take_damage(dmg)

func _on_net_mob_reward(xp: int, loot: Array, pos: Vector2) -> void:
	# servidor dedicado: XP + loot do mob que EU matei
	GameManager.add_xp(xp)
	preload("res://scripts/entities/loot_table.gd").spawn_loot_list(loot, pos, entities)

func _create_player() -> void:
	var pscene: PackedScene = load("res://scenes/entities/player/player.tscn")
	if pscene == null:
		push_error("GRAVE: player.tscn nao carregou — verifique o arquivo")
		return
	player = pscene.instantiate()
	player.name = "Player"
	add_child(player)
	player.position = Vector2(1024, 1240)

func _physics_process(_delta: float) -> void:
	# multiplayer: envia minha posição a 15Hz
	_net_accum += _delta
	if _net_accum >= 1.0 / NET_SEND_HZ:
		_net_accum = 0.0
		_net_send_position()
	# servidor dedicado: mundo+mobs rodam, sem player/loja/saidas
	if NetworkManager.dedicated:
		return
	if switching or player == null:
		return
	if player.dead:
		if not _respawning:
			_respawning = true
			await get_tree().create_timer(3.0).timeout
			if is_instance_valid(player) and player.dead:
				GameManager.hp = GameManager.hp_max
				GameManager.mana = GameManager.mana_max
				player.dead = false
				player._play("idle")
				switch_map("city1")
			_respawning = false
		return
	for ex in MAPS[current].get("exits", []):
		if player.global_position.distance_to(ex["pos"]) < ex["radius"]:
			switching = true
			switch_map(ex["to"], ex.get("arrive", null))
			switching = false
			return
	if shop != null and MAPS[current].has("shop"):
		var near = player.global_position.distance_to(MAPS[current]["shop"]) < 120.0
		if near and not shop.is_open() and Input.is_key_pressed(KEY_F):
			shop.open()
		elif not near and shop.is_open():
			shop.close()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and shop != null and shop.is_open():
			shop.close()

func _unlock_city2() -> void:
	if GameManager.city2_unlocked:
		return
	GameManager.city2_unlocked = true
	GameManager.city2_visited = true
	GameManager.save_game()
	if player != null:
		var l = Label.new()
		l.text = "NOVAS SKILLS DESBLOQUEADAS! (teclas R e G — veja na tela K)"
		l.position = player.global_position + Vector2(-260, -140)
		l.add_theme_font_size_override("font_size", 17)
		l.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
		l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		l.add_theme_constant_override("outline_size", 5)
		l.z_index = 60
		add_child(l)
		var tw = l.create_tween()
		tw.tween_interval(4.0)
		tw.tween_property(l, "modulate:a", 0.0, 1.0)
		tw.tween_callback(l.queue_free)
	print("CITY2: skills avancadas (R/G) desbloqueadas!")

func switch_map(name: String, arrive_pos = null) -> void:
	if name == current or not MAPS.has(name):
		return
	AudioManager.play_sfx("door")
	AudioManager.play_music("city" if name in ["city1", "city2"] else "cave")
	current = name
	GameManager.current_map = name
	if name == "city2":
		_unlock_city2()
	for c in map_layer.get_children():
		c.queue_free()
	var sprite = Sprite2D.new()
	sprite.texture = TEXHELPER.load_map(MAPS[name]["texture"])
	sprite.centered = false
	sprite.scale = Vector2(2, 2)
	map_layer.add_child(sprite)
	if player != null:
		# portao correspondente (chegando de outro mapa) ou spawn default
		player.global_position = arrive_pos if arrive_pos != null else MAPS[name]["player_spawn"]
	for mob in get_tree().get_nodes_in_group("mobs"):
		mob.queue_free()
	# espelhos de mob do multiplayer tambem saem ao trocar de mapa
	for id in net_mobs.keys():
		var m = net_mobs[id]
		if is_instance_valid(m):
			m.queue_free()
	net_mobs.clear()
	var spawner_name = MAPS[name].get("spawner", "")
	if spawner_name != "":
		var spawner = load("res://scripts/world/spawners.gd")
		var node = spawner.new()
		node.spawner_name = spawner_name
		node.map_name = name
		entities.add_child(node)
		# zona segura (city2): mobs agressivos nao atacam dentro dela
		if MAPS[name].get("safe_zone", false):
			node.safe_zone = true
	COLLIDERS.build_colliders(name, map_layer)
	for ex in MAPS[current].get("exits", []):
		var marker = Label.new()
		marker.text = ex["label"]
		marker.position = ex["pos"] + Vector2(-45, -95)
		marker.add_theme_font_size_override("font_size", 16)
		marker.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
		marker.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		marker.add_theme_constant_override("outline_size", 4)
		map_layer.add_child(marker)
		var tw = marker.create_tween()
		tw.set_loops()
		tw.tween_property(marker, "position:y", marker.position.y - 8.0, 0.6)
		tw.tween_property(marker, "position:y", marker.position.y, 0.6)
	if shop != null:
		shop.queue_free()
		shop = null
	if MAPS[current].has("shop"):
		shop = load("res://scripts/world/shop.gd").new()
		shop.city = current
		add_child(shop)
		var sign_l = Label.new()
		sign_l.text = "LOJA [F]"
		sign_l.position = MAPS[current]["shop"] + Vector2(-40, -70)
		sign_l.add_theme_font_size_override("font_size", 15)
		sign_l.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
		sign_l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		sign_l.add_theme_constant_override("outline_size", 4)
		map_layer.add_child(sign_l)
	if player != null:
		GameManager.weapon = player.weapon
		GameManager.hair_color = player.hair_color
		GameManager.tunic_color = player.tunic_color
		GameManager.pants_color = player.pants_color
	GameManager.save_game()

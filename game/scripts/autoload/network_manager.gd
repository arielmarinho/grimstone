extends Node
## NetworkManager — multiplayer online estilo Tibia (cliente-servidor autoritativo)
## Servidor: godot --headless -- --server  |  Cliente: conecta por IP no título

const PORT := 7777
const MAX_PLAYERS := 64

var is_server: bool = false
var peer: ENetMultiplayerPeer = null
var players := {}  # peer_id -> {name, level, map, pos}
var my_id: int = 1

signal player_joined(id: int, info: Dictionary)
signal player_left(id: int)
signal chat_message(sender: String, text: String, channel: String)

func _ready() -> void:
	var args = OS.get_cmdline_user_args()
	if "--server" in args:
		start_server()

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT, MAX_PLAYERS)
	if err != OK:
		push_error("Falha ao abrir servidor na porta %d" % PORT)
		return
	multiplayer.multiplayer_peer = peer
	is_server = true
	my_id = 1
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("[SERVER] Grimstone online na porta ", PORT)

func start_client(host: String) -> void:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(host, PORT)
	if err != OK:
		push_error("Falha ao conectar em %s:%d" % [host, PORT])
		return
	multiplayer.multiplayer_peer = peer
	is_server = false
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_failed)
	multiplayer.server_disconnected.connect(_on_server_lost)
	print("[CLIENT] Conectando em ", host, "...")

func _on_connected() -> void:
	my_id = multiplayer.get_unique_id()
	print("[CLIENT] Conectado! meu id: ", my_id)
	rpc_id(1, "_rpc_register", GameManager.player_name, GameManager.level, GameManager.current_map)

func _on_failed() -> void:
	print("[CLIENT] Falha na conexao — jogando offline")
	multiplayer.multiplayer_peer = null

func _on_server_lost() -> void:
	print("[SERVER] Conexao perdida — jogando offline")
	multiplayer.multiplayer_peer = null
	players.clear()

# ---------- REGISTRO DE PLAYERS ----------
func _on_peer_connected(id: int) -> void:
	print("[SERVER] peer ", id, " conectou")

func _on_peer_disconnected(id: int) -> void:
	if players.has(id):
		var info = players[id]
		print("[SERVER] ", info["name"], " saiu")
		players.erase(id)
		_broadcast_player_left.rpc(id)

@rpc("any_peer", "call_remote", "reliable")
func _rpc_register(name: String, level: int, map: String) -> void:
	if not multiplayer.is_server():
		return
	var sender = multiplayer.get_remote_sender_id()
	players[sender] = {"name": name, "level": level, "map": map}
	_rpc_sync_players.rpc(players)
	print("[SERVER] ", name, " (nivel ", level, ") registrou — ", players.size(), " online")

@rpc("authority", "call_remote", "reliable")
func _rpc_sync_players(all: Dictionary) -> void:
	players = all
	for id in players:
		player_joined.emit(id, players[id])

@rpc("authority", "call_remote", "reliable")
func _broadcast_player_left(id: int) -> void:
	players.erase(id)
	player_left.emit(id)

# ---------- POSIÇÃO (15 Hz, unreliable) ----------
func send_position(pos: Vector2, map: String, anim: String) -> void:
	if multiplayer.multiplayer_peer == null or is_server:
		return
	_rpc_position.rpc_id(1, pos, map, anim)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func _rpc_position(pos: Vector2, map: String, anim: String) -> void:
	if not multiplayer.is_server():
		return
	var sender = multiplayer.get_remote_sender_id()
	if players.has(sender):
		players[sender]["pos"] = pos
		players[sender]["map"] = map
		players[sender]["anim"] = anim
		_relay_position.rpc(sender, pos, map, anim)

@rpc("authority", "call_remote", "unreliable_ordered")
func _relay_position(id: int, pos: Vector2, map: String, anim: String) -> void:
	if id == my_id:
		return
	player_joined.emit(id, {"pos": pos, "map": map, "anim": anim, "update": true})

# ---------- CHAT ----------
func send_chat(text: String) -> void:
	if multiplayer.multiplayer_peer == null:
		chat_message.emit(GameManager.player_name, text, "global")
		return
	if is_server:
		_relay_chat.rpc(GameManager.player_name, text)
	else:
		_rpc_chat.rpc_id(1, text)

@rpc("any_peer", "call_remote", "reliable")
func _rpc_chat(text: String) -> void:
	if not multiplayer.is_server():
		return
	var sender = multiplayer.get_remote_sender_id()
	var name = players.get(sender, {}).get("name", "???")
	_relay_chat.rpc(name, text)

@rpc("authority", "call_remote", "reliable")
func _relay_chat(sender: String, text: String) -> void:
	chat_message.emit(sender, text, "global")

# ---------- HELPERS ----------
func is_online() -> bool:
	return multiplayer.multiplayer_peer != null

func online_count() -> int:
	return players.size() if is_online() else 1

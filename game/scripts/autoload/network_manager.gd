extends Node
## NetworkManager — multiplayer online estilo Tibia (cliente-servidor autoritativo)
## Servidor: Godot headless rodando este mesmo projeto com --server
## Cliente: conecta por IP na tela de título
## v2: registro com aparência (arma/cores), spawn/despawn de players remotos,
##     chat com eventos de join/leave, nomes sobre os avatares

const PORT := 7777
const MAX_PLAYERS := 64

var is_server: bool = false
var active: bool = false  # true só depois de start_server/start_client OK (offline = false)
var peer: ENetMultiplayerPeer = null
var players := {}  # peer_id -> {name, level, map, app{weapon,hair,tunic,pants}}
var my_id: int = 1

signal player_joined(id: int, info: Dictionary)
signal player_left(id: int)
signal player_state(id: int, pos: Vector2, map: String, anim: String)
signal chat_message(sender: String, text: String, kind: String)  # kind: "msg"|"join"|"leave"|"system"
signal server_lost  # conexão com o servidor caiu (clientes limpam estado remoto)

func _ready() -> void:
	# servidor dedicado: godot --headless -- --server
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
	active = true
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
	active = true
	print("[CLIENT] Conectando em ", host, "...")

func _my_appearance() -> Dictionary:
	return {
		"weapon": GameManager.weapon,
		"hair": GameManager.hair_color,
		"tunic": GameManager.tunic_color,
		"pants": GameManager.pants_color,
	}

func _on_connected() -> void:
	my_id = multiplayer.get_unique_id()
	print("[CLIENT] Conectado! meu id: ", my_id)
	# registra meu personagem no servidor (com aparência pra renderizar o avatar)
	rpc_id(1, "_rpc_register", GameManager.player_name, GameManager.level, GameManager.current_map, _my_appearance())

func _on_failed() -> void:
	print("[CLIENT] Falha na conexao — jogando offline")
	multiplayer.multiplayer_peer = null
	players.clear()

func _on_server_lost() -> void:
	print("[SERVER] Conexao perdida — jogando offline")
	multiplayer.multiplayer_peer = null
	players.clear()
	server_lost.emit()
	chat_message.emit("", "Conexao perdida — voltando ao modo OFFLINE.", "system")

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
func _rpc_register(name: String, level: int, map: String, app: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	var sender = multiplayer.get_remote_sender_id()
	players[sender] = {"name": name, "level": level, "map": map, "app": app}
	# manda a lista completa pro novo e avisa todos
	_rpc_sync_players.rpc(players)
	print("[SERVER] ", name, " (nivel ", level, ") registrou — ", players.size(), " online")

@rpc("authority", "call_remote", "reliable")
func _rpc_sync_players(all: Dictionary) -> void:
	# dif: spawna os que são novos pra mim
	var known := players.keys()
	players = all
	for id in all:
		if not known.has(id):
			player_joined.emit(id, all[id])
	chat_message.emit("", "Voce entrou no mundo online! %d jogador(es) conectado(s)." % all.size(), "system")

@rpc("authority", "call_remote", "reliable")
func _broadcast_player_left(id: int) -> void:
	var info = players.get(id, {})
	players.erase(id)
	player_left.emit(id)
	if info.has("name"):
		chat_message.emit(str(info["name"]), "saiu do jogo.", "leave")

# ---------- POSIÇÃO (15 Hz, unreliable) ----------
func send_position(pos: Vector2, map: String, anim: String) -> void:
	if not active or multiplayer.multiplayer_peer == null or is_server:
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
	player_state.emit(id, pos, map, anim)

# ---------- CHAT ----------
func send_chat(text: String) -> void:
	if not active or multiplayer.multiplayer_peer == null:
		# offline: eco local
		chat_message.emit(GameManager.player_name, text, "msg")
		return
	if is_server:
		chat_message.emit(GameManager.player_name, text, "msg")
		_relay_chat.rpc(GameManager.player_name, text)
	else:
		_rpc_chat.rpc_id(1, text)

@rpc("any_peer", "call_remote", "reliable")
func _rpc_chat(text: String) -> void:
	if not multiplayer.is_server():
		return
	var sender = multiplayer.get_remote_sender_id()
	var name = players.get(sender, {}).get("name", "???")
	# eco do autor chega via _relay_chat (broadcast) — NAO emitir aqui com nome errado
	_relay_chat.rpc(name, text)

@rpc("authority", "call_remote", "reliable")
func _relay_chat(sender: String, text: String) -> void:
	chat_message.emit(sender, text, "msg")

# ---------- HELPERS ----------
func is_online() -> bool:
	return active and multiplayer.multiplayer_peer != null \
		and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

func online_count() -> int:
	return players.size() if is_online() else 1

extends Node
## NetTest — teste de rede automatizado (regra gs-netcode: 2 clientes + 1 server no localhost)
## Uso:
##   godot --headless --path . -- --nettest server
##   godos --headless --path . -- --nettest clientA
##   godot --headless --path . -- --nettest clientB
## Sequência: server abre ENet 7777; clientes conectam, registram, enviam chat,
## movem o player; validamos: registro (players online), relay de posição entre
## clientes, chat A->B, e saída limpa sem crash.

var role := ""
var _log: Array = []
var _flog_path := ""

func _flog(msg: String, a = null, b = null, c = null, d = null, e = null, f = null, g = null) -> void:
	for extra in [a, b, c, d, e, f, g]:
		if extra != null:
			msg += " " + str(extra)
	print(msg)
	if _flog_path == "":
		return
	var fh = FileAccess.open(_flog_path, FileAccess.READ_WRITE if FileAccess.file_exists(_flog_path) else FileAccess.WRITE)
	if fh == null:
		return
	fh.seek_end()
	fh.store_line(msg)
	fh.flush()
var _main = null
var _t := 0.0
var _phase := 0
var _fail := false
var _phase_mobs_wait := 0
var _chat_sent := false  # chat enviado uma vez só (re-registro duplicava o envio)
var _deadline := 24.0  # saída LIMPA antes do timeout do shell (stdout morre no SIGTERM)

func _ready() -> void:
	var args = OS.get_cmdline_user_args()
	for a in args:
		if a.begins_with("--nettest="):
			role = a.get_slice("=", 1)
	if role == "":
		return  # não é teste — jogo normal
	_flog_path = "/tmp/nettest_%s.log" % role
	FileAccess.open(_flog_path, FileAccess.WRITE).store_line("start")
	# este nó é injetado DENTRO da main (main.gd faz add_child) — main já é meu pai
	_main = get_parent()
	_flog("[NETTEST] role=", role, " acoplado à main")

func _phase_server() -> void:
	match _phase:
		0:
			NetworkManager.start_server()
			_flog("[NETTEST][SERVER] aguardando 2 clientes...")
			_phase = 1
		1:
			if NetworkManager.players.size() >= 2:
				_flog("[NETTEST][SERVER] 2 clientes registrados: ", NetworkManager.players.keys())
				_phase = 2
				_t = 0.0
		2:
			# deixa os clientes trocarem chat/posição E completarem a fase de mobs (~20s)
			_t += get_physics_process_delta_time()
			if _t > 20.0:
				_flog("[NETTEST][SERVER] DONE — encerrando")
				_flog("[NETTEST][RESULT] server OK")
				get_tree().quit(0)

func _phase_client(name_tag: String, chat_text: String) -> void:
	match _phase:
		0:
			# conecta no localhost
			NetworkManager.start_client("127.0.0.1")
			_phase = 1
			_t = 0.0
		1:
			_t += get_physics_process_delta_time()
			# espera OS DOIS registrados (o sync do servidor traz a lista completa)
			if NetworkManager.is_online() and NetworkManager.my_id != 1 and NetworkManager.players.size() >= 2:
				_flog("[NETTEST][", name_tag, "] registrado! id=", NetworkManager.my_id, " players=", NetworkManager.players.keys())
				_phase = 2
				_t = 0.0
			elif _t > 25.0:
				_fail = true
				_flog("[NETTEST][", name_tag, "] FALHOU: não registrou 2 players em 25s — players=", NetworkManager.players.keys())
				get_tree().quit(1)
		2:
			# fase MOBS: espera espelhos de mob chegarem do servidor, aproxima, pede dano
			_t += get_physics_process_delta_time()
			var nm = _main.net_mobs if _main != null else {}
			if _phase_mobs_wait == 0:
				# chat continua sendo validado (fase 3) — envia UMA vez só
				if not _chat_sent:
					_chat_sent = true
					NetworkManager.send_chat(chat_text)
					_flog("[NETTEST][", name_tag, "] chat enviado: ", chat_text)
				if nm.size() > 0:
					_phase_mobs_wait = 1
					_flog("[NETTEST][", name_tag, "] mobs espelhados: ", nm.size())
					_t = 0.0
			elif _phase_mobs_wait == 1 and _t > 1.0:
				# teleporta o player pra BEIRA de um mob VIVO (varre todos, nao so o 1o)
				for mid in nm:
					var m = nm[mid]
					if is_instance_valid(m) and not m.dead:
						if _main.player != null:
							_main.player.global_position = m.global_position + Vector2(70, 0)
						_phase_mobs_wait = 2
						_t = 0.0
						break
			elif _phase_mobs_wait == 2 and _t > 1.5:
				# pede dano no primeiro mob espelhado VIVO (varre todos)
				for mid in nm:
					var m = nm[mid]
					if is_instance_valid(m) and not m.dead:
						var hp_before = m.hp
						NetworkManager.request_mob_damage(mid, 5)
						_flog("[NETTEST][", name_tag, "] pediu dano 5 no mob ", mid, " (hp=", hp_before, ")")
						_phase_mobs_wait = 3
						_t = 0.0
						break
			elif _phase_mobs_wait == 3 and _t > 2.0:
				# valida: hp do espelho caiu (snapshot autoritativo chegou)
				var ok := false
				for mid in nm:
					var m2 = nm[mid]
					if is_instance_valid(m2) and m2.hp < m2.max_hp:
						ok = true
				if ok:
					_flog("[NETTEST][", name_tag, "] MOB OK — hp caiu no snapshot autoritativo")
				else:
					_fail = true
					_flog("[NETTEST][", name_tag, "] FALHOU: hp do mob nao caiu apos request_mob_damage")
					get_tree().quit(1)
				_phase = 3
				_t = 0.0
		3:
			# escuta por 4s: chat do outro + estados de posição
			_t += get_physics_process_delta_time()
			if _t > 4.0:
				var got_chat := false
				var got_pos := false
				for entry in _log:
					if entry.begins_with("CHAT:"):
						got_chat = true
					if entry.begins_with("POS:"):
						got_pos = true
				if got_chat and got_pos:
					_flog("[NETTEST][", name_tag, "] OK — recebeu chat E posição do outro player")
					_flog("[NETTEST][RESULT] ", name_tag, " OK")
				else:
					_fail = true
					_flog("[NETTEST][", name_tag, "] FALHOU: chat=", got_chat, " pos=", got_pos, " log=", _log)
					get_tree().quit(1)
				_phase = 4
		4:
			# server encerrou → sair limpo
			if not NetworkManager.is_online():
				_flog("[NETTEST][", name_tag, "] server caiu — saindo limpo")
				get_tree().quit(0)

func _physics_process(delta: float) -> void:
	if role == "":
		return
	_t += delta
	if _t > _deadline:
		print("[NETTEST][RESULT] TIMEOUT role=", role, " fase=", _phase, " log=", _log)
		get_tree().quit(1)
		return
	match role:
		"server":
			_phase_server()
		"clientA":
			_phase_client("A", "ola do cliente A!")
		"clientB":
			_phase_client("B", "ola do cliente B!")

# ---------- hooks nos sinais do NetworkManager (conectados no _ready tardio) ----------
func _connect_signals() -> void:
	if not NetworkManager.chat_message.is_connected(_on_chat):
		NetworkManager.chat_message.connect(_on_chat)
	if not NetworkManager.player_state.is_connected(_on_state):
		NetworkManager.player_state.connect(_on_state)
	if not NetworkManager.player_joined.is_connected(_on_join):
		NetworkManager.player_joined.connect(_on_join)

func _on_chat(sender: String, text: String, kind: String) -> void:
	if kind == "msg":
		_log.append("CHAT:" + sender + ":" + text)

func _on_state(id: int, pos: Vector2, map: String, anim: String) -> void:
	_log.append("POS:" + str(id) + ":" + str(pos) + ":" + map + ":" + anim)

func _on_join(id: int, info: Dictionary) -> void:
	_log.append("JOIN:" + str(id) + ":" + str(info.get("name", "?")))

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		call_deferred("_connect_signals")

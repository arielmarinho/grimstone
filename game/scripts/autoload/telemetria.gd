extends Node
## Telemetria — envia frame do jogo + estado pra debug remoto (F12 ou automático)
## NÃO grava nada no disco: frame fica em memória, vai direto por HTTP.
## F12 = envia 1 frame agora. --telemetria=N = envia a cada N segundos.

const WEBHOOK := "https://maestro.adapta.one/webhooks/generic/17b615cef93bd3dacaa1b07ca67dfa9aaa5111c5906f2c836ff10f9499676b14"
const SECRET := "2219110b7a55954b7673eace1d7f2b37c4836adb3ae5f1bf1fdb3a070ae6da85"

var http: HTTPRequest
var auto_interval := 0.0
var auto_timer := 0.0
var busy := false
var erros_sessao: Array[String] = []

func _ready() -> void:
	http = HTTPRequest.new()
	http.timeout = 10.0
	add_child(http)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--telemetria="):
			auto_interval = float(arg.get_slice("=", 1))
	# captura erros de script da sessão
	get_tree().set_auto_accept_quit(true)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F12:
			_enviar("F12 manual")

func _process(delta: float) -> void:
	if auto_interval <= 0.0 or busy:
		return
	auto_timer += delta
	if auto_timer >= auto_interval:
		auto_timer = 0.0
		_enviar("automatico %ds" % int(auto_interval))

func registrar_erro(msg: String) -> void:
	erros_sessao.append(msg)
	if erros_sessao.size() > 50:
		erros_sessao = erros_sessao.slice(-50)

func _estado() -> Dictionary:
	var st := {
		"versao": GameManager.GAME_VERSION if GameManager.get("GAME_VERSION") != null else "?",
		"erros": erros_sessao,
	}
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		st["player"] = {
			"pos": [int(player.global_position.x), int(player.global_position.y)],
			"facing": player.get("facing"),
			"anim": player.get("sprite").animation if player.get("sprite") else "?",
			"frame": player.get("sprite").frame if player.get("sprite") else -1,
			"flip_h": player.get("sprite").flip_h if player.get("sprite") else false,
			"weapon": GameManager.weapon_base(),
			"level": GameManager.level,
			"hp": GameManager.hp,
		}
	return st

func _enviar(origem: String) -> void:
	if busy:
		return
	busy = true
	# captura o frame ATUAL da viewport (sem gravar em disco)
	var img := get_viewport().get_texture().get_image()
	var b64 := ""
	if img != null:
		var png := img.save_png_to_buffer()
		b64 = Marshalls.raw_to_base64(png)
	var body := JSON.stringify({
		"comando": "telemetria_godot",
		"origem": origem,
		"screenshot_base64": b64,
		"diagnostico": JSON.stringify(_estado()),
	})
	http.request(WEBHOOK, PackedStringArray([
		"Content-Type: application/json",
		"X-Webhook-Secret: " + SECRET,
	]), HTTPClient.METHOD_POST, body)
	var ok := await http.request_completed
	busy = false

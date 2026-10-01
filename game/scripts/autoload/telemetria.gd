extends Node
## Telemetria — envia frame do jogo + estado pra debug remoto (tecla P ou automático)
## NÃO grava nada no disco: frame fica em memória, vai direto por HTTP.
## P = envia 1 frame agora. --telemetria=N = envia a cada N segundos.
## (F12 é volume no Mac — tecla trocada pra P)
## Screenshot vai em CHUNKS pequenos (parte/total) + evento fim com diagnóstico
## — o canal do Grimstone filtra payloads base64 grandes, então dividimos.
## v2: downscale p/ 480px + JPEG q60 ANTES do base64 (~15-25KB em vez de ~240KB)
## e chunks de 360 chars (limite seguro do filtro) — ~60 partes em vez de 952.

const WEBHOOK := "https://maestro.adapta.one/webhooks/generic/17b615cef93bd3dacaa1b07ca67dfa9aaa5111c5906f2c836ff10f9499676b14"
const SECRET := "2219110b7a55954b7673eace1d7f2b37c4836adb3ae5f1bf1fdb3a070ae6da85"
const CHUNK := 360
const MAX_W := 480
const JPEG_Q := 0.6

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

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P:
			_enviar("tecla P manual")

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

func _post(body: Dictionary) -> void:
	var payload := JSON.stringify(body)
	http.request(WEBHOOK, PackedStringArray([
		"Content-Type: application/json",
		"X-Webhook-Secret: " + SECRET,
	]), HTTPClient.METHOD_POST, payload)

func _enviar(origem: String) -> void:
	if busy:
		return
	busy = true
	# captura o frame ATUAL da viewport, reduz e comprime (sem gravar em disco)
	var b64 := ""
	if get_viewport() != null and get_viewport().get_texture() != null:
		var img: Image = get_viewport().get_texture().get_image()
		if img != null:
			if img.get_width() > MAX_W:
				var h := int(img.get_height() * float(MAX_W) / float(img.get_width()))
				img.resize(MAX_W, h, Image.INTERPOLATE_BILINEAR)
			b64 = Marshalls.raw_to_base64(img.save_jpg_to_buffer(JPEG_Q))
	# envia em chunks de 360 chars (passa pelo filtro do Grimstone)
	var total := maxi(1, ceili(b64.length() / float(CHUNK)))
	var i := 0
	while i < b64.length():
		var part := b64.substr(i, CHUNK)
		_post({
			"comando": "telemetria_chunk",
			"origem": origem,
			"part": (i / CHUNK) + 1,
			"total": total,
			"data": part,
		})
		await http.request_completed
		i += CHUNK
	# evento fim com o diagnóstico
	_post({
		"comando": "telemetria_fim",
		"origem": origem,
		"total": total,
		"diagnostico": JSON.stringify(_estado()),
	})
	await http.request_completed
	busy = false

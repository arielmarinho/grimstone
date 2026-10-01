extends Node
## AudioManager — SFX com pool de players + musica com crossfade entre mapas
## Regras da skill gs-audio: SFX nunca acima de -6dB, musica -18dB, fallback silencioso

const SFX = {
	"hit": "res://assets/audio/hit.wav",
	"shoot": "res://assets/audio/shoot.wav",
	"cast": "res://assets/audio/cast.wav",
	"mob_death": "res://assets/audio/mob_death.wav",
	"player_hurt": "res://assets/audio/player_hurt.wav",
	"player_death": "res://assets/audio/player_death.wav",
	"level_up": "res://assets/audio/level_up.wav",
	"coin": "res://assets/audio/coin.wav",
	"pickup": "res://assets/audio/pickup.wav",
	"potion": "res://assets/audio/potion.wav",
	"ui_click": "res://assets/audio/ui_click.wav",
	"door": "res://assets/audio/door.wav",
}
const SFX_DB = -8.0
const MUSIC_DB = -18.0
const POOL_SIZE = 8

var _pool: Array = []
var _pool_idx: int = 0
var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _music_current: String = ""
var _music_use_a: bool = true
var _cache: Dictionary = {}

func _ready() -> void:
	# pool de SFX (8 players) pra sons rapidos nao se cortarem
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.volume_db = SFX_DB
		add_child(p)
		_pool.append(p)
	_music_a = AudioStreamPlayer.new()
	_music_b = AudioStreamPlayer.new()
	add_child(_music_a)
	add_child(_music_b)

func play_sfx(name: String, pitch_var: float = 0.1) -> void:
	var path: String = SFX.get(name, "")
	if path == "":
		return
	var stream = _cache.get(path, null)
	if stream == null:
		if not ResourceLoader.exists(path):
			return  # fallback silencioso: arquivo faltando nunca da erro
		stream = load(path)
		_cache[path] = stream
	var p: AudioStreamPlayer = _pool[_pool_idx]
	_pool_idx = (_pool_idx + 1) % POOL_SIZE
	p.stream = stream
	p.pitch_scale = 1.0 + randf_range(-pitch_var, pitch_var)
	p.play()

func play_music(name: String) -> void:
	if name == _music_current:
		return
	_music_current = name
	# crossfade: abaixa a atual, sobe a nova
	var old = _music_a if _music_use_a else _music_b
	var new = _music_b if _music_use_a else _music_a
	_music_use_a = not _music_use_a
	var path: String = "res://assets/audio/music_%s.wav" % name
	if not ResourceLoader.exists(path):
		return
	var stream = load(path)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = int(stream.get_length() * stream.mix_rate)  # frames
	new.stream = stream
	new.volume_db = -40.0
	new.play()
	var tw = create_tween()
	tw.tween_property(new, "volume_db", MUSIC_DB, 1.5)
	tw.parallel().tween_property(old, "volume_db", -40.0, 1.5)
	tw.tween_callback(old.stop)

func stop_music() -> void:
	_music_current = ""
	_music_a.stop()
	_music_b.stop()

extends Node
## AudioManager — audio 100% PROCEDURAL (sintetizado em GDScript no startup)
## SFX com pool de 8 players + musica chiptune com crossfade entre mapas.
## Sem arquivos binarios no repo — tudo gerado por codigo (mesma filosofia dos sprites).
## Regras da skill gs-audio: SFX -8dB, musica -18dB, pitch variavel pra nao cansar.

const SFX_HZ := 22050
const MUSIC_HZ := 11025
const SFX_DB := -8.0
const MUSIC_DB := -18.0
const POOL_SIZE := 8

var _pool: Array = []
var _pool_idx: int = 0
var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _music_current: String = ""
var _music_use_a: bool = true
var _sfx: Dictionary = {}
var _music: Dictionary = {}

func _ready() -> void:
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.volume_db = SFX_DB
		add_child(p)
		_pool.append(p)
	_music_a = AudioStreamPlayer.new()
	_music_b = AudioStreamPlayer.new()
	add_child(_music_a)
	add_child(_music_b)
	_build_sfx()
	_build_music()

func play_sfx(sfx_name: String, pitch_var: float = 0.1) -> void:
	if not _sfx.has(sfx_name):
		return  # fallback silencioso
	var p: AudioStreamPlayer = _pool[_pool_idx]
	_pool_idx = (_pool_idx + 1) % POOL_SIZE
	p.stream = _sfx[sfx_name]
	p.pitch_scale = 1.0 + randf_range(-pitch_var, pitch_var)
	p.play()

func play_music(music_name: String) -> void:
	if music_name == _music_current or not _music.has(music_name):
		return
	_music_current = music_name
	# crossfade: abaixa a atual, sobe a nova
	var old = _music_a if _music_use_a else _music_b
	var new = _music_b if _music_use_a else _music_a
	_music_use_a = not _music_use_a
	new.stream = _music[music_name]
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

# ================= SINTese =================
func _to_wav(bytes: PackedByteArray, hz: int, loop: bool = false) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = hz
	wav.stereo = false
	wav.data = bytes
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = bytes.size() / 2
	return wav

func _env(x: float, dur: float, a: float, r: float) -> float:
	return clampf(minf(x / a, (dur - x) / r), 0.0, 1.0)

func _sweep(t: float, dur: float, f0: float, f1: float, square_w: bool = false, tri_w: bool = false) -> float:
	var ph := TAU * (f0 * t + (f1 - f0) * t * t / (2.0 * dur))
	if square_w:
		return 1.0 if sin(ph) >= 0.0 else -1.0
	if tri_w:
		return 2.0 / PI * asin(sin(ph))
	return sin(ph)

func _render(dur: float, fn: Callable, hz: int = SFX_HZ) -> AudioStreamWAV:
	var n := int(dur * hz)
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in n:
		var v: float = clampf(fn.call(i / float(hz)), -1.0, 1.0)
		bytes.encode_s16(i * 2, int(v * 32767.0))
	return _to_wav(bytes, hz)

func _tone_bytes(f: float, dur: float, square_w: bool, a: float, r: float, amp: float = 1.0) -> PackedByteArray:
	var n := int(SFX_HZ * dur)
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in n:
		var t := i / float(SFX_HZ)
		var ph := TAU * f * t
		var v := (1.0 if sin(ph) >= 0.0 else -1.0) if square_w else sin(ph)
		bytes.encode_s16(i * 2, int(clampf(v * _env(t, dur, a, r) * amp, -1.0, 1.0) * 32767.0))
	return bytes

func _silence_bytes(dur: float) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(int(SFX_HZ * dur) * 2)
	return bytes

func _build_sfx() -> void:
	# hit: thump grave + estalo de ruido
	_sfx["hit"] = _render(0.12, func(t):
		var v := 0.0
		if t < 0.09:
			v += _sweep(t, 0.09, 180.0, 60.0) * _env(t, 0.09, 0.002, 0.08)
		if t < 0.05:
			v += (randf() * 2.0 - 1.0) * _env(t, 0.05, 0.001, 0.045) * 0.5
		return v)
	# shoot: chirp descendente rapido (flecha)
	_sfx["shoot"] = _render(0.13, func(t):
		return _sweep(t, 0.13, 1100.0, 350.0, false, true) * _env(t, 0.13, 0.002, 0.11))
	# cast: sweep ascendente brilhante (magia)
	_sfx["cast"] = _render(0.22, func(t):
		return _sweep(t, 0.22, 300.0, 950.0) * _env(t, 0.22, 0.01, 0.18) \
			+ 0.4 * _sweep(t, 0.22, 600.0, 1900.0) * _env(t, 0.22, 0.01, 0.18))
	# mob_death: growl descendente
	_sfx["mob_death"] = _render(0.4, func(t):
		return _sweep(t, 0.4, 280.0, 70.0, true) * _env(t, 0.4, 0.005, 0.35) * 0.7)
	# player_hurt: thud medio
	_sfx["player_hurt"] = _render(0.16, func(t):
		return _sweep(t, 0.16, 240.0, 90.0) * _env(t, 0.16, 0.002, 0.14) \
			+ 0.3 * (randf() * 2.0 - 1.0) * _env(t, 0.16, 0.001, 0.1))
	# player_death: tom longo descendente
	_sfx["player_death"] = _render(0.9, func(t):
		return _sweep(t, 0.9, 420.0, 55.0, false, true) * _env(t, 0.9, 0.01, 0.8))
	# level_up: arpejo C5 E5 G5 C6 + cauda
	var lu := PackedByteArray()
	for f in [523.25, 659.25, 783.99, 1046.5]:
		lu.append_array(_tone_bytes(f, 0.11, true, 0.005, 0.09))
	lu.append_array(_tone_bytes(1046.5, 0.35, true, 0.005, 0.3))
	_sfx["level_up"] = _to_wav(lu, SFX_HZ)
	# coin: 2 pings agudos
	var coin := _tone_bytes(1250.0, 0.06, false, 0.002, 0.05)
	coin.append_array(_tone_bytes(1650.0, 0.09, false, 0.002, 0.08))
	_sfx["coin"] = _to_wav(coin, SFX_HZ)
	# pickup: pop suave subindo
	_sfx["pickup"] = _render(0.09, func(t):
		return _sweep(t, 0.09, 480.0, 720.0) * _env(t, 0.09, 0.004, 0.07))
	# potion: 3 bolhas subindo
	var pot := PackedByteArray()
	for f in [300.0, 430.0, 580.0]:
		var n := int(SFX_HZ * 0.1)
		var seg := PackedByteArray()
		seg.resize(n * 2)
		for i in n:
			var t := i / float(SFX_HZ)
			var v := sin(TAU * (f + 25.0 * sin(TAU * 30.0 * t)) * t) * _env(t, 0.1, 0.01, 0.08)
			seg.encode_s16(i * 2, int(clampf(v, -1.0, 1.0) * 32767.0))
		pot.append_array(seg)
		pot.append_array(_silence_bytes(0.03))
	_sfx["potion"] = _to_wav(pot, SFX_HZ)
	# ui_click: tick curtinho
	_sfx["ui_click"] = _to_wav(_tone_bytes(1900.0, 0.03, false, 0.001, 0.025), SFX_HZ)
	# door: creak + thud
	_sfx["door"] = _render(0.22, func(t):
		return (randf() * 2.0 - 1.0) * _env(t, 0.22, 0.02, 0.18) * 0.4 \
			+ _sweep(t, 0.22, 110.0, 70.0) * _env(t, 0.22, 0.01, 0.2))

# ================= MUSICAS (chiptune) =================
func _note(semi: int) -> float:
	return 440.0 * pow(2.0, semi / 12.0)

func _build_song(bpm: float, chords: Array, melody: Array, lead_wave: float) -> AudioStreamWAV:
	var bars := chords.size()
	var beat := 60.0 / bpm
	var total := int(MUSIC_HZ * beat * bars * 4.0)
	var mix := PackedFloat32Array()
	mix.resize(total)
	# baixo: raiz do acorde -12 oitava, uma nota por beat
	for bar in range(bars):
		var root: int = chords[bar]
		for beat_i in range(4):
			var start := int(MUSIC_HZ * (bar * 4 + beat_i) * beat)
			var d := beat * 0.95
			var n := int(MUSIC_HZ * d)
			for j in n:
				var idx := start + j
				if idx >= total:
					break
				var t := j / float(MUSIC_HZ)
				var ph := TAU * _note(root - 12) * t
				mix[idx] += 2.0 / PI * asin(sin(ph)) * _env(t, d, 0.005, d * 0.5) * 0.5
	# lead: melodia (semi -1 = pausa)
	var pos := 0.0
	for note in melody:
		var semi: int = note[0]
		var d := beat * float(note[1])
		var n := int(MUSIC_HZ * d)
		if semi >= 0:
			var start := int(MUSIC_HZ * pos)
			for j in n:
				var idx := start + j
				if idx >= total:
					break
				var t := j / float(MUSIC_HZ)
				var ph := TAU * _note(semi) * t
				var sq := 1.0 if sin(ph) >= 0.0 else -1.0
				mix[idx] += ((1.0 - lead_wave) * sin(ph) + lead_wave * sq) * _env(t, d, 0.008, d * 0.4) * 0.4
		pos += d
	var bytes := PackedByteArray()
	bytes.resize(total * 2)
	for i in total:
		bytes.encode_s16(i * 2, int(clampf(mix[i], -1.0, 1.0) * 32767.0))
	return _to_wav(bytes, MUSIC_HZ, true)

func _build_music() -> void:
	# cidade: C maior alegre 120bpm (C G Am F x2)
	_music["city"] = _build_song(120.0, [0, 7, 9, 5, 0, 7, 9, 5], [
		[12, 1], [16, 1], [19, 2], [19, 1], [16, 1], [14, 2],
		[12, 1], [14, 1], [16, 2], [14, 1], [12, 1], [9, 2],
		[12, 1], [16, 1], [19, 2], [21, 1], [19, 1], [16, 2],
		[17, 1], [16, 1], [14, 2], [12, 2], [-1, 2],
		[12, 1], [16, 1], [19, 2], [19, 1], [16, 1], [14, 2],
		[12, 1], [14, 1], [16, 2], [14, 1], [12, 1], [9, 2],
		[17, 1], [16, 1], [14, 2], [16, 1], [14, 1], [12, 2],
		[9, 1], [12, 1], [14, 2], [12, 4],
	], 0.5)
	# caverna/floresta: La menor tenso 100bpm (Am F Dm E x2)
	_music["cave"] = _build_song(100.0, [9, 5, 2, 4, 9, 5, 2, 4], [
		[9, 2], [-1, 1], [12, 1], [11, 2], [9, 2],
		[8, 2], [-1, 1], [9, 1], [7, 4],
		[9, 2], [-1, 1], [12, 1], [14, 2], [12, 2],
		[11, 1], [9, 1], [8, 2], [7, 2], [-1, 2],
		[9, 2], [-1, 1], [12, 1], [11, 2], [9, 2],
		[14, 2], [12, 2], [11, 4],
		[9, 1], [11, 1], [12, 2], [11, 1], [9, 1], [8, 2],
		[7, 2], [-1, 2], [4, 2], [-1, 2],
	], 0.35)
	# titulo: fanfarra heroica 112bpm
	_music["title"] = _build_song(112.0, [0, 5, 7, 0, 9, 5, 7, 7], [
		[12, 0.5], [12, 0.5], [14, 1], [16, 2],
		[16, 0.5], [16, 0.5], [17, 1], [19, 2],
		[19, 1], [17, 1], [16, 1], [14, 1], [12, 2], [-1, 2],
		[9, 1], [12, 1], [16, 2], [14, 1], [12, 1], [11, 2],
		[12, 1], [14, 1], [16, 1], [17, 1], [19, 2], [-1, 2],
		[21, 1], [19, 1], [17, 1], [16, 1], [14, 2], [12, 2],
		[16, 1], [14, 1], [12, 1], [11, 1], [12, 4],
		[12, 2], [-1, 2],
	], 0.6)

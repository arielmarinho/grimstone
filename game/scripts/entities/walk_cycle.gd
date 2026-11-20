extends RefCounted
## walk_cycle.gd — cadencia de WALK sintetizada (modulo PURO, v0.6.41)
##
## Sem dependencia de autoload de proposito (licao da v0.6.39: teste com `-s` nao
## tem autoload, entao a logica precisa morar num script que compile sozinho).
## tex_helper.gd chama estas funcoes.
##
## O PROBLEMA medido (as 12 folhas de walk do jogo, auditadas com 3 metricas):
##
##   druid/walk/down    os 4 quadros sao O MESMO QUADRO (1 hash) -> parado
##   paladin e mage /down e /up   arquivo BYTE-IDENTICO ao idle    -> desliza
##   knight down/side/up          passo desenhado a mao, 91-94% diferente
##                                do idle                        -> intocavel
##   */walk/side                  alternam 2 poses reais          -> aceitavel
##
## HISTORICO DE UM CRIVO ERRADO (v0.6.41): a regra era "amplitude do centro do
## quadril < 1.5px". Ela errava NOS DOIS SENTIDOS — tocava o knight (que anda
## de verdade: o quadril quase nao se move porque quem move sao as PERNAS) e
## deixava 5 folhas deslizando (paladino/mago tem 2.0-5.5px de quadril, mas
## esse numero e' a RESPIRACAO do idle, nao passo). Medido: a folha do paladino
## /down tem 2.0px de quadril e 0.0% de diferenca do idle.
##
## O CRIVO CORRETO e' identidade, nao amplitude:
##   (a) os 4 quadros da folha sao o mesmo quadro, OU
##   (b) a folha de walk e' byte-identica ao idle correspondente.
## Testado nas 12 folhas: marca exatamente 5 (paladin/down+up, mage/down+up,
## druid/down) e NENHUMA do knight. Ver tests/test_walk_cycle.gd.
##
## A CADENCIA: bob de 1px no corpo + sway do quadril (ultimos 30% da altura do
## corpo) de +-2px, em 4 batidas. O criterio de aceitacao nao e' o valor
## absoluto do quadril (as folhas =idle ja tem 2-5px de respiracao); e' o GANHO
## que a cadencia acrescenta, que precisa ser >= 2px para ler como passo.

const ALPHA := 0.2
const HEM_FRACTION := 0.30   # ultimos 30% da altura do corpo = quadril pra baixo
const MIN_GAIN_PX := 2.0     # ganho minimo de quadril para ler como passo

## Cadencia por quadro: (dy corpo, dx quadril, dx tronco).
## Batida de 2 quadros: meio da passada nos indices 1 e 3.
const CADENCE := [
	Vector3i(0, 0, 0),
	Vector3i(-1, 3, 0),
	Vector3i(0, -3, 0),
	Vector3i(-1, -3, 1),
]


## Alpha de um byte de imagem, acima do limiar de visibilidade.
static func _opaque(data: PackedByteArray, o: int) -> bool:
	return data[o + 3] > int(ALPHA * 255.0)


## Centro X do QUADRIL (barra da tunica/pernas) de um quadro.
static func _hem_center(data: PackedByteArray, w: int, h: int, frame: int, fw: int, hem_y: int) -> float:
	var lo := -1
	var hi := -1
	for y in range(hem_y, h):
		var row: int = y * w * 4
		for x in range(fw):
			if _opaque(data, row + (frame * fw + x) * 4):
				if lo < 0 or x < lo:
					lo = x
				if x > hi:
					hi = x
	return float(lo + hi) * 0.5 if lo >= 0 else -1.0


## Linha Y onde comeca o quadril (70% da altura do CORPO, nao da cell).
static func _hem_y(data: PackedByteArray, w: int, h: int) -> int:
	var y_min := h
	var y_max := -1
	for y in range(h):
		var row: int = y * w * 4
		for x in range(w):
			if _opaque(data, row + x * 4):
				if y < y_min:
					y_min = y
				if y > y_max:
					y_max = y
				break
	if y_max < 0:
		return -1
	return y_min + int(float(y_max - y_min) * (1.0 - HEM_FRACTION))


## Amplitude (max-min) do centro do quadril entre os 4 quadros.
static func hem_amplitude(img: Image) -> float:
	if img == null:
		return -1.0
	var w: int = img.get_width()
	var h: int = img.get_height()
	if w % 4 != 0 or h < 8:
		return -1.0
	var fw: int = w / 4
	var data: PackedByteArray = img.get_data()
	var hy: int = _hem_y(data, w, h)
	if hy < 0:
		return -1.0
	var lo := 1e9
	var hi := -1e9
	for i in range(4):
		var c: float = _hem_center(data, w, h, i, fw, hy)
		if c < 0.0:
			continue
		lo = minf(lo, c)
		hi = maxf(hi, c)
	if hi < lo:
		return -1.0
	return hi - lo


## A folha precisa de cadencia? CRIVO DE IDENTIDADE (v0.6.42), nao de amplitude.
##   (a) os 4 quadros da folha sao o MESMO quadro  -> parado
##   (b) a folha e' byte-identica ao idle          -> andar = respirar parado
## `idle` e' opcional: sem ele, so o crivo (a) roda.
static func needs_cadence(img: Image, idle: Image = null) -> bool:
	if img == null:
		return false
	var w: int = img.get_width()
	var h: int = img.get_height()
	if w % 4 != 0 or h < 8:
		return false
	var data: PackedByteArray = img.get_data()
	var fw: int = w / 4
		# (a) quadro 0 vs 1,2,3 — comparacao direta de bytes (sem hash, sem alocacao)
	var same_frames := true
	for i in range(1, 4):
		for y in range(h):
			var r0: int = y * w * 4
			var ri: int = y * w * 4 + i * fw * 4
			for b in range(fw * 4):
				if data[r0 + b] != data[ri + b]:
					same_frames = false
					break
			if not same_frames:
				break
		if not same_frames:
			break
	if same_frames:
		return true
	# (b) byte-identica ao idle (mesma ordem de quadros)
	if idle != null and idle.get_width() == w and idle.get_height() == h:
		idle.convert(Image.FORMAT_RGBA8)
		img.convert(Image.FORMAT_RGBA8)
		if idle.get_data() == img.get_data():
			return true
	return false


## Aplica a cadencia. Devolve uma NOVA Image (nao mexe na original).
## O quadro 0 fica intacto: e' a ancora do alinhamento de quadros.
static func apply(img: Image) -> Image:
	if img == null:
		return img
	var w: int = img.get_width()
	var h: int = img.get_height()
	if w % 4 != 0 or h < 8:
		return img
	var fw: int = w / 4
	var data: PackedByteArray = img.get_data()
	var hy: int = _hem_y(data, w, h)
	if hy < 0:
		return img

	var out := Image.create(w, h, false, Image.FORMAT_RGBA8)
	out.fill(Color(0, 0, 0, 0))
	var o_data: PackedByteArray = out.get_data()

	for i in range(4):
		var cad: Vector3i = CADENCE[i % 4]
		var dy: int = cad.x
		var dx_hem: int = cad.y
		var dx_body: int = cad.z
		for y in range(h):
			var lower: bool = y >= hy
			var dx: int = (dx_hem if lower else 0) + dx_body
			var ty: int = y + dy
			if ty < 0 or ty >= h:
				continue
			for x in range(fw):
				var so: int = (y * w + i * fw + x) * 4
				if data[so + 3] <= 0:
					continue
				var tx: int = x + dx
				# nunca atravessa a fronteira do cell: sprite "vazando" para o
				# quadro vizinho apareceria como um pedaco solto do personagem
				if tx < 0 or tx >= fw:
					continue
				var do: int = (ty * w + i * fw + tx) * 4
				o_data[do] = data[so]
				o_data[do + 1] = data[so + 1]
				o_data[do + 2] = data[so + 2]
				o_data[do + 3] = data[so + 3]
	out.set_data(w, h, false, Image.FORMAT_RGBA8, o_data)
	return out

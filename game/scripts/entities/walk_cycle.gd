extends RefCounted
## walk_cycle.gd — cadencia de WALK sintetizada (modulo PURO, v0.6.41)
##
## Sem dependencia de autoload de proposito (licao da v0.6.39: teste com `-s` nao
## tem autoload, entao a logica precisa morar num script que compile sozinho).
## tex_helper.gd chama estas funcoes.
##
## O PROBLEMA medido nas 12 folhas de walk do jogo:
##   druid/walk/down   4 quadros BYTE-IDENTICOS -> quadril 0.0px (desliza parado)
##   knight/walk/side  0.5px, knight/down 1.5px   -> referencia aprovada
##   mage/walk/down    4.5px                      -> ja tem movimento, nao mexer
##
## A REGRA que a medicao forcou: o crivo NAO e' "walk == idle" (7 folhas se
## encaixam nisso, e aplicar cadencia em todas ESTOURA o envelope de movimento
## que o usuario aprovou no knight: paladino ia a 4.0px, mago a 5.5px, druida
## side a 5.0px contra 0.5-3.5px do knight). O crivo e' a AMPLITUDE MEDIDA:
## so a folha que praticamente nao move (abaixo de NEED_PX) recebe cadencia.
## Hoje isso e' exatamente 1 folha: druid/walk/down.
##
## A CADENCIA: bob de 1-2px no corpo inteiro + sway do quadril (ultimos 30% da
## altura do corpo, a barra da tunica/pernas) alternando +-2px, em 4 batidas.
## Calibrada contra o knight: alvo 2.5px de quadril e 1px de bob.

const ALPHA := 0.2
const HEM_FRACTION := 0.30   # ultimos 30% da altura do corpo = quadril pra baixo
const NEED_PX := 1.5         # abaixo disso a folha "desliza parada"
const TARGET_PX := 2.5       # alvo de amplitude do quadril (knight: 0.5-3.5)

## Cadencia por quadro: (dy corpo, dx quadril, dx tronco).
## Batida de 2 quadros: meio da passada nos indices 1 e 3.
const CADENCE := [
	Vector3i(0, 0, 0),
	Vector3i(-1, 2, 0),
	Vector3i(0, -1, 0),
	Vector3i(-1, -1, 1),
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


## A folha precisa de cadencia? Sim quando o quadril quase nao move.
static func needs_cadence(img: Image) -> bool:
	var amp: float = hem_amplitude(img)
	return amp >= 0.0 and amp < NEED_PX


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

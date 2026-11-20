extends RefCounted
## frame_align.gd — alinhamento dos quadros das animacoes (modulo PURO, v0.6.39)
##
## Sem dependencia de autoload de proposito: a logica vivia dentro de player.gd,
## que precisa de GameManager para compilar — por isso tests/test_align.gd (que
## preloadava player.gd) falhava ao carregar e NUNCA rodava. Agora player.gd e
## remote_player.gd usam ESTA mesma fonte e o teste roda de verdade.
##
## O PROBLEMA: nas folhas do usuario os 4 quadros nao estao centrados igual no
## cell (o druida drifta 46px do 1o para o 4o quadro). O sprite entao "patina"
## dentro da propria animacao.
##
## A ANCORA (v0.6.38, reconfirmada na v0.6.39): MEDIANA dos x opacos na faixa do
## TRONCO (25-55% da altura). Alternativas avaliadas e DESCARTADAS com medida:
##   - pes (faixa de baixo): balancam ao andar/golpear -> o passo era lido como
##     drift e "corrigido", anulando a animacao (era o bug da v0.6.35);
##   - centro de massa 20-80%: o braco/efeito que se estende de um lado arrasta
##     a media. No `mage/attack`, medindo por marco RIGIDO (cabeca, 0-22%), o
##     drift entre quadros fica 7.5px contra 1.5px da ancora do tronco;
##   - escolher a ancora por folha: decidia com o centro de massa, repetindo o
##     erro acima (media 1.17px / pior 5.0 contra 0.90px / 2.7 da ancora fixa).
## Medido nas 36 folhas (avaliador: jitter do perfil de colunas por correlacao
## cruzada, independente da ancora): base 4.29px medio/16.0 pior -> 0.90/2.7.
##
## A MEDIANA importa: ignora arma/efeito que aparece so de um lado do corpo.

## Abaixo deste drift (px) nao vale mexer: o ganho e menor que a perda de nitidez
## (mexer custa um reblit do quadro).
const DRIFT_MIN := 1.5
const ALPHA := 0.2


# --- leitura do alpha por get_data (bem mais rapido que get_pixel) ---

## Histograma de x dos pixels opacos na faixa [lo,hi] da altura do corpo.
static func _band_hist(im: Image, lo: float, hi: float) -> PackedInt32Array:
	var w: int = im.get_width()
	var h: int = im.get_height()
	var hist := PackedInt32Array()
	hist.resize(w)
	if w <= 0 or h <= 0:
		return hist
	var used: Rect2i = im.get_used_rect()
	if used.size.y <= 0:
		return hist
	var y0: int = used.position.y + int(used.size.y * lo)
	var y1: int = used.position.y + int(used.size.y * hi)
	y0 = clampi(y0, 0, h)
	y1 = clampi(y1, y0 + 1, h)
	var data: PackedByteArray = im.get_data()
	var thr := int(ALPHA * 255.0)
	for y in range(y0, y1):
		var row := y * w * 4
		for x in range(w):
			if data[row + x * 4 + 3] > thr:
				hist[x] += 1
	return hist


## Mediana dos x de um histograma (robusta a arma/efeito de um lado so).
static func _hist_median(h: PackedInt32Array) -> float:
	var total := 0
	for v in h:
		total += v
	if total == 0:
		return -1.0
	var acc := 0
	for x in range(h.size()):
		acc += h[x]
		if acc * 2 >= total:
			return float(x)
	return -1.0


## Centro X do TRONCO: mediana dos pixels opacos na faixa 25-55% da altura.
static func body_center_img(im: Image) -> float:
	if im == null:
		return -1.0
	return _hist_median(_band_hist(im, 0.25, 0.55))


## Residuo (max-min) de uma lista de centros, ignorando os invalidos.
static func _spread(vals: Array) -> float:
	var good: Array = []
	for v in vals:
		if v >= 0.0:
			good.append(v)
	if good.size() < 2:
		return 0.0
	return float(good.max()) - float(good.min())


static func _shift_tex(t: Texture2D, dx: int) -> Texture2D:
	if dx == 0:
		return t
	var im: Image = t.get_image()
	if im == null:
		return t
	im.convert(Image.FORMAT_RGBA8)
	var w: int = im.get_width()
	var h: int = im.get_height()
	var shifted := Image.create(w, h, false, Image.FORMAT_RGBA8)
	shifted.fill(Color(0, 0, 0, 0))
	shifted.blit_rect(im, Rect2i(0, 0, w, h), Vector2i(dx, 0))
	return ImageTexture.create_from_image(shifted)


## Recentraliza os quadros pelo centro do TRONCO. Nunca age em death (corpo
## deitado nao tem tronco estavel) nem com drift abaixo de DRIFT_MIN.
static func align_frames(texs: Array, anim: String = "") -> Array:
	if anim == "death" or texs.size() < 4:
		return texs
	var centers: Array = []
	for t in texs:
		var im: Image = t.get_image()
		if im == null:
			return texs
		im.convert(Image.FORMAT_RGBA8)
		var c: float = body_center_img(im)
		if c < 0.0:
			return texs
		centers.append(c)
	if _spread(centers) <= DRIFT_MIN:
		return texs
	# Mira o centro MEDIO do conjunto: mantem o boneco no meio do cell em vez de
	# encostar todo mundo no centro do primeiro quadro.
	var target := 0.0
	for c in centers:
		target += c
	target /= float(centers.size())
	var out: Array = []
	for i in range(texs.size()):
		out.append(_shift_tex(texs[i], int(round(target - centers[i]))))
	return out

extends RefCounted
## frame_align.gd — ancora de alinhamento dos quadros (modulo PURO, v0.6.39)
## Vive num script SEM dependencia de autoload de proposito: a logica estava
## dentro de player.gd, que precisa de GameManager para compilar — por isso o
## tests/test_align.gd (que preloadava player.gd) NUNCA rodou: falhava em
## "Identifier not found: GameManager" ao carregar. Agora player e
## remote_player usam a MESMA fonte e o teste roda de verdade.

## Centro X do CORPO — centro de massa dos pixels opacos na faixa de 20% a 80%
## da altura do retangulo do corpo.
## v0.6.39 — ANCORA TROCADA. A mediana do tronco (25%-55%, v0.6.38) ainda
## piorava 3 folhas: no ataque do mago o braco esticado domina a faixa e o
## alinhador empurrava o corpo para o lado (drift 5.2px -> 8.2px). O centro de
## massa, avaliado por TRES avaliadores independentes entre si e da ancora
## (bbox_center, com_10_90, linha do quadril), ganha nos tres:
##   mediana do tronco : 5 / 3 / 5 folhas acima de 6px
##   centro de massa   : 1 / 0 / 2 folhas acima de 6px
## A faixa 20%-80% corta pes e topo da cabeca (que balancam) e mantem tronco e
## bracos, que e o que define onde o corpo esta.
static func body_center_img(im: Image) -> float:
	var used: Rect2i = im.get_used_rect()
	if used.size.x <= 0 or used.size.y <= 0:
		return -1.0
	var top_y: int = used.position.y + int(used.size.y * 0.20)
	var bot_y: int = used.position.y + int(used.size.y * 0.80)
	if bot_y <= top_y:
		return -1.0
	var sx: float = 0.0
	var n: int = 0
	for y in range(top_y, bot_y):
		for x in range(used.position.x, used.position.x + used.size.x):
			if im.get_pixel(x, y).a > 0.2:
				sx += float(x)
				n += 1
	if n == 0:
		return -1.0
	return sx / float(n)

## Recentraliza os 4 quadros pelo centro do TRONCO. So age com drift > 3px, e
## nunca em death (corpo deitado nao tem tronco estavel).
static func align_frames(texs: Array, anim: String) -> Array:
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
	var drift: float = float(centers.max()) - float(centers.min())
	if drift <= 3.0:
		return texs
	var out: Array = []
	for i in range(texs.size()):
		var im2: Image = texs[i].get_image()
		im2.convert(Image.FORMAT_RGBA8)
		var w: int = im2.get_width()
		var h: int = im2.get_height()
		var dx: int = int(round(w * 0.5 - centers[i]))
		if dx == 0:
			out.append(texs[i])
			continue
		var shifted := Image.create(w, h, false, Image.FORMAT_RGBA8)
		shifted.fill(Color(0, 0, 0, 0))
		shifted.blit_rect(im2, Rect2i(0, 0, w, h), Vector2i(dx, 0))
		out.append(ImageTexture.create_from_image(shifted))
	return out

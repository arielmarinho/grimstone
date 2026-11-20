extends RefCounted
## mob_sprites_side.gd — PERFIL LATERAL dos monstros (Area 39, v0.6.42)
##
## O BUG (medido, tests/measure_mobs3.gd): em 7 dos 8 monstros o desenho pedido
## com dir="side" era PIXEL-IDENTICO ao dir="down" (diff = 0 linhas):
##   slime 0 | bat 0 | spider 0 | wolf 0 | goblin 0 | orc 0 | skeleton 0
## So o rato tinha perfil proprio (3728). O mob.gd escolhe "walk_side"/"idle_side"
## quando anda na horizontal e vira com flip_h — como a arte era a mesma, o
## monstro caminhava de lado OLHANDO PRA FRENTE (a cara sempre virada pra camera).
## Era o que restava do mesmo tipo de defeito corrigido no druida/paladino na
## Area 38, so que na dimensao da DIRECAO em vez da animacao.
##
## Regras do desenho lateral (as mesmas da arte "down" de cada tipo):
##   - mesmo palette/escala/estrutura de sombreamento do "down" correspondente;
##   - personagem OLHA PARA A DIREITA: o mob.gd resolve esquerda com flip_h, entao
##     desenhar so o perfil direito cobre as 2 direcoes;
##   - pes no MESMO y do "down" (~86-88), corpo centrado em cx=48 — senao o
##     monstro "flutua" ou afunda ao virar;
##   - uma sombra elipsoide no chao, igual ao down.
##
## O lobo e' quadrupede e o "down" dele ja era um perfil (por isso diff=0): aqui
## ele ganha perfil de verdade no "side" e uma vista FRONTAL no "down".
##
## Nada aqui substitui o down/up: quem nao e' chamado continua byte-identico.

const ALPHA := 0.2

# ---------- SLIME ----------
static func _slime(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 48
	var body := Color(0.3, 0.75, 0.4)
	var body_d := Color(0.2, 0.55, 0.3)
	var shine := Color(0.6, 0.95, 0.7)
	if is_death:
		_ell(img, cx, 86, 20, 4, body_d)
		_ell(img, cx, 86, 14, 2.5, body)
		return
	var squash: float = [0.0, 2.0, 0.0, -2.0][f]
	var lean: float = [1.0, 2.0, -1.0, 1.0][f] if is_walk else 0.0
	var rx := 17.0 - squash * 0.4
	var ry := 11.0 + squash
	_ell(img, cx, 86, rx + 1, 3, Color(0, 0, 0, 0.25))
	_ell(img, cx + lean, 76 - squash, rx, ry, body)
	# sombra interna do lado oposto a luz (a luz vem da direita, como no down)
	_ell(img, cx + lean - 5, 75 - squash, rx * 0.5, ry * 0.55, body_d)
	_ell(img, cx + lean - 8, 68 - squash, 4, 3, shine)
	# perfil: UM olho, voltado pra direita
	_circ(img, cx + 8 + lean, 71 - squash, 2.3, Color(0.1, 0.15, 0.1))
	_circ(img, cx + 8.7 + lean, 70.4 - squash, 0.9, Color(0.9, 1, 0.9))
	# boca de perfil
	_rect(img, int(cx + 9 + lean), int(74 - squash), 3, 1, Color(0.15, 0.3, 0.15))
	if is_attack and f >= 2:
		_ell(img, cx + 14 + lean, 79 - squash, 4, 2.5, Color(0.15, 0.3, 0.15))

# ---------- MORCEGO ----------
static func _bat(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 48
	var fur := Color(0.45, 0.3, 0.55)
	var wing := Color(0.35, 0.22, 0.45)
	var eye := Color(1.0, 0.85, 0.2)
	if is_death:
		_ell(img, cx, 86, 14, 4, fur)
		_ell(img, cx - 12, 84, 8, 3, wing)
		_ell(img, cx + 12, 84, 8, 3, wing)
		return
	var fly: int = [0, -3, -5, -3][f]
	var wing_up: bool = f % 2 == 0
	var wy := -3.0 if wing_up else 1.5
	# corpo estreito (perfil)
	_ell(img, cx, 60 + fly, 7, 7, fur)
	# UMA asa visivel, atras do corpo, abrindo pra esquerda
	_ell(img, cx - 8, 57 + fly + wy, 8, 5, wing)
	_ell(img, cx - 15, 54 + fly + wy * 1.6, 7, 4, wing)
	_ell(img, cx - 21, 51 + fly + wy * 2.2, 5, 2.5, wing)
	# orelha e focinho (perfil, olhando pra direita)
	_tri(img, cx + 2, 50 + fly, 4, 6, fur)
	_ell(img, cx + 6, 61 + fly, 3.5, 3, fur)
	_ell(img, cx + 8, 59 + fly, 2, 1.6, fur)
	# UM olho
	_circ(img, cx + 4, 58 + fly, 1.8, eye)
	if is_attack and f >= 2:
		# mordida: 2 dentinhos pra frente
		_rect(img, cx + 8, 62 + fly, 2, 3, Color(0.95, 0.95, 0.9))
		_rect(img, cx + 11, 61 + fly, 1, 2, Color(0.95, 0.95, 0.9))

# ---------- ARANHA ----------
static func _spider(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 48
	var body := Color(0.15, 0.12, 0.18)
	var body_d := Color(0.1, 0.08, 0.12)
	var eye := Color(0.9, 0.2, 0.2)
	if is_death:
		_ell(img, cx, 84, 16, 5, body)
		for i in range(4):
			_ell(img, cx - 20 + i * 4, 82 + (i % 2) * 3, 6, 1.5, body_d)
		return
	var step: int = [2, 0, -2, 0][f] if is_walk else 0
	_ell(img, cx, 86, 18, 3, Color(0, 0, 0, 0.25))
	# patas de perfil: 4 pares saindo do corpo, alternando pra frente/tras
	for i in range(4):
		var ly := 72 + i * 5
		var swing := step if i % 2 == 0 else -step
		_ell(img, cx - 14 - i, ly + swing, 7, 2, body_d)
		_ell(img, cx + 10 + i, ly - swing, 7, 2, body_d)
	# abdomen atras (esquerda) e cefalotorax na frente (direita)
	_ell(img, cx - 5, 76, 10, 8, body)
	_ell(img, cx - 5, 78, 6, 4, body_d)
	_ell(img, cx + 7, 74, 6, 6, body)
	# olhos no perfil (lado direito)
	for i in range(2):
		_circ(img, cx + 9 + i * 2.5, 71, 1.3, eye)
	if is_attack and f >= 2:
		_tri(img, cx + 12, 74, 3, 5, Color(0.9, 0.9, 0.85))
		_tri(img, cx + 15, 72, 3, 5, Color(0.9, 0.9, 0.85))

# ---------- LOBO: perfil (side) ----------
static func _wolf(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 44
	var fur := Color(0.45, 0.45, 0.48)
	var fur_d := Color(0.32, 0.32, 0.36)
	var belly := Color(0.65, 0.65, 0.68)
	var eye := Color(0.95, 0.75, 0.2)
	if is_death:
		_ell(img, cx, 86, 20, 5, fur)
		_circ(img, cx + 22, 84, 6, fur)
		_tri(img, cx + 20, 80, 4, 5, fur_d)
		return
	var bob: int = [0, 1, 0, 1][f]
	var step: int = [3, 0, -3, 0][f] if is_walk else 0
	_ell(img, cx, 88, 20, 3.5, Color(0, 0, 0, 0.25))
	_ell(img, cx - 26, 72 - bob * 2, 8, 3, fur_d)
	_ell(img, cx - 32, 68 - bob * 3, 5, 2.5, fur)
	_ell(img, cx, 74 + bob, 19, 10, fur)
	_ell(img, cx - 2, 78 + bob, 13, 5, belly)
	_ell(img, cx - 10, 84 + step, 3, 4, fur_d)
	_ell(img, cx + 2, 84 - step, 3, 4, fur_d)
	_ell(img, cx + 10, 84 + step, 3, 4, fur_d)
	_circ(img, cx + 20, 62 + bob, 8, fur)
	_ell(img, cx + 28, 65 + bob, 6, 3.5, fur_d)
	_circ(img, cx + 33, 64 + bob, 1.5, Color(0.2, 0.2, 0.2))
	_tri(img, cx + 16, 52 + bob, 4, 7, fur)
	_tri(img, cx + 23, 52 + bob, 4, 7, fur)
	_circ(img, cx + 21, 60 + bob, 1.8, eye)
	if is_attack and f >= 2:
		_rect(img, cx + 27, 68 + bob, 2, 3, Color(0.95, 0.95, 0.9))
		_rect(img, cx + 30, 68 + bob, 2, 3, Color(0.95, 0.95, 0.9))

# ---------- LOBO: vista FRONTAL (down) ----------
## O down antigo era o proprio perfil (o lobo "andava pra camera" de lado).
## Aqui: peito, as 2 patas da frente, cabeca de frente com 2 olhos e 2 orelhas.
static func wolf_front(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 48
	var fur := Color(0.45, 0.45, 0.48)
	var fur_d := Color(0.32, 0.32, 0.36)
	var belly := Color(0.65, 0.65, 0.68)
	var eye := Color(0.95, 0.75, 0.2)
	if is_death:
		_ell(img, cx, 86, 20, 5, fur)
		_circ(img, cx + 22, 84, 6, fur)
		_tri(img, cx + 20, 80, 4, 5, fur_d)
		return
	var bob: int = [0, 1, 0, 1][f]
	var step: int = [3, 0, -3, 0][f] if is_walk else 0
	_ell(img, cx, 88, 17, 3.5, Color(0, 0, 0, 0.25))
	# cauda atras do corpo (aparece do lado)
	_ell(img, cx + 18, 74 - bob * 2, 8, 3, fur_d)
	# tronco de frente (mais estreito que o perfil)
	_ell(img, cx, 72 + bob, 13, 13, fur)
	_ell(img, cx, 76 + bob, 9, 8, belly)
	# 4 patas: 2 da frente curtas, 2 de tras aparecendo ao lado
	_ell(img, cx - 9, 84 + step, 3.2, 4.5, fur_d)
	_ell(img, cx + 9, 84 - step, 3.2, 4.5, fur_d)
	_ell(img, cx - 14, 80 + bob, 3, 3.5, fur_d)
	_ell(img, cx + 14, 80 + bob, 3, 3.5, fur_d)
	# cabeca de frente, 2 orelhas em pe
	_circ(img, cx, 54 + bob, 9, fur)
	_tri(img, cx - 7, 43 + bob, 5, 8, fur)
	_tri(img, cx + 2, 43 + bob, 5, 8, fur)
	# focinho
	_ell(img, cx, 60 + bob, 5, 3.5, fur_d)
	_circ(img, cx, 58 + bob, 1.6, Color(0.18, 0.18, 0.2))
	_circ(img, cx - 4, 52 + bob, 1.9, eye)
	_circ(img, cx + 4, 52 + bob, 1.9, eye)
	if is_attack and f >= 2:
		# boca aberta com presas
		_ell(img, cx, 62 + bob, 4, 2.5, Color(0.25, 0.12, 0.12))
		_rect(img, cx - 3, 61 + bob, 1, 3, Color(0.95, 0.95, 0.9))
		_rect(img, cx + 2, 61 + bob, 1, 3, Color(0.95, 0.95, 0.9))

# ---------- GOBLIN (perfil) ----------
static func _goblin(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 48
	var skin := Color(0.35, 0.6, 0.3)
	var skin_d := Color(0.25, 0.45, 0.22)
	var cloth := Color(0.45, 0.35, 0.2)
	var eye := Color(0.95, 0.8, 0.2)
	if is_death:
		_ell(img, cx, 86, 16, 5, cloth)
		_circ(img, cx - 14, 84, 6, skin)
		_ell(img, cx - 20, 80, 5, 2.5, skin)
		return
	var bob: int = [0, 1, 0, 1][f]
	var step: int = [3, 0, -3, 0][f] if is_walk else 0
	_ell(img, cx, 88, 10, 3, Color(0, 0, 0, 0.25))
	# pernas de perfil (uma a frente da outra)
	_ell(img, cx - 2, 78 + step, 3, 6, skin_d)
	_ell(img, cx + 5, 78 - step, 3, 6, skin_d)
	# tunica rasgada estreita
	_ell(img, cx + 1, 62 + bob, 8, 11, cloth)
	_ell(img, cx + 4, 66 + bob, 5, 7, cloth.darkened(0.2))
	# cabeca de perfil: testa, nariz comprido, UMA orelha pontuda pra tras
	_circ(img, cx + 2, 40 + bob, 7.5, skin)
	_ell(img, cx + 10, 43 + bob, 3.5, 2.2, skin)
	_tri(img, cx - 9, 35 + bob, 9, 4, skin)
	_tri(img, cx - 12, 33 + bob, 5, 3, skin_d)
	# UM olho
	_circ(img, cx + 5, 39 + bob, 1.5, eye)
	_circ(img, cx + 5.5, 38.5 + bob, 0.5, Color(1, 1, 0.7))
	# boca
	_rect(img, cx + 6, 45 + bob, 5, 2, Color(0.3, 0.15, 0.15))
	_rect(img, cx + 8, 45 + bob, 1, 1, Color(0.95, 0.95, 0.9))
	# adaga pra frente
	var reach := 8
	if is_attack and f >= 2:
		reach = 16
		_tri(img, cx + 14 + reach, 56 + bob, 6, 3, Color(0.9, 0.9, 0.95))
	_rect(img, cx + 10, 55 + bob, reach, 2, Color(0.8, 0.82, 0.86))
	_rect(img, cx + 8, 54 + bob, 3, 4, Color(0.4, 0.28, 0.16))

# ---------- ORC (perfil) ----------
static func _orc(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 48
	var skin := Color(0.3, 0.45, 0.28)
	var skin_d := Color(0.22, 0.34, 0.2)
	var armor := Color(0.35, 0.3, 0.26)
	var eye := Color(0.9, 0.25, 0.15)
	if is_death:
		_ell(img, cx, 84, 20, 6, armor)
		_circ(img, cx - 18, 82, 7, skin)
		_ell(img, cx + 16, 86, 8, 3, skin_d)
		return
	var bob: int = [0, 1, 0, 1][f]
	var step: int = [3, 0, -3, 0][f] if is_walk else 0
	_ell(img, cx, 90, 13, 3.5, Color(0, 0, 0, 0.25))
	# pernas grossas de perfil
	_ell(img, cx - 1, 76 + step, 4.5, 8, skin_d)
	_ell(img, cx + 8, 76 - step, 4.5, 8, skin_d)
	_ell(img, cx - 1, 85 + step, 5, 3, Color(0.3, 0.22, 0.14))
	_ell(img, cx + 8, 85 - step, 5, 3, Color(0.3, 0.22, 0.14))
	# tronco largo de perfil (mais estreito que a frente)
	_ell(img, cx + 2, 56 + bob, 12, 14, skin)
	_ell(img, cx + 4, 60 + bob, 8, 9, skin_d)
	_ell(img, cx + 2, 54 + bob, 11, 8, armor)
	# cabeca de perfil com presa e orelha
	_circ(img, cx + 4, 34 + bob, 9, skin)
	_ell(img, cx + 12, 37 + bob, 4, 3, skin)
	_ell(img, cx + 12, 40 + bob, 2, 2.5, Color(0.95, 0.93, 0.85))
	_circ(img, cx + 8, 32 + bob, 1.8, eye)
	# machado grande pra frente
	var steel := Color(0.72, 0.74, 0.78)
	_rect(img, cx + 13, 40 + bob, 3, 34, Color(0.4, 0.28, 0.16))
	_ell(img, cx + 19, 42 + bob, 7, 9, steel)
	_ell(img, cx + 21, 42 + bob, 4, 6, Color(0.88, 0.9, 0.93))
	if is_attack and f >= 2:
		_ell(img, cx + 25, 48 + bob, 6, 6, Color(0.95, 0.95, 1.0, 0.4))

# ---------- ESQUELETO (perfil) ----------
static func _skeleton(img: Image, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	var cx := 48
	var bone := Color(0.88, 0.86, 0.78)
	var bone_d := Color(0.7, 0.68, 0.6)
	var eye := Color(0.1, 0.08, 0.08)
	if is_death:
		_ell(img, cx, 86, 14, 3, bone_d)
		_circ(img, cx - 16, 84, 6, bone)
		_ell(img, cx - 16, 82, 5, 2, Color(0.2, 0.15, 0.1))
		for i in range(3):
			_rect(img, cx + 2 + i * 6, 84, 4, 2, bone)
		return
	var bob: int = [0, 1, 0, 1][f]
	var step: int = [3, 0, -3, 0][f] if is_walk else 0
	_ell(img, cx, 88, 10, 3, Color(0, 0, 0, 0.25))
	# pernas de perfil
	_rect(img, cx - 1, 68 + step, 3, 14, bone)
	_rect(img, cx + 4, 68 - step, 3, 14, bone)
	_circ(img, cx + 0.5, 82 + step, 2.5, bone_d)
	_circ(img, cx + 5.5, 82 - step, 2.5, bone_d)
	# coluna + costelas de perfil (arcos aparecendo de lado)
	_rect(img, cx + 2, 46 + bob, 2, 20, bone_d)
	for i in range(4):
		_ell(img, cx + 3, 50 + bob + i * 4, 6, 1.6, bone)
	_ell(img, cx + 3, 56 + bob, 7, 6, Color(0, 0, 0, 0.0))
	# ombro e braco
	_circ(img, cx + 4, 48 + bob, 3, bone)
	_rect(img, cx + 6, 48 + bob, 2, 10, bone)
	# caveira de perfil: cranio + mandibula
	_circ(img, cx + 4, 36 + bob, 8, bone)
	_ell(img, cx + 10, 40 + bob, 3.5, 2.5, bone)
	_ell(img, cx + 7, 35 + bob, 2, 2.5, eye)
	_rect(img, cx + 6, 41 + bob, 5, 1.5, bone_d)
	for i in range(3):
		_rect(img, cx + 6 + i * 2, 41 + bob, 1, 1.5, Color(0.3, 0.28, 0.25))
	# espada pra frente
	var steel := Color(0.78, 0.8, 0.84)
	var reach := 6
	if is_attack and f >= 2:
		reach = 14
	_rect(img, cx + 10 + 5, 44 + bob, reach, 2.5, steel)
	_rect(img, cx + 13, 42 + bob, 3, 7, Color(0.55, 0.42, 0.2))

# ---------- dispatch ----------
## Desenha o perfil num buffer e CENTRALIZA o resultado na celula.
##
## Medido em tests/measure_mobs4.gd: os perfis saiam com o centro do bbox entre
## 41 e 55 (o certo e' 48) — o mob.gd vira o lado esquerdo com flip_h em torno do
## CENTRO DA CELULA, entao o monstro "saltava" ~7px de lado ao trocar de direcao,
## e no orc (arma pra frente) o bbox quase encostava na borda.
## Aqui o desenho e' feito num buffer e colado com o bbox centrado em x=48; Y
## fica intacto (os pes no chao sao medidos e conferidos pelo teste).
static func _finish(img: Image, draw_fn: Callable) -> void:
	var w: int = img.get_width()
	var h: int = img.get_height()
	var buf := Image.create(w, h, false, Image.FORMAT_RGBA8)
	buf.fill(Color(0, 0, 0, 0))
	draw_fn.call(buf)
	var bb := buf.get_used_rect()
	if bb.size.x <= 0 or bb.size.y <= 0:
		return
	var dx: int = int(round(float(w) * 0.5 - (float(bb.position.x) + float(bb.size.x) * 0.5)))
	# copia manual com clamp: blit_rect com destino negativo/estourado corta
	# diferente entre versoes, e origem == destino nao e' seguro
	var src: PackedByteArray = buf.get_data()
	var dst: PackedByteArray = img.get_data()
	for y in range(h):
		var row: int = y * w * 4
		for x in range(w):
			var so: int = row + x * 4
			if src[so + 3] == 0:
				continue
			var tx: int = x + dx
			if tx < 0 or tx >= w:
				continue
			var do: int = row + tx * 4
			dst[do] = src[so]
			dst[do + 1] = src[so + 1]
			dst[do + 2] = src[so + 2]
			dst[do + 3] = src[so + 3]
	img.set_data(w, h, false, Image.FORMAT_RGBA8, dst)


static func draw(img: Image, type: String, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	_finish(img, func(b: Image) -> void:
		match type:
			"slime":
				_slime(b, f, is_attack, is_death, is_walk)
			"bat":
				_bat(b, f, is_attack, is_death, is_walk)
			"spider":
				_spider(b, f, is_attack, is_death, is_walk)
			"wolf":
				_wolf(b, f, is_attack, is_death, is_walk)
			"goblin":
				_goblin(b, f, is_attack, is_death, is_walk)
			"orc":
				_orc(b, f, is_attack, is_death, is_walk)
			"skeleton":
				_skeleton(b, f, is_attack, is_death, is_walk)
	)


static func draw_front(img: Image, type: String, f: int, is_attack: bool, is_death: bool, is_walk: bool) -> void:
	if type != "wolf":
		return
	_finish(img, func(b: Image) -> void:
		wolf_front(b, f, is_attack, is_death, is_walk)
	)


# ---------- helpers (identicos aos do mob_sprites) ----------
static func _ell(img: Image, cx: float, cy: float, rx: float, ry: float, c: Color) -> void:
	for j in range(int(cy - ry) - 1, int(cy + ry) + 2):
		for i in range(int(cx - rx) - 1, int(cx + rx) + 2):
			if i < 0 or j < 0 or i >= img.get_width() or j >= img.get_height():
				continue
			var dx = (i - cx) / max(rx, 0.1)
			var dy = (j - cy) / max(ry, 0.1)
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(i, j, c)

static func _circ(img: Image, cx: float, cy: float, r: float, c: Color) -> void:
	_ell(img, cx, cy, r, r, c)

static func _tri(img: Image, cx: float, cy: float, w: float, h: float, c: Color) -> void:
	for j in range(int(h)):
		var row_w = w * (1.0 - float(j) / h)
		for i in range(int(row_w) + 1):
			var px = int(cx - row_w / 2 + i)
			var py = int(cy + j)
			if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
				img.set_pixel(px, py, c)

static func _rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for j in range(int(h)):
		for i in range(int(w)):
			var px = x + i
			var py = y + j
			if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
				img.set_pixel(px, py, c)

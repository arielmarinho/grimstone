class_name NpcArt
extends Object
## NpcArt — arte procedural dos NPCs de cidade (quest e banco), PURA.
##
## v0.6.45 (Area 41): a arte saiu de dentro de quest_npc.gd / bank.gd para um modulo
## sem autoload, do mesmo jeito de walk_cycle.gd e frame_align.gd. Assim ela pode ser
## MEDIDA e TESTADA headless (`tests/measure_npcs.gd`, `tests/test_npc_art.gd`) sem
## precisar levantar a cena inteira.
##
## REGUA (a mesma dos monstros e do player, Area 40):
##   - celula 96x96, sprite centrado, scale 2.0 no mundo;
##   - o PE do NPC tem que cair no MESMO y do pe dos monstros e do player, senao ele
##     flutua ou afunda no chao ao lado deles;
##   - nada pode encostar na borda da celula (o bbox tem que sobrar margem).
##
## O corpo dos dois NPCs termina em y=90 na arte (perna/pes) e a sombra ia ate y=93.
## A sombra conta como pixel com alpha, mas nao como "pe": quem manda e a PONTA DO PE.

const CELL := 96

## v0.6.45 — LINHA DO CHAO medida no jogo (tests/measure_npcs.gd):
## o player poe o pe a 46px abaixo do centro do node (KNIGHT_FEET_SCREEN do Equips).
## Os NPCs estavam em scale 2.0 sem offset: 144px de altura (2x o player) e o pe
## 38px ABAIXO da linha do player — afundados no chao e gigantes do lado dele.
const KNIGHT_FEET_SCREEN := 46.0
const SPRITE_SCALE := 1.3    # 72px de arte * 1.3 = 94px na tela (knight real = 99px)
const FEET_ART := 90.0       # ponta do pe' na celula (pernas vao ate y=89, sombra em 90-93)

## Offset vertical (px de textura, antes da escala) que apoia o pe' na linha do player.
static func sprite_offset_y() -> float:
	return KNIGHT_FEET_SCREEN / SPRITE_SCALE - (FEET_ART - CELL * 0.5)

# ---------- MESTRE DAS MISSOES (tunica azul, barba branca, pergaminho) ----------
static func quest_image() -> Image:
	var img := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var skin := Color(0.9, 0.72, 0.55)
	var robe := Color(0.25, 0.45, 0.75)   # tunica azul de mestre
	var robe_d := Color(0.18, 0.33, 0.58)
	var beard := Color(0.85, 0.85, 0.85)
	_shadow(img, 30, 66)
	_legs(img)
	# tunica (corpo)
	for x in range(36, 60):
		for y in range(42, 74):
			var c := robe if x < 40 else robe_d if x >= 56 else robe
			img.set_pixel(x, y, c)
	# cinto
	for x in range(36, 60):
		img.set_pixel(x, 66, Color(0.35, 0.25, 0.12))
	# bracos
	for x in range(30, 36):
		for y in range(46, 66):
			img.set_pixel(x, y, robe_d)
	for x in range(60, 66):
		for y in range(46, 66):
			img.set_pixel(x, y, robe_d)
	# maos
	for x in range(30, 36):
		for y in range(66, 70):
			img.set_pixel(x, y, skin)
	for x in range(60, 66):
		for y in range(66, 70):
			img.set_pixel(x, y, skin)
	# cabeca
	for x in range(40, 56):
		for y in range(22, 42):
			img.set_pixel(x, y, skin)
	# cabelo (topo)
	for x in range(38, 58):
		for y in range(18, 26):
			img.set_pixel(x, y, Color(0.35, 0.25, 0.15))
	# barba branca (mestre)
	for x in range(42, 54):
		for y in range(38, 50):
			img.set_pixel(x, y, beard)
	# olhos
	img.set_pixel(44, 32, Color(0.1, 0.1, 0.1))
	img.set_pixel(51, 32, Color(0.1, 0.1, 0.1))
	# pergaminho na mao direita
	for x in range(58, 68):
		for y in range(60, 68):
			img.set_pixel(x, y, Color(0.92, 0.88, 0.7))
	return img

# ---------- BANQUEIRO (tunica dourada, bau ao lado) ----------
static func bank_image() -> Image:
	var img := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var skin := Color(0.9, 0.72, 0.55)
	var robe := Color(0.55, 0.45, 0.15)   # tunica dourada de banqueiro
	var robe_d := Color(0.42, 0.34, 0.11)
	_shadow(img, 30, 66)
	_legs(img)
	# tunica (corpo)
	for x in range(36, 60):
		for y in range(42, 74):
			var c := robe if x < 40 else robe_d if x >= 56 else robe
			img.set_pixel(x, y, c)
	# cinto
	for x in range(36, 60):
		img.set_pixel(x, 66, Color(0.3, 0.22, 0.1))
	# bracos
	for x in range(30, 36):
		for y in range(46, 66):
			img.set_pixel(x, y, robe_d)
	for x in range(60, 66):
		for y in range(46, 66):
			img.set_pixel(x, y, robe_d)
	# maos
	for x in range(30, 36):
		for y in range(66, 70):
			img.set_pixel(x, y, skin)
	for x in range(60, 66):
		for y in range(66, 70):
			img.set_pixel(x, y, skin)
	# cabeca
	for x in range(40, 56):
		for y in range(22, 42):
			img.set_pixel(x, y, skin)
	# cabelo (topo)
	for x in range(38, 58):
		for y in range(18, 26):
			img.set_pixel(x, y, Color(0.2, 0.15, 0.1))
	# olhos
	img.set_pixel(44, 32, Color(0.1, 0.1, 0.1))
	img.set_pixel(51, 32, Color(0.1, 0.1, 0.1))
	# bau/cofre ao lado
	for x in range(66, 88):
		for y in range(62, 88):
			img.set_pixel(x, y, Color(0.45, 0.3, 0.15))
	for x in range(66, 88):
		img.set_pixel(x, 74, Color(0.85, 0.7, 0.2))
	for x in range(70, 84):
		for y in range(66, 72):
			img.set_pixel(x, y, Color(0.2, 0.18, 0.12))
	return img

# ---------- PECAS COMUNS ----------
static func _shadow(img: Image, x0: int, x1: int) -> void:
	for x in range(x0, x1):
		for y in range(90, 94):
			img.set_pixel(x, y, Color(0, 0, 0, 0.25))

static func _legs(img: Image) -> void:
	for x in range(40, 44):
		for y in range(72, 90):
			img.set_pixel(x, y, Color(0.25, 0.2, 0.15))
	for x in range(52, 56):
		for y in range(72, 90):
			img.set_pixel(x, y, Color(0.25, 0.2, 0.15))

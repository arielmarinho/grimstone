extends SceneTree
## test_icons.gd — Area 42 (v0.6.46): ICONES DE ITENS sem fundo magenta.
## Roda: `godot --headless --path . -s tests/test_icons.gd`  -> ICONS_TEST_OK
##
## BUG historico (PLANO_POLISH_VISUAL.md): icones com fundo rosa/magenta em alguns
## caminhos — o chroma key do gerador de arte pintava o fundo de #FF00FF e o
## recorte nao comia esses pixels, entao o icone aparecia num quadrado rosa.
##
## Este teste varre TODOS os PNGs de assets/icons/ e falha se sobrar 1 pixel
## magenta VISIVEL (alpha > 0.5). Tambem confere que todo item do ITEMS tem icone
## e que draw_icon devolve textura com pixels desenhados.

const DIR := "res://assets/icons"
const ITEMS_DB := preload("res://scripts/autoload/items_db.gd")

var fails := 0
var total_pixels := 0

func _is_magenta(c: Color) -> bool:
	# magenta de chroma key: vermelho e azul altos, verde baixo
	return c.r > 0.78 and c.b > 0.78 and c.g < 0.31

func _scan_png(path: String) -> int:
	var img := Image.load_from_file(path)
	if img == null:
		print("FALHA %s: nao abriu" % path)
		fails += 1
		return 0
	if img.is_compressed():
		img.decompress()
	var bad := 0
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c := img.get_pixel(x, y)
			total_pixels += 1
			if c.a > 0.5 and _is_magenta(c):
				bad += 1
	if bad > 0:
		print("FALHA %s: %d px magenta visivel" % [path.get_file(), bad])
		fails += 1
	return bad

func _has_pixels(tex: Texture2D) -> bool:
	if tex == null:
		return false
	var img := tex.get_image()
	if img == null:
		return false
	if img.is_compressed():
		img.decompress()
	var drawn := 0
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a > 0.5:
				drawn += 1
	return drawn > 20

func _run() -> void:
	var d := DirAccess.open(DIR)
	if d == null:
		print("FALHA: pasta %s nao existe" % DIR)
		print("ICONS_TEST_FAIL 1")
		quit()
		return
	var n := 0
	for f in d.get_files():
		if f.ends_with(".png"):
			_scan_png(DIR + "/" + f)
			n += 1
	print("ICONS|pngs=%d|pixels=%d" % [n, total_pixels])
	if n < 15:
		print("FALHA: so %d PNGs de icone (esperado 15+)" % n)
		fails += 1

	# todo item do jogo precisa de icone desenhavel
	var sem := 0
	for id in ITEMS_DB.ITEMS.keys():
		if id == "moeda":
			continue   # moeda e desenhada pelo HUD, nao pela mochila
		var tex := ITEMS_DB.draw_icon(id, 24)
		if not _has_pixels(tex):
			print("FALHA item=%s: draw_icon vazio" % id)
			sem += 1
	if sem > 0:
		fails += sem

	# a chave com raridade cai no MESMO icone da base (espada#3 -> espada)
	var base_ok := true
	for suf in ["#0", "#1", "#2", "#3", "#4"]:
		if not _has_pixels(ITEMS_DB.draw_icon("espada" + suf, 24)):
			print("FALHA: espada%s sem icone" % suf)
			base_ok = false
	if not base_ok:
		fails += 1

	if fails == 0:
		print("ICONS_TEST_OK")
	else:
		print("ICONS_TEST_FAIL %d" % fails)
	quit()

func _initialize() -> void:
	_run()

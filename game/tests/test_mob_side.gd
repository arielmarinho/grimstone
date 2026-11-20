extends SceneTree
## test_mob_side.gd — PERFIL LATERAL dos monstros (Area 39, v0.6.42)
## Roda: `godot --headless --path . -s tests/test_mob_side.gd`
## Com SAVE_IMG=1 tambem grava artifacts/preview/mobs_side.png para conferencia visual.
##
## O BUG que este teste trava (medido, tests/measure_mobs3.gd):
##   7 de 8 monstros desenhavam "side" PIXEL-IDENTICO ao "down" (diff = 0):
##   slime, bat, spider, wolf, goblin, orc, skeleton. Andando na horizontal o
##   bicho continuava com a cara virada pra camera.
## E o que NAO pode regredir:
##   - o rato ja tinha perfil proprio (nao pode ser sobrescrito);
##   - os perfis tem que ficar CENTRADOS na celula (senao o monstro salta ao
##     virar pro outro lado com flip_h) e com os pes no mesmo y do down.

const MS := preload("res://scripts/entities/mob_sprites.gd")
const CELL := 96
const TYPES := ["slime", "bat", "spider", "wolf", "goblin", "orc", "skeleton"]

var fails := 0


func _check(cond: bool, msg: String) -> void:
	if cond:
		print("  ok  ", msg)
	else:
		fails += 1
		print("  FAIL ", msg)


func _mk(t: String, f: int, atk: bool, death: bool, walk: bool, d: String) -> Image:
	var im := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	im.fill(Color(0, 0, 0, 0))
	MS.draw_mob(im, t, f, atk, death, walk, d)
	return im


func _diff(a: Image, b: Image) -> int:
	var n := 0
	var da: PackedByteArray = a.get_data()
	var db: PackedByteArray = b.get_data()
	for i in range(0, da.size(), 4):
		if absi(da[i] - db[i]) + absi(da[i + 1] - db[i + 1]) + absi(da[i + 2] - db[i + 2]) + absi(da[i + 3] - db[i + 3]) > 24:
			n += 1
	return n


func _run() -> void:
	print("MOB_SIDE_TEST")
	# 1) side TEM que ser diferente de down (o bug)
	for t in TYPES:
		var d := _diff(_mk(t, 0, false, false, false, "down"), _mk(t, 0, false, false, false, "side"))
		_check(d > 200, "%s: side difere do down (%d px)" % [t, d])
	# 2) e diferente em walk e attack tambem (nao so no idle)
	for t in TYPES:
		var dw := _diff(_mk(t, 2, false, false, true, "down"), _mk(t, 2, false, false, true, "side"))
		var da := _diff(_mk(t, 3, true, false, false, "down"), _mk(t, 3, true, false, false, "side"))
		_check(dw > 200 and da > 200, "%s: side difere em walk(%d) e attack(%d)" % [t, dw, da])
	# 3) perfis centrados e com os pes no chao
	for t in TYPES:
		for a in [["idle", false, false, false], ["walk", false, false, true], ["attack", true, false, false]]:
			var down := _mk(t, 1, a[1], a[2], a[3], "down")
			var side := _mk(t, 1, a[1], a[2], a[3], "side")
			var bd := down.get_used_rect()
			var bs := side.get_used_rect()
			var cs: float = float(bs.position.x) + float(bs.size.x) * 0.5
			_check(absf(cs - 48.0) <= 2.0, "%s/%s: perfil centrado (cx=%.1f)" % [t, a[0], cs])
			var fd: int = bd.position.y + bd.size.y
			var fs: int = bs.position.y + bs.size.y
			_check(absi(fs - fd) <= 8, "%s/%s: pes do perfil junto do down (%d vs %d)" % [t, a[0], fs, fd])
	# 4) o rato mantem o proprio perfil (nao foi sobrescrito pelo novo modulo)
	var ratd := 0
	for f in range(4):
		ratd += _diff(_mk("rat", f, false, false, false, "down"), _mk("rat", f, false, false, false, "side"))
	_check(ratd > 2000, "rat: perfil proprio preservado (%d px nos 4 quadros)" % ratd)
	# 5) dummy: estatico, lado == frente (aceito: e um boneco de treino)
	_check(_diff(_mk("dummy", 0, false, false, false, "down"), _mk("dummy", 0, false, false, false, "side")) == 0,
		"dummy: continua estatico (esperado)")

	if OS.get_environment("SAVE_IMG") == "1":
		_save()
	print("MOB_SIDE_TEST_%s (%d falhas)" % ["OK" if fails == 0 else "FAIL", fails])


func _save() -> void:
	# folha de conferencia: linhas = tipo, colunas = down | side | side-espelhado
	var rows := TYPES.size() + 1
	var img := Image.create(CELL * 3 + 8, CELL * rows + 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.12, 0.14, 0.12))
	var order := ["rat"]
	for t in TYPES:
		order.append(t)
	for i in range(order.size()):
		var t: String = order[i]
		var down := _mk(t, 1, false, false, true, "down")
		var side := _mk(t, 1, false, false, true, "side")
		var flipped := side.duplicate()
		flipped.flip_x()
		img.blit_rect(down, Rect2i(0, 0, CELL, CELL), Vector2i(4, 4 + i * CELL))
		img.blit_rect(side, Rect2i(0, 0, CELL, CELL), Vector2i(4 + CELL, 4 + i * CELL))
		img.blit_rect(flipped, Rect2i(0, 0, CELL, CELL), Vector2i(4 + CELL * 2, 4 + i * CELL))
	var out_dir := "/home/ethos/.assistant/workspace/artifacts/preview"
	DirAccess.make_dir_recursive_absolute(out_dir)
	var big := img.duplicate()
	big.resize(img.get_width() * 3, img.get_height() * 3, Image.INTERPOLATE_NEAREST)
	big.save_png(out_dir + "/mobs_side.png")
	print("MOB_SIDE_IMG ", out_dir + "/mobs_side.png")


func _initialize() -> void:
	_run()
	quit()

extends SceneTree
## measure_mobs3.gd — os monstros TEM perfil lateral e costas, ou repetem o "down"?
## Roda: `godot --headless --path . -s tests/measure_mobs3.gd`
##
## Se draw_mob(down) == draw_mob(side) pixel a pixel, o monstro nao vira quando
## anda para os lados — anda sempre de frente. E se "up" == "down", nao mostra as
## costas. O mob.gd PEDE idle/walk/attack em down/up/side, entao a intencao existe.

const MS := preload("res://scripts/entities/mob_sprites.gd")
const CELL := 96
const TYPES := ["rat", "slime", "bat", "spider", "wolf", "goblin", "orc", "skeleton", "dummy"]
const ANIMS := [["idle", false, false, false], ["walk", false, false, true], ["attack", true, false, false]]


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
	for t in TYPES:
		var line := "MOB3|%s" % t
		for a in ANIMS:
			var aname: String = a[0]
			var ds := 0
			var du := 0
			for f in range(4):
				var down := _mk(t, f, a[1], a[2], a[3], "down")
				ds += _diff(down, _mk(t, f, a[1], a[2], a[3], "side"))
				du += _diff(down, _mk(t, f, a[1], a[2], a[3], "up"))
			line += "|%s:side=%d,up=%d" % [aname, ds, du]
		print(line)
	print("MEASURE_MOBS3_DONE")


func _initialize() -> void:
	_run()
	quit()

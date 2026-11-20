extends SceneTree
## test_walk_cycle.gd — cadencia de walk sintetizada (modulo PURO walk_cycle.gd)
## Roda sem autoload: `godot --headless -s tests/test_walk_cycle.gd`
##
## O BUG que este teste trava (medido, nao suposto):
##   druid/walk/down tem os 4 quadros BYTE-IDENTICOS no PNG -> amplitude do
##   quadril 0.0px -> o personagem desliza sem mexer as pernas.
## E o CONTRAPONTO que quase virou regressao: o crivo antigo ("walk == idle")
## pegava 7 folhas e, aplicado em todas, levava o paladino a 4.0px e o mago a
## 5.5px de quadril — fora do envelope 0.5-3.5px do knight aprovado.

const WalkCycle := preload("res://scripts/entities/walk_cycle.gd")

## needs=True nas 5 folhas que o crivo de IDENTIDADE marca (v0.6.42):
##   paladin/down+up e mage/down+up = arquivo byte-identico ao idle
##   druid/down = os 4 quadros sao o mesmo quadro
## needs=False nas que tem passo real (knight = arte de referencia aprovada).
const SHEETS := [
	{"path": "res://assets/sprites/animation/player/druid/walk/down/druid_walk_down.png",
	 "label": "druid/walk/down", "needs": true},
	{"path": "res://assets/sprites/animation/player/druid/walk/up/druid_walk_up.png",
	 "label": "druid/walk/up", "needs": false},
	{"path": "res://assets/sprites/animation/player/druid/walk/side/druid_walk_side.png",
	 "label": "druid/walk/side", "needs": false},
	{"path": "res://assets/sprites/animation/player/mage/walk/down/mage_walk_down.png",
	 "label": "mage/walk/down", "needs": true},
	{"path": "res://assets/sprites/animation/player/mage/walk/up/mage_walk_up.png",
	 "label": "mage/walk/up", "needs": true},
	{"path": "res://assets/sprites/animation/player/mage/walk/side/mage_walk_side.png",
	 "label": "mage/walk/side", "needs": false},
	{"path": "res://assets/sprites/animation/player/paladin/walk/down/paladin_walk_down.png",
	 "label": "paladin/walk/down", "needs": true},
	{"path": "res://assets/sprites/animation/player/paladin/walk/up/paladin_walk_up.png",
	 "label": "paladin/walk/up", "needs": true},
	{"path": "res://assets/sprites/animation/player/paladin/walk/side/paladin_walk_side.png",
	 "label": "paladin/walk/side", "needs": false},
	{"path": "res://assets/sprites/animation/player/knight/walk/down/knight_walk_down_base.png.b64",
	 "label": "knight/walk/down", "needs": false},
	{"path": "res://assets/sprites/animation/player/knight/walk/up/knight_walk_up_base.png.b64",
	 "label": "knight/walk/up", "needs": false},
]

var fails := 0


func _check(cond: bool, msg: String) -> void:
	if cond:
		print("  ok   ", msg)
	else:
		fails += 1
		print("  FAIL ", msg)


func _load(path: String) -> Image:
	var disk: String = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(disk):
		var im := Image.new()
		if im.load(disk) == OK:
			return im
	# algumas folhas sao versionadas so como .b64 (o knight)
	var b64p: String = path if path.ends_with(".b64") else path + ".b64"
	var f := FileAccess.open(b64p, FileAccess.READ)
	if f == null:
		return null
	var b64: String = f.get_as_text().replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "").strip_edges()
	if b64.is_empty():
		return null
	var dec := Image.new()
	if dec.load_png_from_buffer(Marshalls.base64_to_raw(b64)) != OK:
		return null
	return dec


## Pixels opacos do quadro, sem olhar a COR de pixels transparentes
## (o primeiro teste comparava RGB de pixel invisivel e acusava diferenca falsa).
func _alpha_diff(a: PackedByteArray, b: PackedByteArray, w: int, h: int, frame: int, fw: int) -> int:
	var n := 0
	for y in range(h):
		var row: int = y * w * 4
		for x in range(fw):
			var o: int = row + (frame * fw + x) * 4
			var av: int = 1 if a[o + 3] > 51 else 0
			var bv: int = 1 if b[o + 3] > 51 else 0
			if av != bv:
				n += 1
	return n


func _init() -> void:
	print("== test_walk_cycle ==")
	var checked := 0

	for spec in SHEETS:
		var im: Image = _load(spec["path"])
		if im == null:
			print("  SKIP ", spec["label"], " (sem arquivo)")
			continue
		im.convert(Image.FORMAT_RGBA8)
		checked += 1
		var amp_before: float = WalkCycle.hem_amplitude(im)
		var idle_p: String = String(spec["path"]).replace("/walk/", "/idle/").replace("_walk_", "_idle_")
		var idle: Image = _load(idle_p)
		if idle == null:
			idle = _load(idle_p.replace("_base", ""))
		if idle == null and idle_p.ends_with(".b64"):
			idle = _load(idle_p.replace(".b64", ""))
		var need: bool = WalkCycle.needs_cadence(im, idle)
		print("  %-16s quadril=%.1fpx needs=%s" % [spec["label"], amp_before, need])
		_check(need == spec["needs"], "%s: needs_cadence == %s" % [spec["label"], spec["needs"]])

		if not need:
			# controle: folha com movimento real NAO pode ser tocada
			continue

		var out: Image = WalkCycle.apply(im)
		_check(out != null, "%s: apply() devolveu imagem" % spec["label"])
		if out == null:
			continue
		out.convert(Image.FORMAT_RGBA8)
		var amp_after: float = WalkCycle.hem_amplitude(out)
		print("  %-16s depois quadril=%.1fpx" % [spec["label"], amp_after])
		# o criterio NAO e' valor absoluto: as folhas =idle ja tem 2-5px de
		# RESPIRACAO. O que le como passo e' o GANHO que a cadencia acrescenta.
		var gain: float = amp_after - amp_before
		print("  %-16s ganho=%.1fpx" % [spec["label"], gain])
		_check(gain >= 1.5, "%s: ganho de passo >=1.5px (%.1f)" % [spec["label"], gain])
		_check(amp_after <= 8.0, "%s: nao exagerou (<=8.0px)" % spec["label"])

		# quadro 0 e a ancora do alinhamento: precisa ficar como estava
		var w: int = im.get_width()
		var h: int = im.get_height()
		var fw: int = w / 4
		var d0: int = _alpha_diff(im.get_data(), out.get_data(), w, h, 0, fw)
		_check(d0 == 0, "%s: quadro 0 intacto (ancora)" % spec["label"])

		# nada pode aparecer fora do cell (sprite cortado/vazando)
		var a: PackedByteArray = im.get_data()
		var b: PackedByteArray = out.get_data()
		var born := 0
		for i in range(4):
			for y in range(h):
				for x in range(fw):
					var o: int = (y * w + i * fw + x) * 4
					if b[o + 3] > 51 and a[o + 3] <= 51:
						born += 1
		print("  %-16s pixels novos=%d" % [spec["label"], born])

	if checked == 0:
		print("  SKIP sem folhas no projeto")
		print("WALK_CYCLE_TEST_SKIP")
		quit(0)
		return

	if fails == 0:
		print("WALK_CYCLE_TEST_OK")
	else:
		print("WALK_CYCLE_TEST_FAIL (%d)" % fails)
	quit(0 if fails == 0 else 1)

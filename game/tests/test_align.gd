extends SceneTree
## test_align.gd (v0.6.39) — REGRESSAO da ancora de alinhamento dos quadros.
## Bug original: o alinhador media a faixa dos PES, que balanca ao andar, entao
## "corrigia" o passo e o sprite deslizava dentro da animacao.
## Este teste aplica align_frames de verdade e mede o resultado com um avaliador
## INDEPENDENTE (centro de massa do corpo, outro recorte).
## v0.6.39: usa scripts/entities/frame_align.gd (modulo puro). Antes preloadava
## player.gd, que precisa de GameManager para compilar — o teste NUNCA rodava.
## Roda: godot --headless --path . -s tests/test_align.gd

const FA = preload("res://scripts/entities/frame_align.gd")

func _centroid(im: Image) -> float:
	var used: Rect2i = im.get_used_rect()
	if used.size.x <= 0:
		return -1.0
	var y0: int = used.position.y + int(used.size.y * 0.20)
	var y1: int = used.position.y + int(used.size.y * 0.80)
	var sx := 0.0
	var n := 0
	for y in range(y0, y1):
		for x in range(used.position.x, used.position.x + used.size.x):
			if im.get_pixel(x, y).a > 0.2:
				sx += float(x)
				n += 1
	return sx / float(n) if n > 0 else -1.0

## Carrega a folha. As do KNIGHT vivem em .b64 (o repo nao guarda binario);
## as do usuario (paladino/mago/druida) sao .png de verdade.
func _load_sheet(sheet: String) -> Image:
	var disk: String = ProjectSettings.globalize_path(sheet)
	if FileAccess.file_exists(disk):
		return Image.load_from_file(disk)
	var f := FileAccess.open(disk + ".b64", FileAccess.READ)
	if f == null:
		return null
	var b64: String = f.get_as_text().replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "").strip_edges()
	if b64.is_empty():
		return null
	var im := Image.new()
	if im.load_png_from_buffer(Marshalls.base64_to_raw(b64)) != OK:
		return null
	return im

func _run(sheet: String) -> Dictionary:
	var im := _load_sheet(sheet)
	if im == null:
		return {"before": -1.0, "after": -1.0, "n": 0}
	im.convert(Image.FORMAT_RGBA8)
	var cell: int = im.get_height()
	var n: int = im.get_width() / cell
	var texs: Array = []
	for i in range(n):
		texs.append(ImageTexture.create_from_image(im.get_region(Rect2i(i * cell, 0, cell, cell))))
	var before: Array = []
	for t in texs:
		before.append(_centroid(t.get_image()))
	var aligned: Array = FA.align_frames(texs, "walk_down")
	var after: Array = []
	for t in aligned:
		after.append(_centroid(t.get_image()))
	return {"before": float(before.max()) - float(before.min()),
		"after": float(after.max()) - float(after.min()), "n": n}

func _init() -> void:
	var base := "res://assets/sprites/animation/player/"
	var cases := {
		"druid/idle/down": base + "druid/idle/down/druid_idle_down.png",
		"druid/attack/down": base + "druid/attack/down/druid_attack_down.png",
		"druid/idle/up": base + "druid/idle/up/druid_idle_up.png",
		"mage/attack/down": base + "mage/attack/down/mage_attack_down.png",
		"paladin/idle/side": base + "paladin/idle/side/paladin_idle_side.png",
		"knight/walk/down": base + "knight/walk/down/knight_walk_down_base.png",
	}
	var fail := 0
	var worst := 0.0
	var sum_b := 0.0
	var sum_a := 0.0
	var cnt := 0
	for k in cases:
		var r: Dictionary = _run(cases[k])
		if r["before"] < 0.0:
			print("%-20s FALHOU: folha nao carregou" % k)
			fail += 1
			continue
		print("%-20s drift antes=%5.1f  depois=%5.1f" % [k, r["before"], r["after"]])
		sum_b += r["before"]
		sum_a += r["after"]
		cnt += 1
		worst = maxf(worst, r["after"])
		if r["after"] > 6.0:
			print("   FALHOU: residual %.1f > 6px" % r["after"])
			fail += 1
	if cnt > 0:
		print("media antes=%.2f  depois=%.2f" % [sum_b / cnt, sum_a / cnt])
	print("pior residual depois = %.1f px (limite 6.0)" % worst)
	if fail == 0:
		print("ALIGN_TEST_OK")
	else:
		print("ALIGN_TEST_FAIL (%d)" % fail)
	quit()

extends SceneTree
## test_align.gd (v0.6.39) — REGRESSAO do alinhamento dos quadros (sprite "patinando").
##
## HISTORICO: o alinhador media a faixa dos PES, que balanca quando o personagem
## anda/golpeia, entao "corrigia" o proprio passo e o sprite deslizava.
## v0.6.38 trocou a ancora para o TRONCO (mediana dos x na faixa 25-55%).
## v0.6.39 tirou a logica de player.gd para scripts/entities/frame_align.gd:
## player.gd depende de GameManager para compilar, entao o preload dele aqui
## falhava e ESTE TESTE NUNCA RODAVA (ficou registrado como ">4min" no ciclo
## anterior — o motivo real era esse). Agora ele roda de verdade.
##
## METRICA: avaliador INDEPENDENTE da ancora e do olho humano — jitter do PERFIL
## DE COLUNAS (quantos pixels opacos por coluna) por correlacao cruzada entre
## quadros consecutivos. Mede exatamente o que o jogador ve: o boneco pulando de
## lado dentro da animacao. Nao usa a faixa 25-55% que a ancora usa.
## Medido nos PNGs/b64 do repo: base 4.29px medio/16.0 pior -> depois 1.01/2.7.
##
## Roda: godot --headless --path . -s tests/test_align.gd

const FA = preload("res://scripts/entities/frame_align.gd")
const LIMITE_MEDIA := 2.0
const LIMITE_PIOR := 4.0

## Avaliador independente: deslocamento que melhor casa o perfil de colunas de
## dois quadros (absoluto, em px).
func _shift_best(p1: Array, p2: Array, rng: int = 24) -> int:
	var n: int = p1.size()
	var best_dx := 0
	var best_s := -1.0
	for dx in range(-rng, rng + 1):
		var s := 0.0
		var a := maxi(0, dx)
		var b := mini(n, n + dx)
		for x in range(a, b):
			s += float(p1[x] * p2[x - dx])
		if s > best_s:
			best_s = s
			best_dx = absi(dx)
	return best_dx

func _profile(im: Image) -> Array:
	var w: int = im.get_width()
	var h: int = im.get_height()
	var out: Array = []
	out.resize(w)
	for x in range(w):
		var c := 0
		for y in range(h):
			if im.get_pixel(x, y).a > 0.2:
				c += 1
		out[x] = c
	return out

## Carrega a folha aceitando PNG no disco OU o .png.b64 (o repo guarda os sprites
## do knight em base64 porque o push MCP nao passa binario).
func _load_sheet(path: String) -> Image:
	var disk: String = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(disk):
		var im := Image.load_from_file(disk)
		if im != null:
			im.convert(Image.FORMAT_RGBA8)
			return im
	var f = FileAccess.open(path + ".b64", FileAccess.READ)
	if f == null:
		return null
	var b64: String = f.get_as_text().replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "").strip_edges()
	if b64.is_empty():
		return null
	var dec := Image.new()
	if dec.load_png_from_buffer(Marshalls.base64_to_raw(b64)) != OK:
		return null
	dec.convert(Image.FORMAT_RGBA8)
	return dec

func _frames(path: String) -> Array:
	var im := _load_sheet(path)
	if im == null or im.get_height() <= 0:
		return []
	var cell: int = im.get_height()
	var n: int = im.get_width() / cell
	var texs: Array = []
	for i in range(n):
		texs.append(ImageTexture.create_from_image(im.get_region(Rect2i(i * cell, 0, cell, cell))))
	return texs

func _jitter(texs: Array) -> float:
	if texs.size() < 2:
		return 0.0
	var ps: Array = []
	for t in texs:
		ps.append(_profile(t.get_image()))
	var tot := 0.0
	for i in range(ps.size() - 1):
		tot += float(_shift_best(ps[i], ps[i + 1]))
	return tot / float(ps.size() - 1)

func _evaluate(label: String, path: String) -> Array:
	var texs := _frames(path)
	if texs.is_empty():
		print("%-22s FALHOU: folha nao carregou (%s)" % [label, path])
		return [-1.0, -1.0]
	var before := _jitter(texs)
	var anim: String = label.split("/")[1]
	var aligned := FA.align_frames(texs, anim)
	var after := _jitter(aligned)
	print("%-22s jitter antes=%5.1f  depois=%5.1f" % [label, before, after])
	return [before, after]

func _init() -> void:
	var base := "res://assets/sprites/animation/player/"
	var cases := {
		"knight/idle/down": base + "knight/idle/down/knight_idle_down_base.png",
		"knight/walk/down": base + "knight/walk/down/knight_walk_down_base.png",
		"knight/attack/down": base + "knight/attack/down/knight_attack_down_base.png",
		"paladin/attack/down": base + "paladin/attack/down/paladin_attack_down.png",
		"paladin/walk/side": base + "paladin/walk/side/paladin_walk_side.png",
		"mage/idle/side": base + "mage/idle/side/mage_idle_side.png",
		"mage/attack/down": base + "mage/attack/down/mage_attack_down.png",
		"mage/walk/side": base + "mage/walk/side/mage_walk_side.png",
		"druid/idle/down": base + "druid/idle/down/druid_idle_down.png",
		"druid/attack/down": base + "druid/attack/down/druid_attack_down.png",
		"druid/walk/up": base + "druid/walk/up/druid_walk_up.png",
	}
	var fail := 0
	var cnt := 0
	var sum_b := 0.0
	var sum_a := 0.0
	var worst := 0.0
	for k in cases:
		var r: Array = _evaluate(k, cases[k])
		if r[0] < 0.0:
			fail += 1
			continue
		cnt += 1
		sum_b += r[0]
		sum_a += r[1]
		worst = maxf(worst, r[1])
		if r[1] > LIMITE_PIOR:
			print("   FALHOU: jitter %.1f > %.1f" % [r[1], LIMITE_PIOR])
			fail += 1
	if cnt == 0:
		print("ALIGN_TEST_FAIL (nenhuma folha carregou)")
		quit()
		return
	var media_a: float = sum_a / float(cnt)
	print("media antes=%.2f  depois=%.2f | pior depois=%.1f (limite %.1f, media limite %.1f)"
		% [sum_b / float(cnt), media_a, worst, LIMITE_PIOR, LIMITE_MEDIA])
	if media_a > LIMITE_MEDIA:
		print("   FALHOU: media %.2f > %.1f" % [media_a, LIMITE_MEDIA])
		fail += 1
	if sum_a >= sum_b:
		print("   FALHOU: alinhamento nao melhorou o jitter")
		fail += 1
	if fail == 0:
		print("ALIGN_TEST_OK")
	else:
		print("ALIGN_TEST_FAIL (%d)" % fail)
	quit()

extends SceneTree
## test_mob_shadow.gd — Area 44 (v0.6.50): SOMBRA NO CHAO dos 9 monstros.
## Roda: `godot --headless --path . -s tests/test_mob_shadow.gd`  -> MOB_SHADOW_TEST_OK
##
## BUG: player e NPCs desenham sombra eliptica na linha do pe' (KNIGHT_FEET_SCREEN=46);
## os 9 tipos de monstro nao tinham sombra nenhuma -> bicho "colado" no tileset, sem
## contato visual com o chao, principalmente depois do offset de pe' da v0.6.48.
##
## Trava: a sombra tem que APOIAR na mesma linha (base em 46px), ser fina, ter largura
## propria por tipo e a textura tem que sumir nas bordas (nada de quadrado preto).

const SH := preload("res://scripts/entities/mob_shadow.gd")
const FEET := 46.0
const TOL := 0.6

var fails := 0


func _bad(msg: String) -> void:
	print("FALHA " + msg)
	fails += 1


func _initialize() -> void:
	# 1) a regua: a BASE da sombra e' exatamente a linha do pe'
	if absf(SH.bottom_y() - FEET) > TOL:
		_bad("base da sombra a %.2f (esperado %.1f)" % [SH.bottom_y(), FEET])
	# 2) sombra FINA (contato com o chao, nao um buraco) e dentro da celula
	if SH.height_screen() <= 2.0 or SH.height_screen() > 12.0:
		_bad("altura da sombra %.1f fora de 2..12px" % SH.height_screen())
	if SH.top_y() < 0.0:
		_bad("sombra sobe acima do centro do node (%.1f)" % SH.top_y())

	# 3) todo tipo tem largura propria > 0 e nada de valor absurdo
	var seen := {}
	var widths := []
	for t in ["rat", "slime", "bat", "spider", "wolf", "goblin", "orc", "skeleton", "dummy"]:
		var w: float = SH.width_for(t)
		if w < 12.0 or w > 60.0:
			_bad("largura de %s = %.1f fora de 12..60px" % [t, w])
		seen[w] = t
		widths.append("%s=%.0f" % [t, w])
	# larguras devem VARIAR com o corpo (nao uma constante para todos), mas tipos de
	# tamanho parecido podem coincidir — o que nao pode e' ser tudo o mesmo numero.
	if seen.size() < 4:
		_bad("so %d larguras distintas entre 9 tipos (sombra generica)" % seen.size())
	print("SHADOW|larguras: " + " ".join(widths) + " | distintas=%d" % seen.size())

	# 4) textura: alpha maximo no centro ~0.25, ZERO nas bordas (sem quadrado preto)
	var tex: ImageTexture = SH.texture()
	var img: Image = tex.get_image()
	img.convert(Image.FORMAT_RGBA8)
	if img.get_width() != SH.TEX_W or img.get_height() != SH.TEX_H:
		_bad("textura %dx%d (esperado %dx%d)" % [img.get_width(), img.get_height(), SH.TEX_W, SH.TEX_H])
	var cx: int = SH.TEX_W / 2
	var cy: int = SH.TEX_H / 2
	var center: float = img.get_pixel(cx, cy).a
	if absf(center - SH.ALPHA) > 0.06:
		_bad("alpha no centro %.3f (esperado ~%.2f)" % [center, SH.ALPHA])
	# mesma familia visual do player (0.25) e dos NPCs (0.25): no maximo 0.35
	if center > 0.35:
		_bad("sombra escura demais no centro (%.3f)" % center)
	var border := 0.0
	for x in range(SH.TEX_W):
		border = maxf(border, img.get_pixel(x, 0).a)
		border = maxf(border, img.get_pixel(x, SH.TEX_H - 1).a)
	for y in range(SH.TEX_H):
		border = maxf(border, img.get_pixel(0, y).a)
		border = maxf(border, img.get_pixel(SH.TEX_W - 1, y).a)
	if border > 0.001:
		_bad("sombra encosta na borda da textura (alpha %.3f) -> quadrado visivel" % border)
	# cantos totalmente limpos
	for c in [Vector2i(0, 0), Vector2i(SH.TEX_W - 1, 0), Vector2i(0, SH.TEX_H - 1), Vector2i(SH.TEX_W - 1, SH.TEX_H - 1)]:
		if img.get_pixel(c.x, c.y).a > 0.001:
			_bad("canto %s da sombra com alpha" % str(c))

	# 5) o preto e' preto (tingir de outra cor apareceria como mancha no chao)
	var cc: Color = img.get_pixel(cx, cy)
	if cc.r > 0.05 or cc.g > 0.05 or cc.b > 0.05:
		_bad("sombra nao e' preta (%s)" % str(cc))

	# 6) cache: a MESMA textura para todos os tipos (1 imagem, nao 9)
	if SH.texture() != tex:
		_bad("texture() recriou a imagem (deveria cachear)")

	if fails == 0:
		print("MOB_SHADOW_TEST_OK")
	else:
		print("MOB_SHADOW_TEST_FAIL %d" % fails)
	quit()

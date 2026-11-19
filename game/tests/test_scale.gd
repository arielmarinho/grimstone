extends SceneTree
## test_scale.gd — valida a escala por classe (v0.6.37) SEM abrir o jogo.
## Confere, para cada arma: (1) a altura do corpo NA TELA (altura_da_arte x
## escala) fica igual a do knight; (2) os PES caem na mesma linha do knight
## (offset aplicado) — crescer em torno do centro da celula afundaria o
## personagem no chao.
## Roda: godot --headless --path . --script res://tests/test_scale.gd

func _init() -> void:
	var ok := true
	var alvo_h: float = Equips.KNIGHT_BODY_H * Equips.KNIGHT_SPRITE_SCALE
	var alvo_pes: float = Equips.KNIGHT_FEET_SCREEN
	print("--- escala/offset por classe (alvo: altura %.1fpx, pes %.1fpx abaixo do centro)" % [alvo_h, alvo_pes])
	var armas := ["sword", "axe", "bow", "spear", "staff", "druid_staff"]
	for w in armas:
		var sc: float = Equips.sprite_scale_for(w)
		var off: float = Equips.sprite_offset_y_for(w)
		var cls: String = Equips.class_dir_for(w)
		var h_arte: float = Equips.KNIGHT_BODY_H
		var pes_arte: float = Equips.KNIGHT_FEET_SCREEN / Equips.KNIGHT_SPRITE_SCALE
		if Equips.CLASS_GEOM.has(cls):
			h_arte = float(Equips.CLASS_GEOM[cls]["h"])
			pes_arte = float(Equips.CLASS_GEOM[cls]["feet"])
		var h_tela: float = h_arte * sc
		var pes_tela: float = (pes_arte + off) * sc
		print("  %-12s %-8s scale=%.3f  altura=%.1f  pes=%.1f  offset_tx=%+.2f" % [w, cls, sc, h_tela, pes_tela, off])
		if absf(h_tela - alvo_h) > 1.0:
			print("  FALHOU: altura fora da faixa em ", w)
			ok = false
		if absf(pes_tela - alvo_pes) > 1.0:
			print("  FALHOU: pes fora do chao em ", w)
			ok = false
	# arma desconhecida nao pode quebrar (nem offset maluco)
	if absf(Equips.sprite_scale_for("foice") - 1.15) > 0.001 or absf(Equips.sprite_offset_y_for("foice")) > 0.001:
		print("  FALHOU: arma desconhecida deveria usar a escala/offset do knight")
		ok = false
	print("SCALE_TEST_OK" if ok else "SCALE_TEST_FAIL")
	quit(0 if ok else 1)

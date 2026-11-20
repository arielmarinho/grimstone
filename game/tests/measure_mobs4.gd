extends SceneTree
## measure_mobs4.gd — o PERFIL LATERAL cai no lugar certo? (Area 39)
## Roda: `godot --headless --path . -s tests/measure_mobs4.gd`
##
## Tres coisas que quebram a leitura do sprite em jogo:
##   feet_y   — base do bbox. Se o side termina mais alto/baixo que o down, o
##              monstro "pula" ou afunda no chao quando vira na horizontal.
##   bbox_cx  — centro do bbox. O sprite gira em torno do CENTRO DA CELULA
##              (flip_h pro lado esquerdo); se o perfil nao estiver centrado, o
##              monstro salta lateralmente ao trocar de direcao.
##   overflow — bbox saindo da celula 96x96 (corte de membro/arma).

const MS := preload("res://scripts/entities/mob_sprites.gd")
const CELL := 96
const TYPES := ["rat", "slime", "bat", "spider", "wolf", "goblin", "orc", "skeleton"]
const ANIMS := [["idle", false, false, false], ["walk", false, false, true], ["attack", true, false, false]]


func _mk(t: String, f: int, atk: bool, death: bool, walk: bool, d: String) -> Image:
	var im := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	im.fill(Color(0, 0, 0, 0))
	MS.draw_mob(im, t, f, atk, death, walk, d)
	return im


func _run() -> void:
	for t in TYPES:
		for a in ANIMS:
			var aname: String = a[0]
			for d in ["down", "side"]:
				var feet := []
				var cxs := []
				var over := 0
				for f in range(4):
					var im := _mk(t, f, a[1], a[2], a[3], d)
					var bb := im.get_used_rect()
					feet.append(bb.position.y + bb.size.y)
					cxs.append(float(bb.position.x) + float(bb.size.x) * 0.5)
					if bb.position.x <= 0 or bb.position.y <= 0 or bb.position.x + bb.size.x >= CELL or bb.position.y + bb.size.y >= CELL:
						over += 1
				var flo := 1e9
				var fhi := -1e9
				var clo := 1e9
				var chi := -1e9
				for i in range(4):
					flo = minf(flo, float(feet[i]))
					fhi = maxf(fhi, float(feet[i]))
					clo = minf(clo, float(cxs[i]))
					chi = maxf(chi, float(cxs[i]))
				print("MOB4|%s|%s|%s|feet=%s|feet_var=%d|cx=%.1f..%.1f|cx_off=%.1f|overflow=%d" %
					[t, aname, d, str(feet), int(fhi - flo), clo, chi, absf((clo + chi) * 0.5 - 48.0), over])
	print("MEASURE_MOBS4_DONE")


func _initialize() -> void:
	_run()
	quit()

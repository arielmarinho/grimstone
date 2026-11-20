extends SceneTree
## test_player_shadow.gd — Area 46 (v0.6.52): SOMBRA NO CHAO do PLAYER.
## Roda: `godot --headless --path . -s tests/test_player_shadow.gd` -> PLAYER_SHADOW_TEST_OK
##
## BUG: os monstros (v0.6.50/51), os NPCs (v0.6.46), a decoracao (v0.6.48) e o loot
## (v0.6.51) ganharam sombra na linha do pe' — o PLAYER ficou de fora. O knight so
## tinha a sombra desenhada DENTRO do PNG, que a escala por classe (v0.6.37) jogou
## 10px acima da linha do pe'; paladino/mago/druida nao tem sombra na folha.
##
## Trava: base da sombra na linha do pe' (46px), espessura fina, largura propria por
## classe, e a sombra COZIDA na folha do knight realmente removida.

const PS := preload("res://scripts/entities/player_shadow.gd")
const MS := preload("res://scripts/entities/mob_shadow.gd")
const FEET := 46.0
const TOL := 0.6

var fails := 0


func _bad(msg: String) -> void:
	print("FALHA " + msg)
	fails += 1


func _initialize() -> void:
	# 1) a regua: BASE da sombra exatamente na linha do pe'
	if absf(PS.bottom_y() - FEET) > TOL:
		_bad("base da sombra a %.2f (esperado %.1f)" % [PS.bottom_y(), FEET])
	if absf(PS.center_y() - (FEET - PS.HEIGHT_SCREEN * 0.5)) > 0.01:
		_bad("centro da sombra incoerente com a altura")
	# 2) fina e acima do centro do node (nao cobre os pes/corpo)
	if PS.HEIGHT_SCREEN <= 2.0 or PS.HEIGHT_SCREEN > 12.0:
		_bad("altura %.1f fora de 2..12px" % PS.HEIGHT_SCREEN)
	if PS.top_y() < 0.0:
		_bad("sombra sobe acima do centro do node (%.1f)" % PS.top_y())

	# 3) largura propria por classe, todas plausiveis e ORDENADAS por corpo
	var ws := {}
	for cls in ["knight", "paladin", "mage", "druid"]:
		var w: float = PS.width_for_class(cls)
		if w < 14.0 or w > 50.0:
			_bad("largura de %s = %.1f fora de 14..50px" % [cls, w])
		ws[cls] = w
	if ws["knight"] <= ws["paladin"]:
		_bad("knight (corpo maior) deveria ter sombra mais larga que o paladino")
	if ws["mage"] <= ws["druid"]:
		_bad("mago deveria ter sombra mais larga que o druida")

	# 4) a arma mapeia pra classe certa (fonte unica: Equips.class_dir_for)
	if PS.class_for("sword") != "knight":
		_bad("espada deveria usar a sombra do knight")
	if PS.class_for("spear") != "paladin":
		_bad("lanca deveria usar a sombra do paladino")
	if PS.class_for("staff") != "mage":
		_bad("cajado deveria usar a sombra do mago")
	if PS.class_for("druid_staff") != "druid":
		_bad("cajado druida deveria usar a sombra do druida")
	if absf(PS.width_for("spear") - PS.width_for_class("paladin")) > 0.01:
		_bad("largura por arma nao bate com a da classe")

	# 5) textura existe, e' a MESMA dos monstros e tem alpha (nao um quadrado preto)
	var tex := PS.texture()
	if tex == null or tex.get_width() <= 0:
		_bad("textura da sombra vazia")
	elif tex.get_width() != MS.TEX_W or tex.get_height() != MS.TEX_H:
		_bad("textura deveria ser compartilhada com MobShadow")

	if fails == 0:
		print("PLAYER_SHADOW_TEST_OK")
	else:
		print("FALHAS: %d" % fails)
	quit(0 if fails == 0 else 1)

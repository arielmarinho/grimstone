extends SceneTree
## measure_decor.gd — Area 43: onde a DECORACAO (postes, barris, caixotes, bandeiras,
## barraca, canteiro) apoia o pe' em relacao a linha do chao do player.
## Roda: godot --headless --path . -s tests/measure_decor.gd
## Regua: KNIGHT_FEET_SCREEN = 46px abaixo do centro do node (Equips).
## No decor o Sprite2D e' centrado na posicao do node com scale 2.0 e SEM offset,
## entao: pe_tela = (base_arte + 0.5 - altura/2) * scale.

const DECOR := preload("res://scripts/world/decor.gd")
const KNIGHT_FEET := 46.0
const SCALE := 2.0

const KINDS := ["LAMP", "FLOWERS", "BARREL", "CRATE", "FLAG", "STALL"]


func _tex(kind: int) -> ImageTexture:
	match kind:
		DECOR.LAMP: return DECOR._tex_lamp()
		DECOR.FLOWERS: return DECOR._tex_flowers()
		DECOR.BARREL: return DECOR._tex_barrel()
		DECOR.CRATE: return DECOR._tex_crate()
		DECOR.FLAG: return DECOR._tex_flag()
	return DECOR._tex_stall()


func _base(img: Image) -> int:
	var m := -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.5:
				m = maxi(m, y)
	return m


func _top(img: Image) -> int:
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.5:
				return y
	return 0


func _initialize() -> void:
	for i in range(KINDS.size()):
		var tex := _tex(i)
		var img := tex.get_image()
		img.convert(Image.FORMAT_RGBA8)
		var base := _base(img)
		var top := _top(img)
		var h := img.get_height()
		var feet: float = (float(base) + 1.0 - float(h) * 0.5) * SCALE
		var h_screen: float = float(base - top + 1) * SCALE
		print("DECOR|%s|tex=%dx%d|base=%d|top=%d|pe_tela=%.1f|desvio=%+.1f|altura=%.0f" % [
			KINDS[i], img.get_width(), h, base, top, feet, feet - KNIGHT_FEET, h_screen])
	quit()

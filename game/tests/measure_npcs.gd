extends SceneTree
## measure_npcs.gd — LINHA DO CHAO: todo sprite (player, monstros, NPCs) tem que
## apoiar o PE na MESMA linha da tela que o knight do jogo.
## Roda: `godot --headless --path . -s tests/measure_npcs.gd`
##
## Regua (a mesma do Equips.sprite_offset_y_for):
##   AnimatedSprite2D centrado na celula 96, entao um pixel da arte em y aparece na
##   tela em (y - 48 + offset) * scale. A linha dos pes do knight no jogo e'
##   KNIGHT_FEET_SCREEN = 46px abaixo do centro.
##   => offset necessario = 46/scale - (pe_arte - 48)
## Sombra (alpha 0.25-0.35) nao conta como pe: limiar de alpha 0.9.

const CELL := 96
const MS := preload("res://scripts/entities/mob_sprites.gd")
const TH := preload("res://scripts/autoload/tex_helper.gd")
const NA := preload("res://scripts/world/npc_art.gd")
const TARGET := 46.0  # KNIGHT_FEET_SCREEN

const TYPES := ["rat", "slime", "bat", "spider", "wolf", "goblin", "orc", "skeleton", "dummy"]


func _bottom_edge(img: Image) -> float:
	var m := -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.9:
				m = maxi(m, y)
				break
	return float(m + 1)


func _mob(t: String, f: int, d: String, walk: bool, atk: bool) -> Image:
	var im := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	im.fill(Color(0, 0, 0, 0))
	MS.draw_mob(im, t, f, atk, false, walk, d)
	return im


func _run() -> void:
	print("LINE|knight_feet_screen_alvo=%.1f" % TARGET)

	# knight procedural (fallback sem PNG): qual pe' ele produz?
	var k := Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
	k.fill(Color(0, 0, 0, 0))
	TH._draw_knight(k, 0, false, false, false, "sword", "castanho", "castanho", "down")
	var kf := _bottom_edge(k)
	print("LINE|knight_proc|pe_arte=%.0f|scale=1.15|pe_tela=%.1f|desvio=%.1f" % [
		kf, (kf - 48) * 1.15, (kf - 48) * 1.15 - TARGET])

	# monstros: pe' do quadro 0 de idle/parede + pior caso de walk, em down e side
	for t in TYPES:
		var small: bool = t in ["rat", "slime", "bat"]
		var sc := 1.4 if small else 1.15
		var feet := 0.0
		for d in ["down", "side", "up"]:
			feet = maxf(feet, _bottom_edge(_mob(t, 0, d, false, false)))
			for f in range(4):
				feet = maxf(feet, _bottom_edge(_mob(t, f, d, true, false)))
		# usa o MENOR pe' (idle down) como ancora, e o pior caso vira a folga
		var idle := _bottom_edge(_mob(t, 0, "down", false, false))
		var off: float = TARGET / sc - (idle - 48.0)
		print("LINE|mob_%s|pe_arte=%.0f|pior=%.0f|scale=%.2f|pe_tela=%.1f|desvio=%.1f|offset_sugerido=%.2f" % [
			t, idle, feet, sc, (idle - 48) * sc, (idle - 48) * sc - TARGET, off])

	for nm in [["npc_quest", NA.quest_image()], ["npc_bank", NA.bank_image()]]:
		var img: Image = nm[1]
		var idle := _bottom_edge(img)
		print("LINE|%s|pe_arte=%.0f|h_arte=%.0f" % [nm[0], idle, _top(img)])
		for sc in [2.0, 1.15]:
			var off: float = TARGET / sc - (idle - 48.0)
			print("LINE|%s|scale=%.2f|pe_tela=%.1f|desvio=%.1f|offset_sugerido=%.2f" % [
				nm[0], sc, (idle - 48) * sc, (idle - 48) * sc - TARGET, off])

	print("MEASURE_NPCS_DONE")
	quit()


func _top(img: Image) -> float:
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.9:
				return float(y)
	return 0.0


func _initialize() -> void:
	_run()

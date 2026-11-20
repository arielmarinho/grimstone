extends Object
## mob_bar.gd — POSICAO DA BARRA DE VIDA do monstro, derivada da ARTE (Area 43, v0.6.49)
##
## O BUG (medido, tests/measure_bar.gd): a barra de HP e' um ProgressBar filho de
## cada mob com offset FIXO no .tscn (-44 .. -38). Ate a v0.6.48 isso "funcionava"
## por acidente, porque TODO sprite era desenhado com o mesmo topo aparente. Com o
## offset de pe' por tipo (v0.6.48) cada corpo passou a terminar num y diferente:
## medido em px de tela contra o topo real da arte —
##   slime/morcego/aranha  -50 px (barra 50px ACIMA da cabeca, boiando no vazio)
##   rato                   -7.5 px (colada no corpo)
##   orc                   -14.7 px
## Ou seja: um numero magico no .tscn que nao conhece nem a arte nem a escala.
##
## REGRA (a mesma do player/mobs/NPCs/decor): o node do mob e' o CENTRO da celula
## 96 (y=48). Um pixel de arte em y aparece na tela em (y - 48 + offset) * scale.
## A barra fica GAP px acima do pixel mais alto do corpo.
##
## Modulo PURO (sem autoload/cena) para poder ser medido e testado headless —
## mesmo padrao de walk_cycle.gd, frame_align.gd e npc_art.gd.

const CELL_CENTER := 48.0
const BAR_H := 6.0      # altura da barra em px de tela (era 6 no .tscn)
const BAR_W := 40.0     # largura (era 40 no .tscn)
const GAP := 6.0        # folga entre o topo da cabeca e a barra

## Topo do corpo em px de TELA (negativo = acima do centro do node).
static func head_top_screen(top_art: float, feet_offset: float, scale: float) -> float:
	return (top_art - CELL_CENTER + feet_offset) * scale

## y (offset do Control, relativo ao node) do TOPO da barra de vida.
static func bar_top(top_art: float, feet_offset: float, scale: float) -> float:
	return head_top_screen(top_art, feet_offset, scale) - GAP - BAR_H

## Mede o pixel mais alto (alpha >= 0.9) de uma textura de quadro.
static func head_top_of(img: Image) -> float:
	if img == null:
		return -1.0
	img.convert(Image.FORMAT_RGBA8)
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a >= 0.9:
				return float(y)
	return -1.0

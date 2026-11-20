extends Object
## ground_item.gd — POSICAO NO CHAO dos itens dropados e das moedas (Area 45, v0.6.51)
##
## O BUG (medido): `drop.gd` cria um Sprite2D CENTRADO na posicao do node, e o node
## nasce em `mob.global_position` (CENTRO da celula do monstro). Pela regua unica do projeto o pe' fica
## `KNIGHT_FEET_SCREEN = 46px` abaixo desse centro — logo o item pousava com a base
## 36px ACIMA do chao (icone de 20px: base em +10px) e parecia flutuar no ar onde o
## monstro estava, enquanto o corpo do monstro (v0.6.48) e do player estavam no chao.
##
## Modulo PURO (sem autoload, sem cena), mesmo padrao de mob_bar.gd / mob_shadow.gd /
## npc_art.gd / walk_cycle.gd / frame_align.gd: pode ser medido e testado headless.

## A regua unica do projeto (Equips.KNIGHT_FEET_SCREEN, NpcArt, Decor, MobShadow).
const FEET_SCREEN := 46.0

## Altura em que o item "paira" acima do chao quando o tween de queda termina.
const BOB_UP := 3.0


## Deslocamento (px de tela, relativo ao centro do node) que poe a BASE do icone
## exatamente na linha do chao. `h` = altura do icone em px.
## Um Sprite2D centrado desenha de -h/2 a +h/2; para a base ir a FEET_SCREEN o
## centro tem de ir a FEET_SCREEN - h/2.
static func base_offset(h: float) -> float:
	return FEET_SCREEN - h * 0.5


## Centro da AURA de raridade (fica no chao, sob o item, nao sob o centro do icone).
static func aura_center_y() -> float:
	return FEET_SCREEN - 2.0


## y do pico do pulinho (tween): sobe BOB_UP acima da base assentada.
static func bob_peak(h: float) -> float:
	return base_offset(h) - BOB_UP


## Maior desvio aceitavel entre a base do item e a linha do chao.
const TOL := 0.5

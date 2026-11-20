class_name MobShadow
extends Object
## mob_shadow.gd — SOMBRA NO CHAO dos monstros, derivada da mesma regua do resto (Area 44, v0.6.50)
##
## O BUG (medido, tests/measure_mob_shadow.gd): o projeto tem UMA regua de pe'
## (`KNIGHT_FEET_SCREEN = 46px` abaixo do centro do node) usada pelo player, pelos
## monstros (v0.6.48), pelos NPCs (v0.6.46) e pela decoracao (v0.6.48) — e o PLAYER e
## os NPCs desenham uma sombra eliptica apoiada nessa linha. Os monstros NAO tinham
## sombra nenhuma: os 9 tipos ficavam "colados" no tileset sem contato visual com o
## chao, enquanto o knight ao lado tinha sombra. Resultado: bicho parecia flutuar.
##
## Modulo PURO (sem autoload, sem cena) para poder ser medido e testado headless —
## mesmo padrao de mob_bar.gd, npc_art.gd, walk_cycle.gd e frame_align.gd.

const CELL := 96
## A regua unica do projeto (Equips.KNIGHT_FEET_SCREEN, NpcArt.KNIGHT_FEET_SCREEN,
## Decor.KNIGHT_FEET_SCREEN): pe' a 46px de tela abaixo do centro do node.
const FEET_SCREEN := 46.0

## Textura da sombra (px de TEXTE da sombra, que e' desenhada em escala propria).
const TEX_W := 64
const TEX_H := 20
## Alpha maximo no centro. O player usa 0.25 e os NPCs 0.25 -> mesma familia visual.
const ALPHA := 0.25

## Largura da sombra por tipo, em px de TELA. Corpo pequeno -> sombra pequena.
## (medido: largura util do corpo na arte, x escala do sprite em mob.gd)
const WIDTH := {
	"rat": 26.0, "slime": 30.0, "bat": 22.0, "spider": 34.0,
	"wolf": 38.0, "goblin": 28.0, "orc": 34.0, "skeleton": 30.0,
	"dummy": 26.0,
}

static var _cache: ImageTexture = null


## Altura da sombra na tela (px). Fina de proposito: e' contato com o chao, nao um buraco.
static func height_screen() -> float:
	return 7.0


## y de TELA (relativo ao centro do node) do CENTRO da sombra.
## Fica na propria linha do pe': a sombra nasce embaixo do corpo, nao embaixo dele + folga.
static func center_y() -> float:
	return FEET_SCREEN - height_screen() * 0.5


## Topo e base da sombra em px de tela — usado pelos testes para travar a regua.
static func top_y() -> float:
	return center_y() - height_screen() * 0.5


static func bottom_y() -> float:
	return center_y() + height_screen() * 0.5


static func width_for(mob_type: String) -> float:
	return float(WIDTH.get(mob_type, 28.0))


## Textura unica (elipse suave, preta com alfa), criada uma vez e compartilhada
## por todos os mobs — 1 textura de 64x20 na memoria, nao uma por bicho.
static func texture() -> ImageTexture:
	if _cache != null:
		return _cache
	var img := Image.create(TEX_W, TEX_H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var cx := float(TEX_W) * 0.5
	var cy := float(TEX_H) * 0.5
	var rx := float(TEX_W) * 0.5
	var ry := float(TEX_H) * 0.5
	for y in range(TEX_H):
		for x in range(TEX_W):
			var dx := (float(x) + 0.5 - cx) / rx
			var dy := (float(y) + 0.5 - cy) / ry
			var d := dx * dx + dy * dy
			if d >= 1.0:
				continue
			# queda suave do centro para a borda (d=0 -> ALPHA, d=1 -> 0)
			var a: float = ALPHA * (1.0 - d) * (1.0 - d)
			if a > 0.004:
				img.set_pixel(x, y, Color(0.0, 0.0, 0.0, a))
	_cache = ImageTexture.create_from_image(img)
	return _cache

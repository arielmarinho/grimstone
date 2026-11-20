class_name PlayerShadow
extends Object
## player_shadow.gd — SOMBRA NO CHAO do PLAYER (Area 46, v0.6.52)
##
## O BUG (medido, scripts/81724fd159dae26a/measure_player_shadow.py): depois das
## Areas 42-45 todo mundo tinha contato visual com o chao — os 9 monstros
## (v0.6.50/51), os NPCs (v0.6.46), a decoracao (v0.6.48) e ate os itens dropados
## (v0.6.51) — MENOS o personagem do jogador. O knight tinha SOMENTE a sombra
## desenhada DENTRO do PNG antigo dele; as 3 classes novas (paladino/mago/druida,
## arte do usuario, v0.6.34) nao tem sombra nenhuma na folha. Resultado: com a
## arma de paladino/mago/druida o personagem flutuava sobre o tileset enquanto
## o monstro do lado tinha sombra.
##
## Varredura nas 4 folhas (idle/walk/attack, 3 direcoes): as linhas ABAIXO do pe'
## estao 100% vazias em todas — o knight nao tem nem a sombra desenhada na celula
## (o que parece "sombra" na folha sao pixels de antialias DENTRO do corpo).
## Ou seja: nenhuma classe tinha sombra no chao, nem por arte nem por node.
##
## Modulo PURO (sem autoload, sem cena) — mesmo padrao de mob_shadow.gd, mob_bar.gd,
## npc_art.gd, walk_cycle.gd e frame_align.gd: medivel e testavel headless.

## LICAO (ciclo 14): class_name NAO resolve no import frio do headless. Preloads
## explicitos aqui, nunca o nome da classe nem o autoload pelo nome.
const MOBSHADOW = preload("res://scripts/entities/mob_shadow.gd")
const EQUIPS = preload("res://scripts/autoload/equips.gd")

## A regua unica do projeto: pe' a 46px de tela abaixo do centro do node
## (Equips.KNIGHT_FEET_SCREEN, MobShadow.FEET_SCREEN, NpcArt, Decor).
const FEET_SCREEN := 46.0

## Altura na tela (px). Fina de proposito: e' contato com o chao, nao um buraco.
const HEIGHT_SCREEN := 7.0

## Largura por CLASSE, em px de TELA. Medida na arte real (mediana das larguras
## do corpo nas 6 linhas acima do pe', quadros idle/walk/attack das 3 direcoes,
## ja multiplicada pela escala da classe): knight 36.8, paladino 24.7,
## mago 33.9, druida 21.6. Corpo pequeno -> sombra pequena (mesma regra dos mobs).
const WIDTH := {
	"knight": 37.0,
	"paladin": 25.0,
	"mage": 34.0,
	"druid": 22.0,
}


## Classe de sprite que a arma equipada usa ("knight" quando nao e das novas).
static func class_for(weapon_base: String) -> String:
	return EQUIPS.class_dir_for(weapon_base)


static func width_for_class(cls: String) -> float:
	return float(WIDTH.get(cls, WIDTH["knight"]))


static func width_for(weapon_base: String) -> float:
	return width_for_class(class_for(weapon_base))


## y de TELA (relativo ao centro do node) do CENTRO da sombra: a BASE da sombra
## fica exatamente na linha do pe'.
static func center_y() -> float:
	return FEET_SCREEN - HEIGHT_SCREEN * 0.5


static func top_y() -> float:
	return center_y() - HEIGHT_SCREEN * 0.5


static func bottom_y() -> float:
	return center_y() + HEIGHT_SCREEN * 0.5


## A elipse e' a MESMA textura dos monstros (64x20 cacheada, compartilhada por
## todos os mobs) — 1 textura na memoria do jogo inteiro, nao uma por bicho.
static func texture() -> ImageTexture:
	return MOBSHADOW.texture()


## Cria (ou reposiciona) a sombra como filha do node do player/avatar remoto.
## Chamado de _build_frames(), que e' refeito a cada troca de arma/classe.
static func attach(parent: Node, weapon_base: String) -> Sprite2D:
	if parent == null:
		return null
	var sh: Sprite2D = parent.get_node_or_null("GroundShadow") as Sprite2D
	if sh == null:
		sh = Sprite2D.new()
		sh.name = "GroundShadow"
		sh.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		parent.add_child(sh)
		parent.move_child(sh, 0)
	sh.texture = texture()
	sh.scale = Vector2(width_for(weapon_base) / float(MOBSHADOW.TEX_W),
		HEIGHT_SCREEN / float(MOBSHADOW.TEX_H))
	sh.position = Vector2(0.0, center_y())
	sh.z_index = -1
	return sh

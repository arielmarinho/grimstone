extends Control
## Minimapa (v0.6.40) — canto superior direito, estilo Rucoy/Tibia.
## Desenha a textura do mapa ATUAL reduzida (a MESMA textura que o main.gd ja
## carregou, custo zero de memoria) + pontos: voce (verde), estrutura/NPC
## (amarelo), monstros (vermelho) e saidas (azul). Tecla M alterna entre
## pequeno (156px) e grande (288px).
## Nunca toca em arquivo nem gera imagem: so desenha o que ja existe.

const SMALL := 156.0
const BIG := 288.0
const MARGIN := 16.0
const VIEW_W := 1280.0

var map_tex: Texture2D = null
var world_size: Vector2 = Vector2(2048.0, 2048.0)
var player_ref: Node = null
var exits: Array = []
var big: bool = false
var _acc: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_rect()

func _update_rect() -> void:
	var s: float = BIG if big else SMALL
	size = Vector2(s, s)
	position = Vector2(VIEW_W - s - MARGIN, MARGIN)

## Chamado pelo main.gd a cada troca de mapa.
func set_map(tex: Texture2D, world: Vector2, exit_list: Array) -> void:
	map_tex = tex
	world_size = world
	if world_size.x <= 1.0 or world_size.y <= 1.0:
		world_size = Vector2(2048.0, 2048.0)
	exits = exit_list
	queue_redraw()

func set_player(p: Node) -> void:
	player_ref = p

func toggle_size() -> void:
	big = not big
	_update_rect()
	queue_redraw()

func _process(delta: float) -> void:
	# redesenho a 10Hz: suficiente pro movimento e barato (nada de 60Hz)
	_acc += delta
	if _acc < 0.1:
		return
	_acc = 0.0
	queue_redraw()

func _to_map(p: Vector2) -> Vector2:
	return Vector2(p.x / world_size.x * size.x, p.y / world_size.y * size.y)

func _dot(ctrl_pos: Vector2, col: Color, radius: float) -> void:
	draw_circle(ctrl_pos, radius + 1.5, Color(0, 0, 0, 0.85))
	draw_circle(ctrl_pos, radius, col)

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	# fundo/borda
	draw_rect(Rect2(r.position - Vector2(3, 3), r.size + Vector2(6, 6)), Color(0, 0, 0, 0.55))
	if map_tex != null:
		draw_texture_rect(map_tex, r, false, Color(1, 1, 1, 0.92))
	else:
		draw_rect(r, Color(0.1, 0.1, 0.12, 0.9))
	# saidas (azul, pulsa)
	if exits.size() > 0:
		for ex in exits:
			var ep: Vector2 = _to_map(ex.get("pos", Vector2.ZERO))
			if r.has_point(ep):
				_dot(ep, Color(0.35, 0.65, 1.0, 0.95), 4.0 if big else 2.5)
	# NPCs / estruturas (amarelo)
	for g in ["quest_npc", "npc_panel"]:
		for n in get_tree().get_nodes_in_group(g):
			if is_instance_valid(n) and n is Node2D:
				var np: Vector2 = _to_map(n.global_position)
				if r.has_point(np):
					_dot(np, Color(1.0, 0.85, 0.3, 0.95), 3.0 if big else 2.0)
	# monstros (vermelho)
	for m in get_tree().get_nodes_in_group("mobs"):
		if is_instance_valid(m) and m is Node2D:
			var mp: Vector2 = _to_map(m.global_position)
			if r.has_point(mp):
				var dead: bool = m.get("hp") != null and int(m.get("hp")) <= 0
				if not dead:
					_dot(mp, Color(1.0, 0.3, 0.25, 0.95), 2.5 if big else 1.8)
	# voce (verde, com anel branco)
	if player_ref != null and is_instance_valid(player_ref):
		var pp: Vector2 = _to_map(player_ref.global_position)
		if r.has_point(pp):
			var pr: float = 4.0 if big else 3.0
			draw_circle(pp, pr + 3.0, Color(0, 0, 0, 0.9))
			draw_circle(pp, pr + 1.6, Color(1, 1, 1, 0.95))
			draw_circle(pp, pr, Color(0.35, 1.0, 0.45))
	# borda dourada por cima
	draw_rect(r, Color(0.95, 0.8, 0.3, 0.9), false, 2.0)
	# titulo do modo
	var f := get_theme_default_font()
	if f != null:
		draw_string(f, Vector2(6, size.y - 6), "MAPA [M]", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1, 1, 1, 0.75))

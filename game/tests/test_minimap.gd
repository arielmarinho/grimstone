extends SceneTree
## test_minimap.gd (v0.6.40) — regressao do MINIMAPA (modulo puro de desenho).
## O que o jogador ve depende de duas coisas faceis de quebrar:
##  1. a conversao mundo -> mapa (se erra a escala, o ponto do player sai do lugar)
##  2. o tamanho/posicao do painel (se estoura a tela no modo grande)
## Nao desenha nada: instancia o script e mede a matematica.

const MM = preload("res://scripts/ui/minimap.gd")

func _init() -> void:
	var fails := 0
	var m = MM.new()

	# escala: mundo 2048 -> mapa 156 (modo pequeno)
	m.world_size = Vector2(2048, 2048)
	m.big = false
	m._update_rect()
	var p0: Vector2 = m._to_map(Vector2.ZERO)
	var pc: Vector2 = m._to_map(Vector2(1024, 1024))
	var pf: Vector2 = m._to_map(Vector2(2048, 2048))
	if not p0.is_equal_approx(Vector2.ZERO):
		print("FALHOU: canto 0,0 virou %s" % p0); fails += 1
	if not pc.is_equal_approx(Vector2(78, 78)):
		print("FALHOU: centro do mundo virou %s (esperado 78,78)" % pc); fails += 1
	if not pf.is_equal_approx(m.size):
		print("FALHOU: canto final %s != tamanho %s" % [pf, m.size]); fails += 1

	# modo grande dobra o painel e continua dentro de 1280px de tela
	m.toggle_size()
	if not m.big:
		print("FALHOU: toggle_size nao ligou o modo grande"); fails += 1
	if m.size.x < 200.0:
		print("FALHOU: modo grande pequeno demais (%s)" % m.size); fails += 1
	if m.position.x + m.size.x > 1280.0:
		print("FALHOU: minimapa grande sai da tela (x=%s w=%s)" % [m.position.x, m.size.x]); fails += 1
	if m.position.y < 0.0:
		print("FALHOU: minimapa acima da tela"); fails += 1

	# mundo com tamanho invalido nao pode dividir por zero
	m.set_map(null, Vector2.ZERO, [])
	if m.world_size.x <= 1.0:
		print("FALHOU: world_size invalido nao foi corrigido (%s)" % m.world_size); fails += 1

	# saidas guardadas pra desenhar
	m.set_map(null, Vector2(2048, 2048), [{"pos": Vector2(1024, 1750)}])
	if m.exits.size() != 1:
		print("FALHOU: saidas nao chegaram ao minimapa"); fails += 1

	m.free()
	if fails == 0:
		print("MINIMAP_TEST_OK")
	else:
		print("MINIMAP_TEST_FAIL (%d)" % fails)
	quit()

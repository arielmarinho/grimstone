extends Node
## FX — numeros flutuantes de texto (v0.6.38): recompensa (XP, moedas, cura, mana,
## skill up) E dados de combate (dano no mob, critico, dano no player).
## 100% procedural, zero assets; autoload conectado aos sinais do GameManager.

func _ready() -> void:
	if GameManager != null:
		GameManager.xp_gained.connect(_on_xp_gained)
		GameManager.coins_gained.connect(_on_coins_gained)
		GameManager.healed.connect(_on_healed)
		GameManager.mana_gained.connect(_on_mana_gained)
		GameManager.skill_up_event.connect(_on_skill_up)

func _player_pos() -> Vector2:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty() or not is_instance_valid(players[0]):
		return Vector2.ZERO
	return players[0].global_position

func float_text(pos: Vector2, text: String, color: Color, size: int = 14, rise: float = 30.0) -> Label:
	var parent := get_tree().current_scene
	if parent == null:
		return null
	var l = Label.new()
	l.text = text
	l.position = pos + Vector2(-30, -55 + randf() * 10.0 - 5.0)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 4)
	l.z_index = 50
	# escala a partir do centro do texto, nao do canto
	l.pivot_offset = Vector2(0, size)
	parent.add_child(l)
	var tw = l.create_tween()
	tw.tween_property(l, "position:y", l.position.y - rise, 0.8)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.8)
	tw.tween_callback(l.queue_free)
	return l

## NUMERO DE DANO — fonte unica (v0.6.38). Antes cada arquivo tinha a sua copia
## (mob.gd _spawn_damage_number, player.gd/projectile.gd _spawn_crit_text) e o
## caminho ONLINE nao mostrava numero nenhum: o mob no cliente e espelho e quem
## aplica o dano e o servidor. Agora todos chamam aqui.
## kind: "mob" (normal), "crit" (dourado grande), "hurt" (vermelho, dano no player).
func damage_number(pos: Vector2, amount: int, crit: bool = false, kind: String = "mob") -> void:
	if amount <= 0:
		return
	var txt := str(amount)
	var col := Color(1.0, 0.95, 0.75)
	var size := 15
	var rise := 28.0
	if crit or kind == "crit":
		txt = "%d!" % amount
		col = Color(1.0, 0.72, 0.15)
		size = 19
		rise = 34.0
	elif kind == "hurt":
		col = Color(1.0, 0.35, 0.3)
		size = 16
	var l := float_text(pos + Vector2(0, -8), txt, col, size, rise)
	# "pop": o numero nasce maior e assenta rapido (peso do golpe)
	if l != null and is_instance_valid(l):
		l.scale = Vector2(1.45, 1.45)
		var tw = l.create_tween()
		tw.tween_property(l, "scale", Vector2.ONE, 0.12)

func _on_xp_gained(amount: int) -> void:
	var p := _player_pos()
	if p != Vector2.ZERO:
		float_text(p, "+%d XP" % amount, Color(0.55, 0.9, 1.0))

func _on_coins_gained(amount: int) -> void:
	var p := _player_pos()
	if p != Vector2.ZERO:
		float_text(p, "+%d" % amount, Color(1.0, 0.85, 0.25))

## chamado DIRETO por coin.gd/drop.gd no pickup (moeda nao passa pelo sinal coins_gained)
func coin_gain(pos: Vector2, amount: int) -> void:
	float_text(pos, "+%d" % amount, Color(1.0, 0.85, 0.25))

func _on_healed(amount: int) -> void:
	var p := _player_pos()
	if p != Vector2.ZERO and amount > 0:
		float_text(p, "+%d" % amount, Color(0.4, 1.0, 0.45))

func _on_mana_gained(amount: int) -> void:
	var p := _player_pos()
	if p != Vector2.ZERO and amount > 0:
		float_text(p, "+%d" % amount, Color(0.5, 0.7, 1.0))

func _on_skill_up(skill: String, level: int) -> void:
	var p := _player_pos()
	if p != Vector2.ZERO:
		float_text(p, "%s UP! Nivel %d" % [skill.capitalize(), level], Color(1.0, 0.85, 0.25), 16)

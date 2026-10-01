extends CharacterBody2D
## Mob base — IA wander/aggro/attack, 4 direcoes, timers filhos, strip magenta
## Subclasses definem: tipo (sprite), stats, loot

const TEXHELPER = preload("res://scripts/autoload/tex_helper.gd")
const NETTARGET = preload("res://scripts/entities/net_target.gd")

const WANDER_RADIUS = 240.0
const AGGRO_RANGE = 280.0
const ATTACK_RANGE = 80.0
const WANDER_SPEED = 90.0
const CHASE_SPEED = 140.0

# tipo do monstro — muda sprite/stats/loot
var mob_type: String = "rat"

# stats por tipo (Tibia-style: progressao de dificuldade)
const TYPES = {
	"rat": {"hp": 40, "dano": 8, "xp": 35, "vel": 1.0},
	"slime": {"hp": 60, "dano": 10, "xp": 50, "vel": 0.7},
	"bat": {"hp": 30, "dano": 6, "xp": 40, "vel": 1.6},
	"spider": {"hp": 90, "dano": 12, "xp": 55, "vel": 1.2},
	"wolf": {"hp": 130, "dano": 13, "xp": 90, "vel": 1.4},
	"goblin": {"hp": 110, "dano": 12, "xp": 70, "vel": 1.3},
	"orc": {"hp": 200, "dano": 16, "xp": 150, "vel": 1.0},
	"skeleton": {"hp": 160, "dano": 14, "xp": 120, "vel": 1.1},
	"dummy": {"hp": 9999, "dano": 0, "xp": 0, "vel": 0.0},  # alvo de treino: nunca morre, nao revida
}

var max_hp: int = 40
var hp: int = 40
var damage: int = 8
var xp_reward: int = 20

var dead: bool = false
var dying: bool = false
var home: Vector2
var wander_target: Vector2
var state: String = "wander"
var attack_cooldown: float = 0.0
var respawn_time: float = 10.0
var facing: String = "down"
var stunned: float = 0.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hp_bar: ProgressBar = $HpBar

# ---------- MULTIPLAYER (mobs autoritativos) ----------
# offline/ servidor: IA local roda normal. Cliente: mob vira "NetMob" passivo.
var net_authority: bool = true  # false = sou espelho visual no cliente
var net_id: int = 0             # id do mob no servidor (quando espelho)
var _net_accum: float = 0.0
const NET_SEND_HZ := 10.0
var _net_map: String = ""      # mapa atual (preenchido pelo spawner no servidor)
var _net_target_pos: Vector2 = Vector2.ZERO
var _net_anim: String = "idle:down"
var _net_buf: Array = []       # buffer de snapshots [{t, p, a}] p/ interpolação c/ lag
const NET_BUF_MS := 120        # interpola ~120ms no passado (cobre jitter de rede)
var _last_hit_by: int = 0      # peer id do ultimo atacante (servidor, pra xp/loot)
var _net_target = null         # alvo virtual (servidor dedicado, sem player local)

func is_net_mirror() -> bool:
	return NetworkManager.is_online() and not NetworkManager.is_server

func _ready() -> void:
	add_to_group("mobs")
	_apply_type()
	home = global_position
	wander_target = global_position
	net_authority = not is_net_mirror()
	var atk := Timer.new()
	atk.one_shot = true
	atk.name = "AtkTimer"
	add_child(atk)
	atk.timeout.connect(_do_attack_hit)
	var rsp := Timer.new()
	rsp.one_shot = true
	rsp.name = "RespawnTimer"
	add_child(rsp)
	rsp.timeout.connect(_do_respawn)
	_build_frames()
	if net_authority and NetworkManager.is_server:
		NetworkManager.net_register_mob(self)
		tree_exiting.connect(_net_exit)
	else:
		# espelho: IA local desligada, estado vem do servidor
		NetworkManager.mob_state.connect(_on_net_state)
		NetworkManager.mob_removed.connect(_on_net_removed)

func _net_exit() -> void:
	NetworkManager.net_unregister_mob(self)

func _apply_type() -> void:
	var t = TYPES.get(mob_type, TYPES["rat"])
	max_hp = t["hp"] + randi() % 11 - 5
	hp = max_hp
	damage = t["dano"]
	xp_reward = t["xp"]

# ANIMS com paths up/side REAIS — o procedural desenha cada direcao do mob
const ANIMS = {
	"idle_down": "res://assets/sprites/animation/enemy/rat/idle/down/rat_idle_down.png",
	"idle_up": "res://assets/sprites/animation/enemy/rat/idle/up/rat_idle_up.png",
	"idle_side": "res://assets/sprites/animation/enemy/rat/idle/side/rat_idle_side.png",
	"walk_down": "res://assets/sprites/animation/enemy/rat/walk/down/rat_walk_down.png",
	"walk_up": "res://assets/sprites/animation/enemy/rat/walk/up/rat_walk_up.png",
	"walk_side": "res://assets/sprites/animation/enemy/rat/walk/side/rat_walk_side.png",
	"attack_down": "res://assets/sprites/animation/enemy/rat/attack/down/rat_attack_down.png",
	"attack_up": "res://assets/sprites/animation/enemy/rat/attack/up/rat_attack_up.png",
	"attack_side": "res://assets/sprites/animation/enemy/rat/attack/side/rat_attack_side.png",
	"death": "res://assets/sprites/animation/enemy/rat/death/down/rat_death_down.png",
}
# paths compartilhados entre tipos — o procedural roteia por CURRENT_MOB

func _build_frames() -> void:
	# roteia o sprite procedural pro tipo certo (paths sao compartilhados)
	TEXHELPER.CURRENT_MOB = mob_type
	var sf = SpriteFrames.new()
	sf.remove_animation("default")
	for anim in ANIMS:
		# TODOS os mobs usam procedural (arte unificada, mesmo estilo do knight).
		# A arte real antiga do rato era pequena/zuada — descartada pelo usuario.
		var texs: Array[Texture2D] = TEXHELPER.load_sheet_procedural(ANIMS[anim])
		if texs.is_empty():
			continue
		sf.add_animation(anim)
		sf.set_animation_speed(anim, 8.0)
		sf.set_animation_loop(anim, anim.begins_with("idle") or anim.begins_with("walk"))
		for t in texs:
			sf.add_frame(anim, _strip_tex(t))
	sprite.sprite_frames = sf
	sprite.play("idle_down")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# mobs menores (rato/slime/bat) ganham presenca na tela (estilo Rucoy)
	var small := mob_type in ["rat", "slime", "bat"]
	sprite.scale = Vector2(1.4, 1.4) if small else Vector2(1.15, 1.15)

func _strip_tex(t: Texture2D) -> Texture2D:
	var im = t.get_image()
	if im == null:
		return t
	im.convert(Image.FORMAT_RGBA8)
	for y in range(im.get_height()):
		for x in range(im.get_width()):
			var c = im.get_pixel(x, y)
			if c.a > 0.0 and c.r > 0.47 and c.b > 0.39 and c.g < 0.43 and absf(c.r - c.b) < 0.31:
				im.set_pixel(x, y, Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(im)

func _physics_process(delta: float) -> void:
	if not net_authority:
		_net_mirror_physics(delta)
		return
	# servidor: transmite estado a 10Hz
	if NetworkManager.is_server:
		_net_accum += delta
		if _net_accum >= 1.0 / NET_SEND_HZ:
			_net_accum = 0.0
			var anim = "idle:" + facing
			if state == "chase" or state == "wander":
				anim = "walk:" + facing
			elif state == "attack":
				anim = "attack:" + facing
			NetworkManager.net_send_mob_state(self, _net_map, anim)
	if mob_type == "dummy":
		return  # dummy de treino: estatico, imortal, nunca ataca
	if dying or dead:
		return
	if stunned > 0.0:
		stunned -= delta
		velocity = Vector2.ZERO
		hp_bar.value = float(hp) / float(max_hp) * 100.0
		return
	var player = _get_player()
	if player == null:
		return

	var t = TYPES.get(mob_type, TYPES["rat"])
	var wspeed = WANDER_SPEED * t["vel"]
	var cspeed = CHASE_SPEED * t["vel"]

	var d = global_position.distance_to(player.global_position)
	if d <= ATTACK_RANGE:
		state = "attack"
	elif d <= AGGRO_RANGE:
		state = "chase"
	else:
		state = "wander"

	match state:
		"wander":
			if global_position.distance_to(wander_target) < 8.0:
				var ang = randf() * TAU
				wander_target = home + Vector2(cos(ang), sin(ang)) * (randf() * WANDER_RADIUS)
			_move(wander_target, wspeed)
		"chase":
			if player.dead:
				state = "wander"
				return
			if global_position.distance_to(home) > 700.0:
				state = "wander"  # leash: nao persegue pra longe do spawn
				return
			_move(player.global_position, cspeed)
		"attack":
			if player.dead:
				state = "wander"
				return
			velocity = Vector2.ZERO
			attack_cooldown -= delta
			if attack_cooldown <= 0.0:
				attack_cooldown = 1.2
				_play_dir("attack")
				$AtkTimer.start(0.3)

	hp_bar.value = float(hp) / float(max_hp) * 100.0

func _do_attack_hit() -> void:
	if dying or dead:
		return
	var player = _get_player()
	if player != null and not player.dead:
		# so acerta se o alvo ainda estiver no alcance do golpe
		if global_position.distance_to(player.global_position) <= 110.0:
			# variancia estilo Tibia: dano ±10% (minimo 1)
			var dmg = max(1, damage + randi() % max(1, int(damage * 0.2) + 1) - int(damage * 0.1))
			if player.get_script() == NETTARGET:
				# servidor dedicado: dano vai por RPC pro cliente dono do alvo
				NetworkManager._rpc_damage_player.rpc_id(player.peer_id, dmg)
			else:
				player.take_damage(dmg)

func _move(dest: Vector2, speed: float) -> void:
	var dir = (dest - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	if abs(dir.x) > abs(dir.y):
		facing = "left" if dir.x < 0 else "right"
	else:
		facing = "up" if dir.y < 0 else "down"
	_play_dir("walk")

func _play_dir(base: String) -> void:
	var anim := base + "_down"
	if facing == "up":
		anim = base + "_up"
		sprite.flip_h = false
	elif facing == "left" or facing == "right":
		anim = base + "_side"
		sprite.flip_h = facing == "left"
	else:
		sprite.flip_h = false
	if sprite.animation != anim:
		sprite.play(anim)

func _get_player():
	# servidor dedicado: alvo virtual = player online mais proximo NO MEU MAPA
	if NetworkManager.dedicated:
		return _net_dedicated_target()
	var nodes = get_tree().get_nodes_in_group("player")
	return nodes[0] if nodes.size() > 0 else null

func _net_dedicated_target():
	# procura o player online mais perto de mim (mesmo mapa) e devolve um alvo virtual
	var best_id := 0
	var best_d := INF
	for id in NetworkManager.players:
		var info = NetworkManager.players[id]
		if info.get("map", "") != _net_map:
			continue
		if not info.has("pos"):
			continue
		var d = global_position.distance_to(info["pos"])
		if d < best_d:
			best_d = d
			best_id = id
	if best_id == 0:
		return null
	if _net_target == null or not is_instance_valid(_net_target) or _net_target.peer_id != best_id:
		_net_target = NETTARGET.new()
		_net_target.peer_id = best_id
		_net_target.global_position = NetworkManager.players[best_id]["pos"]
		add_child(_net_target)
	_net_target.global_position = NetworkManager.players[best_id]["pos"]
	_net_target.dead = false
	return _net_target

func take_damage(amount: int, from_peer: int = 0) -> void:
	if dead or dying:
		return
	if not net_authority:
		# espelho no cliente: pede pro servidor aplicar
		NetworkManager.request_mob_damage(net_id, amount)
		return
	# dummy de treino: mostra o numero de dano mas nunca morre (treino infinito)
	if mob_type == "dummy":
		_flash_damage()
		_spawn_damage_number(amount)
		return
	if from_peer != 0:
		_last_hit_by = from_peer
	hp -= amount
	AudioManager.play_sfx("hit", 0.15)
	hp_bar.value = float(hp) / float(max_hp) * 100.0
	_flash_damage()
	_spawn_damage_number(amount)
	if hp <= 0:
		die()

# ---------- FEEDBACK VISUAL DE DANO ----------
func _flash_damage() -> void:
	# flash branco no sprite (modulate pisca)
	sprite.modulate = Color(3.0, 3.0, 3.0)
	var tw = create_tween()
	tw.tween_property(sprite, "modulate", Color(1, 1, 1), 0.15)

func _spawn_damage_number(amount: int) -> void:
	var l = Label.new()
	l.text = str(amount)
	l.position = global_position + Vector2(-12, -60 + randf() * 10 - 5)
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", Color(1.0, 0.95, 0.75))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 4)
	l.z_index = 50
	get_parent().add_child(l)
	var tw = l.create_tween()
	tw.tween_property(l, "position:y", l.position.y - 28.0, 0.55)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.55)
	tw.tween_callback(l.queue_free)

func die() -> void:
	dying = true
	dead = true
	hp = 0
	velocity = Vector2.ZERO
	hp_bar.value = 0
	_play_dir("death")
	AudioManager.play_sfx("mob_death")
	# servidor dedicado: recompensa vai por RPC pro ultimo atacante (autoritativo)
	if NetworkManager.dedicated and _last_hit_by != 0:
		var loot = preload("res://scripts/entities/loot_table.gd").roll_loot_list(mob_type)
		NetworkManager._rpc_mob_reward.rpc_id(_last_hit_by, xp_reward, loot, global_position, mob_type)
		NetworkManager._rpc_mob_removed.rpc(_last_hit_by)  # cliente para de mirar
		$RespawnTimer.start(respawn_time)
		return
	GameManager.add_xp(xp_reward)
	GameManager.quest_on_kill(mob_type)
	GameManager.bestiary_kill(mob_type)
	preload("res://scripts/entities/loot_table.gd").roll_drop(mob_type, global_position, get_parent())
	# corpo desvanece (o respawn timer continua rodando)
	var tw = create_tween()
	tw.tween_interval(0.8)
	tw.tween_property(sprite, "modulate:a", 0.0, 1.2)
	$RespawnTimer.start(respawn_time)

func _do_respawn() -> void:
	dead = false
	dying = false
	hp = max_hp
	global_position = home
	_play_dir("idle")
	hp_bar.value = 100
	sprite.modulate = Color(1, 1, 1, 1)

# ---------- ESPELHO NO CLIENTE (recebe snapshots do servidor) ----------
func apply_net_state(data: Dictionary) -> void:
	if net_authority:
		return
	_net_target_pos = data["p"]
	_net_buf.append({"t": Time.get_ticks_msec(), "p": data["p"], "a": data.get("a", "idle:down")})
	# buffer enxuto: ~1.5s de snapshots a 10Hz
	while _net_buf.size() > 16:
		_net_buf.pop_front()
	if data.get("m", "") != "":
		_net_map = data["m"]
	_net_anim = data.get("a", "idle:down")
	hp = int(data.get("hp", hp))
	max_hp = int(data.get("mhp", max_hp))
	hp_bar.value = float(hp) / float(max_hp) * 100.0
	var was_dead := dead
	dead = bool(data.get("d", false))
	if dead and not was_dead:
		dying = true
		_play_dir("death")
		# fade do cadaver no cliente (servidor autoritativo nao renderiza)
		var tw = create_tween()
		tw.tween_interval(0.8)
		tw.tween_property(sprite, "modulate:a", 0.0, 1.2)
	elif not dead and was_dead:
		dying = false
		sprite.modulate = Color(1, 1, 1, 1)
		global_position = _net_target_pos
		_play_dir("idle")

func _on_net_state(id: int, data: Dictionary) -> void:
	if id == net_id:
		apply_net_state(data)

func _on_net_removed(id: int) -> void:
	if id == net_id:
		queue_free()

func _net_mirror_physics(_delta: float) -> void:
	if dead or dying:
		return  # cadaver nao desliza
	# interpolação por BUFFER (gs-netcode): mira o estado de ~120ms atrás,
	# cobre jitter/lag sem rubber-banding; fallback = lerp pro último snapshot
	var goal := _net_target_pos
	var anim := _net_anim
	if _net_buf.size() >= 2:
		var now := Time.get_ticks_msec()
		var past := now - NET_BUF_MS
		var a = _net_buf[0]
		for i in range(1, _net_buf.size()):
			var b = _net_buf[i]
			if int(b["t"]) >= past:
				# segmento [a, b] contém o instante "past" — interpola dentro dele
				var span := float(int(b["t"]) - int(a["t"]))
				var f := 0.0 if span <= 0.0 else clampf((float(past) - float(int(a["t"]))) / span, 0.0, 1.0)
				goal = a["p"].lerp(b["p"], f)
				anim = str(b["a"])
				break
			a = b
		# snapshot mais novo que "past" (rede rápida): usa o mais novo disponível
		if int(_net_buf[-1]["t"]) < past:
			goal = _net_buf[-1]["p"]
			anim = str(_net_buf[-1]["a"])
	var dist = global_position.distance_to(goal)
	if dist > 300.0:
		global_position = goal
	elif dist > 2.0:
		global_position = global_position.lerp(goal, 0.25)
		var parts = anim.split(":")
		facing = parts[1] if parts.size() > 1 else "down"
		_play_dir("walk")
	elif not dead and not dying:
		var parts2 = anim.split(":")
		facing = parts2[1] if parts2.size() > 1 else "down"
		_play_dir("idle" if anim.begins_with("idle") else anim.get_slice(":", 0))

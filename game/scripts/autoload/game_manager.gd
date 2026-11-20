extends Node
## GameManager — estado global do jogo (serializável, pronto pra online futuro)

const SAVE_PATH = "user://savegame.json"
const SAVE_VERSION := 2  # 2 = gravacao atomica (.tmp -> .bak -> save)
const BAG_MAX = 20
# versao do jogo — fonte unica (titulo e export_presets leem daqui; housekeeping manual esquecia)
const GAME_VERSION := "0.6.52"

var player_name: String = "Grimstone"
var level: int = 1
var xp: int = 0
var hp: int = 100
var hp_max: int = 100
var mana: int = 50
var mana_max: int = 50
var skills := {
	"espada": {"level": 10, "xp": 0},
	"defesa": {"level": 10, "xp": 0},
}
var current_map: String = "city1"
var coins: int = 0
var bag := {}
var weapon: String = "spear"
var hair_color: String = "castanho"
var tunic_color: String = "castanho"
var pants_color: String = "marrom"
var arrows: int = 50
var city2_visited: bool = false  # R/G skills desbloqueiam ao chegar na VILA
var city2_unlocked: bool = false
var quests := {}  # id -> {"progress": int, "done": bool, "claimed": bool}
# comida/energia estilo Tibia: segundos restantes de "bem alimentado"
var well_fed_time: float = 0.0
const WELL_FED_MAX: float = 600.0  # cap de 10min empilhando comidas

# banco/depósito estilo Tibia: itens guardados fora da mochila (id -> qty)
var bank := {}
# cinto de runas (v0.6.11): 2 slots de atalho (teclas Z/X) pra usar runa sem abrir a mochila
var belt := {"z": "", "x": ""}

# bestiário estilo Tibia: quantos de cada monstro o player já derrotou (mob_type -> kills)
var bestiary := {}

## runas (estilo Tibia): magia guardada em pedra — qualquer classe usa, NAO gasta mana,
## consome a pedra. Dano fixo + escala com a skill "magia" (dano = base * (1 + lvl*0.02)).
const RUNAS := {
	"runa_fogo": {"dano": 60, "efeito": "fogo"},
	"runa_gelo": {"dano": 35, "efeito": "gelo"},
	"runa_trovoada": {"dano": 45, "efeito": "trovoada"},
	"runa_cura": {"dano": 0, "efeito": "cura"},
}

signal quest_done(id: String)

## sinal de quest concluida (progresso cheio, falta ENTREGAR no NPC) — HUD mostra aviso
signal quest_ready(id: String)

# v0.6.15: sinais de recompensa — FX (autoload) mostra numero flutuante ao ganhar algo
signal xp_gained(amount: int)
signal coins_gained(amount: int)
signal healed(amount: int)
signal mana_gained(amount: int)
signal skill_up_event(skill: String, level: int)

## quests de caca (estilo Tibia/Rucoy): NPC das cidades entrega moedas+xp por matar mobs
## cadeia: cada quest exige a anterior entregue (req)
const QUESTS := {
	"q_ratos": {"npc": "city1", "tipo": "kill", "alvo": "rat", "qtd": 5,
		"coins": 40, "xp": 100, "desc": "Mate 5 ratos no bueiro", "req": ""},
	"q_slimes": {"npc": "city1", "tipo": "kill", "alvo": "slime", "qtd": 5,
		"coins": 60, "xp": 180, "desc": "Mate 5 slimes no bueiro", "req": "q_ratos"},
	"q_aranhas": {"npc": "city2", "tipo": "kill", "alvo": "spider", "qtd": 5,
		"coins": 100, "xp": 350, "desc": "Mate 5 aranhas na floresta", "req": "q_slimes"},
	"q_goblins": {"npc": "city2", "tipo": "kill", "alvo": "goblin", "qtd": 5,
		"coins": 140, "xp": 500, "desc": "Mate 5 goblins na floresta", "req": "q_aranhas"},
	"q_orcs": {"npc": "city2", "tipo": "kill", "alvo": "orc", "qtd": 4,
		"coins": 250, "xp": 900, "desc": "Mate 4 orcs na floresta", "req": "q_goblins"},
	"q_esqueletos": {"npc": "city2", "tipo": "kill", "alvo": "skeleton", "qtd": 4,
		"coins": 250, "xp": 900, "desc": "Mate 4 esqueletos na floresta", "req": "q_orcs"},
}

func quest_state(id: String) -> Dictionary:
	return quests.get(id, {"progress": 0, "done": false, "claimed": false})

# ---------- BESTIÁRIO: ficha de cada monstro (dados + lore) ----------
const BESTIARY_INFO := {
	"rat": {"nome": "Rato dos Bueiros", "onde": "Bueiro (sul da cidade)",
		"desc": "Praga comum nos esgotos. Fraco, mas ataca em grupo. Cai fácil — bom pra quem começa."},
	"slime": {"nome": "Gosma Verde", "onde": "Bueiro (sul da cidade)",
		"desc": "Bola de gosma lenta e grudenta. Dói pouco, mas regenera a paciência de quem acha que é fácil."},
	"bat": {"nome": "Morcego Sanguíneo", "onde": "Bueiro e Floresta",
		"desc": "Voa rápido e errado. Difícil de acertar com flecha, fácil de subestimar."},
	"spider": {"nome": "Aranha da Floresta", "onde": "Floresta (sul da vila)",
		"desc": "Tece teias entre as árvores. Venenosa, rápida e não gosta de visitantes."},
	"wolf": {"nome": "Lobo Cinzento", "onde": "Floresta (sul da vila)",
		"desc": "Caçador nato da floresta. Morde forte e persegue longe. Leve poção antes de encarar."},
	"goblin": {"nome": "Goblin Saqueador", "onde": "Floresta (sul da vila)",
		"desc": "Pequeno, covarde e ladrão. Ataca em bando e carrega o que roubou — inclusive moedas."},
	"orc": {"nome": "Orc Guerreiro", "onde": "Floresta (sul da vila)",
		"desc": "Brutamontes de machado. Aguenta pancada e devolve em dobro. Só enfrente bem equipado."},
	"skeleton": {"nome": "Esqueleto Guerreiro", "onde": "Floresta (sul da vila)",
		"desc": "Ossos animados por magia antiga. Não sente medo nem cansaço — só para quando desmonta."},
}


func quest_available(id: String) -> bool:
	var q: Dictionary = QUESTS.get(id, {})
	var req: String = q.get("req", "")
	if req != "" and not (quests.has(req) and quests[req].get("claimed", false)):
		return false
	# done mas NAO entregue: continua disponivel pra ENTREGAR no NPC (so some apos claim)
	if quests.has(id) and quests[id].get("claimed", false):
		return false
	return true

func quest_on_kill(mob_type: String) -> void:
	for id in QUESTS:
		var q: Dictionary = QUESTS[id]
		if q["tipo"] != "kill" or q["alvo"] != mob_type:
			continue
		if not quest_available(id):
			continue
		var st: Dictionary = quests.get(id, {"progress": 0, "done": false, "claimed": false})
		if st.get("done", false):
			continue
		st["progress"] = int(st.get("progress", 0)) + 1
		if st["progress"] >= int(q["qtd"]):
			st["done"] = true
			quest_done.emit(id)
			quest_ready.emit(id)
		quests[id] = st

func quest_claim(id: String) -> bool:
	var q: Dictionary = QUESTS.get(id, {})
	if q.is_empty() or not quests.has(id):
		return false
	var st: Dictionary = quests[id]
	if not st.get("done", false) or st.get("claimed", false):
		return false
	st["claimed"] = true
	quests[id] = st
	coins += int(q.get("coins", 0))
	coins_gained.emit(int(q.get("coins", 0)))
	add_xp(int(q.get("xp", 0)))
	return true

const RARITY = preload("res://scripts/autoload/rarity.gd")

const FUSION_COST := 50

## fusao de itens: 3 iguais do mesmo tier -> 1 do tier seguinte (custa FUSION_COST; lendario nao funde)
func can_fuse(id: String) -> bool:
	var tier := RARITY.tier_of(id)
	return tier < RARITY.TIERS.size() - 1 and bag.get(id, 0) >= 3 and coins >= FUSION_COST

func fuse_item(id: String) -> bool:
	var tier := RARITY.tier_of(id)
	if tier >= RARITY.TIERS.size() - 1:
		return false
	if bag.get(id, 0) < 3 or coins < FUSION_COST:
		return false
	if not remove_item(id, 3):
		return false
	coins -= FUSION_COST
	add_item(RARITY.key_with_tier(id.split("#")[0], tier + 1), 1)
	return true

## arma equipada pode ser "espada#2" (tier de raridade) — dano multiplicado pelo tier
func weapon_base() -> String:
	return weapon.split("#")[0]

func weapon_tier() -> int:
	return RARITY.tier_of(weapon)

func weapon_dano_mult() -> float:
	return RARITY.dano_mult(weapon_tier())

func EQUIPS_OK(w: String) -> bool:
	var base: String = w.split("#")[0]
	var eq = preload("res://scripts/autoload/equips.gd")
	return eq.WEAPONS.has(base)

func xp_for_level(lv: int) -> int:
	return int(50.0 / 3.0 * (pow(lv, 3) - 6 * pow(lv, 2) + 17 * lv - 12))

# --- estimativas de tempo (tela K) ---
# taxas medias medidas no jogo: golpe basico = 4 xp de skill por hit (~1 hit/s farmando) -> ~240 xp/min
# defesa = 2 xp por dano tomado (~1 hit tomado a cada 2s) -> ~60 xp/min
# level = media ~60 xp por mob, ~1 kill a cada 8s (TTK 5-10s) -> ~450 xp/min
const SKILL_XP_PER_MIN := 240.0
const DEFESA_XP_PER_MIN := 60.0
const LEVEL_XP_PER_MIN := 450.0

func skill_xp_need(skill: String) -> int:
	var lv: int = 10
	if skills.has(skill):
		lv = skills[skill]["level"]
	return lv * lv * 5

func fmt_time_min(mins: float) -> String:
	if mins < 1.0:
		return "%ds" % int(max(1.0, mins * 60.0))
	if mins < 90.0:
		return "%.0fmin" % mins
	return "%.1fh" % (mins / 60.0)

func skill_time_left(skill: String) -> String:
	var rate := SKILL_XP_PER_MIN
	if skill == "defesa":
		rate = DEFESA_XP_PER_MIN
	var have: int = skills[skill]["xp"] if skills.has(skill) else 0
	var falta: int = max(0, skill_xp_need(skill) - have)
	return fmt_time_min(float(falta) / rate)

func level_time_left() -> String:
	var falta: int = max(0, xp_for_level(level + 1) - xp)
	return fmt_time_min(float(falta) / LEVEL_XP_PER_MIN)

# stats derivados do level (fonte unica de verdade — save antigo nunca mais desincroniza)
func max_hp_for_level(lv: int) -> int:
	return 100 + (lv - 1) * 10

func max_mana_for_level(lv: int) -> int:
	return 50 + (lv - 1) * 5

func add_xp(amount: int) -> void:
	xp += amount
	xp_gained.emit(amount)
	while level < 999 and xp >= xp_for_level(level + 1):
		level += 1
		hp_max = max_hp_for_level(level)
		mana_max = max_mana_for_level(level)
		# estilo Tibia: level up NAO enche vida/mana se o player esta em combate
		# (evita "heal gratis" no meio do fight); fora de combate enche normal
		var in_combat := false
		for m in get_tree().get_nodes_in_group("mobs"):
			if is_instance_valid(m) and not m.dead and not m.dying and m.state == "attack":
				in_combat = true
				break
		if not in_combat:
			hp = hp_max
			mana = mana_max
		else:
			hp = min(hp_max, hp + 30)
			mana = min(mana_max, mana + 15)
		print("LEVEL UP! Nivel ", level)

func add_skill_xp(skill: String, amount: int) -> void:
	if not skills.has(skill):
		skills[skill] = {"level": 10, "xp": 0}
	skills[skill]["xp"] += amount
	# curva Tibia: custo cresce com o nivel (lvl^2 * 5) — skill up rapido no inicio, lento no fim
	var need = skills[skill]["level"] * skills[skill]["level"] * 5
	while skills[skill]["xp"] >= need:
		skills[skill]["xp"] -= need
		skills[skill]["level"] += 1
		skill_up_event.emit(skill, skills[skill]["level"])
		need = skills[skill]["level"] * skills[skill]["level"] * 5
		print("SKILL UP: ", skill, " nivel ", skills[skill]["level"])

func add_item(id: String, qty: int = 1) -> bool:
	if bag.has(id):
		bag[id] += qty
		return true
	if bag.size() >= BAG_MAX:
		return false
	bag[id] = qty
	return true

func remove_item(id: String, qty: int = 1) -> bool:
	if not bag.has(id) or bag[id] < qty:
		return false
	bag[id] -= qty
	if bag[id] <= 0:
		bag.erase(id)
	return true

func use_item(id: String) -> bool:
	var db = preload("res://scripts/autoload/items_db.gd")
	var it = db.ITEMS.get(id, null)
	if it == null or not remove_item(id):
		return false
	if it.get("tipo", "") == "uso":
		if it.has("hp"):
			hp = min(hp_max, hp + it["hp"])
			healed.emit(int(it["hp"]))
		if it.has("mana"):
			mana = min(mana_max, mana + it["mana"])
			mana_gained.emit(int(it["mana"]))
		if it.has("comida"):
			# comida/energia estilo Tibia: empilha até o cap, regen acelerado
			well_fed_time = min(WELL_FED_MAX, well_fed_time + float(it["comida"]))
	if it.get("tipo", "") == "runa":
		# runa de cura cura direto (como pocao); runas de dano: o HUD aplica o efeito no mundo
		if id == "runa_cura":
			hp = min(hp_max, hp + int(float(hp_max) * 0.4))
		return true
	return true

## dano da runa escalado pela skill "magia" (base * (1 + lvl*0.02))
func runa_dano(id: String) -> int:
	var r = RUNAS.get(id, null)
	if r == null:
		return 0
	var magia_lvl: int = skills.get("magia", {"level": 10})["level"]
	return int(float(r["dano"]) * (1.0 + magia_lvl * 0.02))

## GRAVACAO ATOMICA (v0.6.42)
## O Android mata o processo a qualquer momento (app em background, bateria,
## task killer). Gravar direto no savegame.json significava que um kill no meio
## da escrita deixava o arquivo PELA METADE — e o save anterior ja tinha sido
## apagado junto. O jogador perdia tudo. Agora:
##   escreve no .tmp -> relê e confere que virou JSON inteiro -> o save bom vira
##   .bak -> o .tmp e promovido a save. Um kill em qualquer ponto da sequencia
##   deixa ou o save antigo ou o novo, nunca um arquivo partido.
const SAVE_TMP := "user://savegame.tmp"
const SAVE_BAK := "user://savegame.bak"

func _default_skills() -> Dictionary:
	# dicionario NOVO a cada chamada (nao compartilha referencia com `skills`)
	return {"espada": {"level": 10, "xp": 0}, "defesa": {"level": 10, "xp": 0}}

## AUTOSAVE (v0.6.45)
## O jogador perdia progresso: o jogo so gravava ao trocar de mapa, ao desbloquear
## a city2, no respawn e ao sair pelo menu. No celular o sistema mata o app sem
## avisar (background, bateria, task killer) — tudo desde o ultimo save ia embora.
## Solucao SEM gasto desnecessario de disco: a cada AUTOSAVE_PERIOD s o estado e'
## serializado e COMPARADO com o ultimo texto gravado; so grava se mudou de
## verdade. Estado igual nao toca no cartao (nada de escrita a cada 20s a toa).
const AUTOSAVE_PERIOD := 20.0
var _autosave_acc := 0.0
var _last_saved_text := ""
var _save_loaded := false   # so autosave depois de um load bem sucedido

func _process(delta: float) -> void:
	if not _save_loaded:
		return
	_autosave_acc += delta
	if _autosave_acc < AUTOSAVE_PERIOD:
		return
	_autosave_acc = 0.0
	var text := _serialize()
	if text == _last_saved_text:
		return          # nada mudou: nao gasta escrita
	_write_atomic(text)

## flush imediato — chamado quando o Android manda o app pra background
func flush_save() -> void:
	if not _save_loaded:
		return
	_autosave_acc = 0.0
	_write_atomic(_serialize())

func save_game() -> void:
	_autosave_acc = 0.0
	_write_atomic(_serialize())

func _serialize() -> String:
	var data := {
		"player_name": player_name, "level": level, "xp": xp,
		"hp": hp, "hp_max": hp_max, "mana": mana, "mana_max": mana_max,
		"skills": skills, "current_map": current_map,
		"weapon": weapon, "hair_color": hair_color, "tunic_color": tunic_color,
		"pants_color": pants_color, "arrows": arrows, "city2_visited": city2_visited,
		"coins": coins, "bag": bag, "city2_unlocked": city2_unlocked,
		"quests": quests, "well_fed": int(well_fed_time),
		"bank": bank, "bestiary": bestiary, "belt": belt,
		"save_version": SAVE_VERSION,
	}
	return JSON.stringify(data, "\t")

func _write_atomic(text: String) -> void:
	var tmp := FileAccess.open(SAVE_TMP, FileAccess.WRITE)
	if tmp == null:
		push_warning("save: nao consegui abrir " + SAVE_TMP)
		return
	tmp.store_string(text)
	tmp.close()
	# relê do DISCO: o que esta gravado tem que voltar como JSON completo antes
	# de qualquer coisa sobrescrever o save que ja funciona
	if _read_save(SAVE_TMP) == null:
		push_warning("save: .tmp saiu invalido — save anterior preservado")
		return
	# promove: o save atual vira backup ANTES de ser substituido
	if FileAccess.file_exists(SAVE_PATH):
		if FileAccess.file_exists(SAVE_BAK):
			DirAccess.remove_absolute(SAVE_BAK)
		DirAccess.rename_absolute(SAVE_PATH, SAVE_BAK)
	if DirAccess.rename_absolute(SAVE_TMP, SAVE_PATH) != OK:
		push_warning("save: nao consegui promover o .tmp")

## Le um save e devolve o Dictionary, ou null se o arquivo nao existe, nao abre
## ou nao e JSON valido. Usa JSON.parse (devolve codigo de erro) em vez de
## JSON.parse_string (que cospe ERROR no log a cada save corrompido).
func _read_save(path: String):
	if not FileAccess.file_exists(path):
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var txt := f.get_as_text()
	f.close()
	var j := JSON.new()
	if j.parse(txt) != OK:
		return null
	if not (j.data is Dictionary):
		return null
	return j.data

## Leitura tolerante a tipo: save editado na mao, de versao antiga ou campo com
## lixo nao pode derrubar o load (antes `int("muitos")` estourava SCRIPT ERROR
## no meio do load e deixava o jogo com estado pela metade).
func _as_int(v, fallback: int) -> int:
	if v is int:
		return v
	if v is float:
		return int(v)
	if v is String and v.is_valid_int():
		return int(v)
	if v is bool:
		return 1 if v else 0
	return fallback

func _as_dict(v) -> Dictionary:
	return v if v is Dictionary else {}

func _sanitize_skills(v) -> Dictionary:
	var out := _default_skills()
	var src := _as_dict(v)
	for k in src:
		var e := _as_dict(src[k])
		if e.is_empty():
			continue
		out[str(k)] = {"level": maxi(1, _as_int(e.get("level"), 10)),
			"xp": maxi(0, _as_int(e.get("xp"), 0))}
	return out

## mochila/banco: so chave String -> quantidade int > 0 sobrevive
func _sanitize_counts(v) -> Dictionary:
	var out := {}
	for k in _as_dict(v):
		var q := _as_int(_as_dict(v)[k], 0)
		if k is String and q > 0:
			out[k] = q
	return out

func load_game() -> bool:
	var parsed = _read_save(SAVE_PATH)
	if parsed == null:
		# save truncado/corrompido: cai no backup da gravacao anterior
		parsed = _read_save(SAVE_BAK)
		if parsed == null:
			# jogo novo: sem save nao ha baseline, mas o autosave precisa funcionar
			_last_saved_text = ""
			_save_loaded = true
			return false
		push_warning("save: principal ilegivel — carregado do backup")
	player_name = str(parsed.get("player_name", "Grimstone"))
	level = clampi(_as_int(parsed.get("level"), 1), 1, 1000)
	xp = maxi(0, _as_int(parsed.get("xp"), 0))
	hp_max = max_hp_for_level(level)  # derivado do level — save antigo nunca desincroniza
	hp = clampi(_as_int(parsed.get("hp"), hp_max), 1, hp_max)
	mana_max = max_mana_for_level(level)
	mana = clampi(_as_int(parsed.get("mana"), mana_max), 0, mana_max)
	skills = _sanitize_skills(parsed.get("skills", null))
	current_map = str(parsed.get("current_map", "city1"))
	weapon = str(parsed.get("weapon", "spear"))
	# save antigo: arma sem tier continua valida (tier 0 = comum)
	if not EQUIPS_OK(weapon):
		weapon = "spear"
	coins = maxi(0, _as_int(parsed.get("coins"), 0))
	bag = _sanitize_counts(parsed.get("bag", {}))
	hair_color = str(parsed.get("hair_color", "castanho"))
	tunic_color = str(parsed.get("tunic_color", "castanho"))
	pants_color = str(parsed.get("pants_color", "marrom"))
	arrows = maxi(0, _as_int(parsed.get("arrows"), 50))
	city2_visited = bool(parsed.get("city2_visited", false))
	city2_unlocked = bool(parsed.get("city2_unlocked", false))
	quests = {}
	for id in _as_dict(parsed.get("quests", {})):
		var qe := _as_dict(_as_dict(parsed.get("quests", {}))[id])
		quests[str(id)] = {"progress": maxi(0, _as_int(qe.get("progress"), 0)),
			"done": bool(qe.get("done", false)),
			"claimed": bool(qe.get("claimed", false))}
	# comida: save antigo sem "well_fed" = 0 (não persiste entre sessões longas)
	well_fed_time = float(maxi(0, _as_int(parsed.get("well_fed"), 0)))
	# banco: save antigo sem "bank" = vazio (não perde nada)
	bank = _sanitize_counts(parsed.get("bank", {}))
	# cinto: save antigo sem "belt" = vazio
	var bl := _as_dict(parsed.get("belt", {}))
	belt = {"z": str(bl.get("z", "")), "x": str(bl.get("x", ""))}
	# bestiário: save antigo sem "bestiary" = vazio (contadores começam do zero)
	bestiary = _sanitize_counts(parsed.get("bestiary", {}))
	_last_saved_text = _serialize()   # baseline: autosave so grava se MUDAR
	_save_loaded = true
	return true

## O Android manda PAUSED quando o app vai pra background — e depois pode matar o
## processo sem aviso. Este e' o unico ponto em que da' pra gravar antes disso.
## RESUMED apenas retoma o relogio do autosave (o tempo parado nao conta).
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
			flush_save()
		NOTIFICATION_WM_CLOSE_REQUEST:
			flush_save()
		NOTIFICATION_APPLICATION_RESUMED:
			_autosave_acc = 0.0

# ---------- BESTIÁRIO (estilo Tibia: registro de caça) ----------
## registra 1 derrota do tipo de monstro (chamado em todo kill, offline e online)
func bestiary_kill(mob_type: String) -> void:
	if mob_type == "" or mob_type == "dummy":
		return
	bestiary[mob_type] = int(bestiary.get(mob_type, 0)) + 1

## quantas vezes o player derrotou esse tipo (0 se nunca)
func bestiary_count(mob_type: String) -> int:
	return int(bestiary.get(mob_type, 0))

## tipos já vistos (com pelo menos 1 kill), na ordem do bestiário
func bestiary_seen() -> Array:
	var out: Array = []
	for t in BESTIARY_INFO:
		if bestiary_count(t) > 0:
			out.append(t)
	return out

# ---------- BANCO/DEPÓSITO (estilo Tibia) ----------
## deposita qty do item da mochila pro banco (tier conta: "espada#2" é slot próprio)
func bank_deposit(id: String, qty: int = 1) -> bool:
	if not bag.has(id) or bag[id] < qty:
		return false
	bag[id] -= qty
	if bag[id] <= 0:
		bag.erase(id)
	bank[id] = int(bank.get(id, 0)) + qty
	return true

## saca qty do item do banco pra mochila (respeita BAG_MAX)
func bank_withdraw(id: String, qty: int = 1) -> bool:
	if not bank.has(id) or bank[id] < qty:
		return false
	if not add_item(id, qty):
		return false
	bank[id] -= qty
	if bank[id] <= 0:
		bank.erase(id)
	return true

## ---------- CINTO DE RUNAS (v0.6.11) ----------
## atribui a 1a runa da mochila (ou id especifico) a um slot do cinto (Z/X)
func belt_assign(slot: String, id: String) -> bool:
	if not belt.has(slot):
		return false
	var base: String = id.split("#")[0]
	var db = preload("res://scripts/autoload/items_db.gd")
	if not db.ITEMS.get(base, {}).get("tipo", "") == "runa":
		return false
	belt[slot] = base
	return true

## usa a runa do slot (Z/X): devolve false se vazio ou sem runa na mochila
func belt_use(slot: String) -> bool:
	var id: String = str(belt.get(slot, ""))
	if id == "" or not bag.has(id):
		return false
	return use_item(id)

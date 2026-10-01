extends Node
## GameManager — autoload: estado global do jogo (serializável, pronto pra online futuro)

const SAVE_PATH = "user://savegame.json"
const BAG_MAX = 20

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
var weapon: String = "sword"
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
		if it.has("mana"):
			mana = min(mana_max, mana + it["mana"])
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

func save_game() -> void:
	var data := {
		"player_name": player_name, "level": level, "xp": xp,
		"hp": hp, "hp_max": hp_max, "mana": mana, "mana_max": mana_max,
		"skills": skills, "current_map": current_map,
		"weapon": weapon, "hair_color": hair_color, "tunic_color": tunic_color,
		"pants_color": pants_color, "arrows": arrows, "city2_visited": city2_visited,
		"coins": coins, "bag": bag, "city2_unlocked": city2_unlocked,
		"quests": quests, "well_fed": int(well_fed_time),
		"bank": bank, "bestiary": bestiary,
	}
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed == null:
		return false
	player_name = parsed.get("player_name", "Grimstone")
	level = int(parsed.get("level", 1))
	xp = int(parsed.get("xp", 0))
	hp_max = max_hp_for_level(level)  # derivado do level — save antigo nunca desincroniza
	hp = min(int(parsed.get("hp", hp_max)), hp_max)
	mana_max = max_mana_for_level(level)
	mana = min(int(parsed.get("mana", mana_max)), mana_max)
	skills = parsed.get("skills", skills)
	current_map = parsed.get("current_map", "city1")
	weapon = parsed.get("weapon", "sword")
	# save antigo: arma sem tier continua valida (tier 0 = comum)
	if not EQUIPS_OK(weapon):
		weapon = "sword"
	coins = int(parsed.get("coins", 0))
	bag = parsed.get("bag", {})
	hair_color = parsed.get("hair_color", "castanho")
	tunic_color = parsed.get("tunic_color", "castanho")
	pants_color = parsed.get("pants_color", "marrom")
	arrows = int(parsed.get("arrows", 50))
	city2_visited = bool(parsed.get("city2_visited", false))
	city2_unlocked = bool(parsed.get("city2_unlocked", false))
	quests = parsed.get("quests", {})
	if quests is Dictionary:
		for id in quests:
			quests[id] = {"progress": int(quests[id].get("progress", 0)),
				"done": bool(quests[id].get("done", false)),
				"claimed": bool(quests[id].get("claimed", false))}
	else:
		quests = {}
	# comida: save antigo sem "well_fed" = 0 (não persiste entre sessões longas)
	well_fed_time = float(int(parsed.get("well_fed", 0)))
	# banco: save antigo sem "bank" = vazio (não perde nada)
	bank = parsed.get("bank", {})
	if not bank is Dictionary:
		bank = {}
	# bestiário: save antigo sem "bestiary" = vazio (contadores começam do zero)
	bestiary = parsed.get("bestiary", {})
	if not bestiary is Dictionary:
		bestiary = {}
	return true

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

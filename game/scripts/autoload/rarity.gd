extends Object
## Raridade de itens — 5 tiers estilo RPG (docs/DESIGN_ONLINE.md secao 4)
## Armas dropadas sorteiam tier; o tier multiplica o dano da arma.
## Chave na mochila: "espada#2" = Espada Rara (tier 2). Tier 0 = comum (sem "#").

const TIERS = [
	{"id": "comum", "sufixo": "", "cor": Color(0.75, 0.75, 0.78), "mult": 1.0, "chance": 0.70},
	{"id": "incrivel", "sufixo": "Incrivel", "cor": Color(0.3, 0.85, 0.35), "mult": 1.10, "chance": 0.20},
	{"id": "raro", "sufixo": "Raro", "cor": Color(0.35, 0.55, 1.0), "mult": 1.25, "chance": 0.07},
	{"id": "epico", "sufixo": "Epico", "cor": Color(0.75, 0.4, 0.95), "mult": 1.50, "chance": 0.025},
	{"id": "lendario", "sufixo": "Lendario", "cor": Color(1.0, 0.82, 0.25), "mult": 2.0, "chance": 0.005},
]

static func roll_tier(bonus: int = 0) -> int:
	# rola de cima pra baixo (lendario primeiro); bonus do mob multiplica a chance dos tiers altos
	var r := randf()
	var acc := 0.0
	for i in range(TIERS.size() - 1, 0, -1):
		acc += TIERS[i]["chance"] * (1.0 + bonus * 0.5)
		if r <= acc:
			return i
	return 0

static func tier_of(key: String) -> int:
	# "espada#2" -> 2 ; "espada" -> 0
	if "#" in key:
		return int(key.split("#")[1])
	return 0

static func key_with_tier(base: String, tier: int) -> String:
	return base if tier <= 0 else base + "#" + str(tier)

static func dano_mult(tier: int) -> float:
	return TIERS[clampi(tier, 0, TIERS.size() - 1)]["mult"]

static func cor(tier: int) -> Color:
	return TIERS[clampi(tier, 0, TIERS.size() - 1)]["cor"]

static func sufixo(tier: int) -> String:
	return TIERS[clampi(tier, 0, TIERS.size() - 1)]["sufixo"]

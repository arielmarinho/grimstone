class_name SkillsDB
extends Object
## Skills ativas por classe (estilo Rucoy): 2 skills basicas (Q/E) + 2 avancadas
## (R/G) desbloqueadas ao chegar na CITY2. Ativaveis pelo teclado OU botao no HUD.

const SKILLS = {
	"sword": [
		{"id": "golpe", "nome": "Golpe Poderoso", "tecla": "Q", "mana": 20, "cd": 8.0,
			"desc": "O proximo ataque causa 3x de dano"},
		{"id": "rodopio", "nome": "Rodopio", "tecla": "E", "mana": 35, "cd": 12.0,
			"desc": "Golpeia todos os monstros ao redor (dano x2)"},
		{"id": "investida", "nome": "Investida", "tecla": "R", "mana": 30, "cd": 14.0, "city2": true,
			"desc": "Avanca ate o alvo e causa 2.5x de dano"},
		{"id": "terremoto", "nome": "Terremoto", "tecla": "G", "mana": 50, "cd": 20.0, "city2": true,
			"desc": "Golpeia todos ao redor (dano x2.5) e atordoa por 2s"},
	],
	"axe": [
		{"id": "furia", "nome": "Furia", "tecla": "Q", "mana": 25, "cd": 15.0,
			"desc": "+80% de dano por 8 segundos"},
		{"id": "atordoar", "nome": "Atordoar", "tecla": "E", "mana": 30, "cd": 14.0,
			"desc": "Atordoa o monstro por 3s e causa dano"},
		{"id": "golpe_duplo", "nome": "Golpe Duplo", "tecla": "R", "mana": 35, "cd": 12.0, "city2": true,
			"desc": "Golpeia 2 vezes seguidas (dano total x2.2)"},
		{"id": "bersek", "nome": "Bersek", "tecla": "G", "mana": 55, "cd": 25.0, "city2": true,
			"desc": "+150% de dano por 10 segundos"},
	],
	"bow": [
		{"id": "certeiro", "nome": "Tiro Certeiro", "tecla": "Q", "mana": 20, "cd": 8.0,
			"desc": "A proxima flecha e critico garantido (3x)"},
		{"id": "chuva", "nome": "Chuva de Flechas", "tecla": "E", "mana": 40, "cd": 16.0,
			"desc": "Acerta todos os monstros ao redor (gasta 5 flechas)"},
		{"id": "precisao", "nome": "Precisao", "tecla": "R", "mana": 30, "cd": 15.0, "city2": true,
			"desc": "Proximas 3 flechas sao criticos garantidos"},
		{"id": "tiro_multi", "nome": "Tiro Multiplo", "tecla": "G", "mana": 45, "cd": 18.0, "city2": true,
			"desc": "Flecha explosiva: acerta o alvo e monstros ao redor dele"},
	],
	"staff": [
		{"id": "fogo", "nome": "Bola de Fogo", "tecla": "Q", "mana": 30, "cd": 10.0,
			"desc": "Projeteil gigante que causa 3x de dano"},
		{"id": "cura", "nome": "Cura", "tecla": "E", "mana": 40, "cd": 18.0,
			"desc": "Recupera 40% do HP maximo"},
		{"id": "escudo", "nome": "Escudo Arcano", "tecla": "R", "mana": 35, "cd": 16.0, "city2": true,
			"desc": "Reduz o dano recebido em 50% por 10 segundos"},
		{"id": "nevasca", "nome": "Nevasca", "tecla": "G", "mana": 55, "cd": 22.0, "city2": true,
			"desc": "Congela e causa dano em todos os monstros ao redor"},
	],
}

# Critico: chance base 5% + 0.5% por nivel da skill de combate; dano x2
static func crit_chance(skill_level: int) -> float:
	return 0.05 + skill_level * 0.005

# Skills avancadas (city2 == true) exigem ter pisado na city2 nesta vida
static func skill_unlocked(sk: Dictionary) -> bool:
	if not sk.get("city2", false):
		return true
	return GameManager.city2_unlocked

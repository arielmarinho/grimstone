class_name SkillsDB
extends Object
## Skills ativas por classe (estilo Rucoy): 4 skills por arma.
## Q/E = basicas (disponiveis desde o inicio).
## R/G = avancadas — desbloqueiam ao chegar na VILA (city2).
## IDs casam com os handlers em player.gd _use_skill().

const SKILLS = {
	"sword": [
		{"id": "golpe", "nome": "Golpe Poderoso", "tecla": "Q", "mana": 20, "cd": 8.0,
			"desc": "O proximo ataque causa 3x de dano"},
		{"id": "rodopio", "nome": "Rodopio", "tecla": "E", "mana": 35, "cd": 12.0,
			"desc": "Golpeia todos os monstros ao redor (dano x2)"},
		{"id": "golpe_duplo", "nome": "Golpe Duplo", "tecla": "R", "mana": 45, "cd": 14.0,
			"desc": "Os proximos 2 ataques acertam 2 vezes (o 2o golpe causa 50%)"},
		{"id": "investida", "nome": "Investida", "tecla": "G", "mana": 40, "cd": 12.0,
			"desc": "Avanca ate o alvo e causa dano x2.5"},
	],
	"axe": [
		{"id": "furia", "nome": "Furia", "tecla": "Q", "mana": 25, "cd": 15.0,
			"desc": "+80% de dano por 8 segundos"},
		{"id": "atordoar", "nome": "Atordoar", "tecla": "E", "mana": 30, "cd": 14.0,
			"desc": "Atordoa o monstro por 3s e causa dano"},
		{"id": "bersek", "nome": "Berserk", "tecla": "R", "mana": 50, "cd": 20.0,
			"desc": "+150% de dano por 10 segundos"},
		{"id": "terremoto", "nome": "Terremoto", "tecla": "G", "mana": 55, "cd": 18.0,
			"desc": "Dano x2.5 em area e atordoa 2s todos ao redor"},
	],
	"bow": [
		{"id": "certeiro", "nome": "Tiro Certeiro", "tecla": "Q", "mana": 20, "cd": 8.0,
			"desc": "A proxima flecha e critico garantido (x2)"},
		{"id": "chuva", "nome": "Chuva de Flechas", "tecla": "E", "mana": 40, "cd": 16.0,
			"desc": "Acerta todos os monstros ao redor (gasta 5 flechas)"},
		{"id": "precisao", "nome": "Precisao", "tecla": "R", "mana": 45, "cd": 18.0,
			"desc": "As proximas 3 flechas sao criticas garantidas"},
		{"id": "tiro_multi", "nome": "Tiro Multiplo", "tecla": "G", "mana": 50, "cd": 16.0,
			"desc": "Flecha explosiva x2.5 no alvo (gasta 2 flechas)"},
	],
	"staff": [
		{"id": "fogo", "nome": "Bola de Fogo", "tecla": "Q", "mana": 30, "cd": 10.0,
			"desc": "Projeteil gigante que causa 3x de dano"},
		{"id": "cura", "nome": "Cura", "tecla": "E", "mana": 40, "cd": 18.0,
			"desc": "Recupera 40% do HP maximo"},
		{"id": "escudo", "nome": "Escudo Arcano", "tecla": "R", "mana": 50, "cd": 20.0,
			"desc": "-50% de dano recebido por 10 segundos"},
		{"id": "nevasca", "nome": "Nevasca", "tecla": "G", "mana": 60, "cd": 20.0,
			"desc": "Dano x2.2 em area e atordoa 1.5s todos ao redor"},
	],
}

# R/G desbloqueiam ao visitar a VILA (city2) — flag no GameManager
static func skill_unlocked(sk: Dictionary) -> bool:
	var t: String = sk.get("tecla", "Q")
	return not (t == "R" or t == "G") or GameManager.city2_visited

# Critico: chance base 5% + 0.5% por nivel da skill de combate; dano x2
static func crit_chance(skill_level: int) -> float:
	return 0.05 + skill_level * 0.005

class_name SkillsDB
extends Object
## Skills ativas por classe (estilo Rucoy): 2 skills por arma.
## Q = skill primaria, E = skill secundaria. Ativaveis pelo teclado OU botao no HUD.

const SKILLS = {
	"sword": [
		{"id": "golpe", "nome": "Golpe Poderoso", "tecla": "Q", "mana": 20, "cd": 8.0,
			"desc": "O proximo ataque causa 3x de dano"},
		{"id": "rodopio", "nome": "Rodopio", "tecla": "E", "mana": 35, "cd": 12.0,
			"desc": "Golpeia todos os monstros ao redor (dano x2)"},
	],
	"axe": [
		{"id": "furia", "nome": "Furia", "tecla": "Q", "mana": 25, "cd": 15.0,
			"desc": "+80% de dano por 8 segundos"},
		{"id": "atordoar", "nome": "Atordoar", "tecla": "E", "mana": 30, "cd": 14.0,
			"desc": "Atordoa o monstro por 3s e causa dano"},
	],
	"bow": [
		{"id": "certeiro", "nome": "Tiro Certeiro", "tecla": "Q", "mana": 20, "cd": 8.0,
			"desc": "A proxima flecha e critico garantido (3x)"},
		{"id": "chuva", "nome": "Chuva de Flechas", "tecla": "E", "mana": 40, "cd": 16.0,
			"desc": "Acerta todos os monstros ao redor (gasta 5 flechas)"},
	],
	"staff": [
		{"id": "fogo", "nome": "Bola de Fogo", "tecla": "Q", "mana": 30, "cd": 10.0,
			"desc": "Projeteil gigante que causa 3x de dano"},
		{"id": "cura", "nome": "Cura", "tecla": "E", "mana": 40, "cd": 18.0,
			"desc": "Recupera 40% do HP maximo"},
	],
}

# Critico: chance base 5% + 0.5% por nivel da skill de combate; dano x2
static func crit_chance(skill_level: int) -> float:
	return 0.05 + skill_level * 0.005

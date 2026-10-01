# Sprites Grimstone

Regras vigentes (resumo):
- Fundo magenta #FF00FF em toda geração; nunca usar magenta/rosa na paleta do personagem
- Folha 1x4 por animação (idle, walk, attack, hurt, death), uma animação por folha
- Arma embutida no sprite (estilo Rucoy) — sem camada separada
- Classe definida pela arma; partir sempre da folha-mestre canônica aprovada
- Direções: down, up, left (right = espelho no Godot)
- Nomenclatura: knight_<anim>_<dir>_<sufixo>.png; sufixos: base, axe, h_<cor>, t_<cor>
- Paleta de 5 cores (cabelo/túnica): dourado (220,190,100), ruivo (190,80,40), preto (30,30,35), castanho_claro (150,105,60), branco (200,200,205)
- Túnica termina na linha do cinto
- Pipeline: gerar com magenta → chroma key (tol ~60, mediana da borda, dilatação, limpeza de manchas claras) → PNG transparente → normalizar frames (canvas 96, baseline 84)

# GRIMSTONE — Guia do Desenvolvedor

> Documento vivo: atualizado a cada ciclo de trabalho. Qualquer pessoa (você incluído!)
> consegue adicionar conteúdo ao jogo seguindo este guia.

## Estrutura do projeto

```
game/
├── project.godot              # config do jogo (main_scene = title.tscn)
├── icon.svg                   # ícone do jogo
├── scenes/
│   ├── title.tscn             # tela de título
│   ├── main.tscn              # mundo (mapas, HUD, entidades)
│   └── entities/
│       ├── player/player.tscn # player (CharacterBody2D)
│       └── mobs/rat.tscn      # mob genérico (tipo definido por código)
├── scripts/
│   ├── autoload/              # SINGLETONS (registrados no project.godot)
│   │   ├── game_manager.gd    # estado global: level, hp, bag, coins, save/load
│   │   ├── network_manager.gd # multiplayer (ENet, porta 7777)
│   │   ├── items_db.gd        # TODOS os itens + ícones
│   │   ├── equips.gd          # armas (classe = arma) + cores de roupa
│   │   ├── skills_db.gd       # skills ativas por classe + crítico
│   │   ├── tex_helper.gd      # sprites procedurais + mapas desenhados por código
│   │   └── icons_embedded.gd  # fallback de ícones
│   ├── entities/
│   │   ├── player.gd          # movimento, ataque, skills Q/E, flechas, crítico
│   │   ├── mob.gd             # IA dos monstros + tabela TYPES (stats)
│   │   ├── mob_sprites.gd     # desenho procedural dos 8 monstros
│   │   ├── projectile.gd      # flecha/bola de fogo
│   │   ├── coin.gd / drop.gd  # loot no chão
│   │   └── loot_table.gd      # TABLES: o que cada monstro dropa
│   ├── world/
│   │   ├── main.gd            # MAPS: os 4 mapas, transições, lojas, spawners
│   │   ├── colliders.gd       # colisões de cada mapa
│   │   ├── spawners.gd        # SETS: quais mobs nascem em cada mapa
│   │   └── shop.gd            # loja (CATALOG: id → preço)
│   └── ui/
│       ├── hud.gd             # HUD completo (barras, hotbar, skills, mochila...)
│       └── title_screen.gd    # tela de título
└── assets/
    ├── maps/                  # PNGs dos mapas (fallback: procedural)
    ├── icons/                 # PNGs dos ícones de itens
    └── sprites/               # folhas de sprite (fallback: procedural)
```

## RECEITAS — como adicionar coisas

### ➕ Adicionar um ITEM novo
1. `scripts/autoload/items_db.gd` → adicione em `ITEMS`:
   ```gdscript
   "anel": {"nome": "Anel de Força", "tipo": "uso", "cor": Color(0.9,0.7,0.3), "hp": 10, "desc": "..."},
   ```
   Tipos possíveis: `"uso"` (hp/mana), `"arma"` (arma: "sword"|"axe"|"bow"|"staff"), `"municao"`, `"moeda"`.
2. Ícone: coloque PNG 32x32 em `assets/icons/anel.png` (fundo magenta #FF00FF) — ou deixe sem, o fallback desenha por código.
3. Pra vender na loja: `scripts/world/shop.gd` → adicione `"anel": 100` em `CATALOG`.
4. Pra dropar de monstro: `scripts/entities/loot_table.gd` → adicione na lista do monstro.

### ➕ Adicionar um MONSTRO novo
1. `scripts/entities/mob.gd` → adicione em `TYPES`:
   ```gdscript
   "troll": {"hp": 300, "dano": 40, "xp": 250, "vel": 0.9},
   ```
2. `scripts/entities/mob_sprites.gd` → adicione `_draw_troll(...)` no `match` de `draw_mob` (copie de um existente como base).
3. `scripts/entities/loot_table.gd` → adicione `"troll": [...]` em `TABLES`.
4. Spawne num mapa: `scripts/world/spawners.gd` → adicione `{"type": "troll", "pos": Vector2(x, y)}`.

### ➕ Adicionar uma SKILL
1. `scripts/autoload/skills_db.gd` → adicione na lista da classe:
   ```gdscript
   {"id": "investida", "nome": "Investida", "tecla": "R", "mana": 25, "cd": 10.0, "desc": "..."},
   ```
2. `scripts/entities/player.gd` → adicione o efeito no `match sk["id"]` de `_use_skill`.
3. Se for tecla nova (R), adicione botão no HUD: `scripts/ui/hud.gd` → `_build_skill_buttons` (range 2 → 3).

### ➕ Adicionar um MAPA novo
1. `scripts/autoload/tex_helper.gd` → crie `_map_minhaarea()` (copie `_map_forest()` como base) e roteie em `load_map`.
2. `scripts/world/main.gd` → adicione em `MAPS` (texture, player_spawn, exits, spawner, shop opcional).
3. `scripts/world/colliders.gd` → crie o collider do mapa (bordas + obstáculos).
4. `scripts/world/spawners.gd` → crie o SET de mobs do mapa.
5. Ligue a transição: adicione um exit no mapa de origem apontando pro novo.

### ➕ Adicionar cor de roupa/cabelo
`scripts/autoload/equips.gd` → `CLOTHES_COLORS` (cabelo/túnica) ou `PANTS_COLORS` (calça).

### ➕ Mudar balanceamento
- Stats de mob: `mob.gd` → `TYPES`
- Dano de arma: `equips.gd` → `WEAPONS`
- Preços: `shop.gd` → `CATALOG`
- Loot: `loot_table.gd` → `TABLES`
- XP/level: `game_manager.gd` → `xp_for_level()`
- Crítico: `skills_db.gd` → `crit_chance()`

## TECLAS do jogo
| Tecla | Ação |
|---|---|
| 1-4 | Trocar arma (classe) |
| Q / E | Skills da classe |
| B | Mochila |
| C | Roupas (túnica/cabelo/calça) |
| K | Tela de skills |
| T / Y / U | Ciclar túnica / cabelo / calça |
| E (perto da loja) | Abrir loja |
| F | (reservado: fusão de itens) |
| Enter | (reservado: chat online) |

## Validação antes de commitar
```bash
godot --headless --path game --quit-after 600
# critério: 0 linhas "SCRIPT ERROR"
```

## Histórico de versões
- **v0.1** — MVP: cidade, caverna, rato, classes por arma, save
- **v0.2** — mochila, loot, hotbar, morte/respawn, mundo 2x, 4 direções
- **v0.3** — 8 monstros, 4 mapas (city1/city2/floresta/caverna), skills Q/E, flechas, crítico, calça, lojas, tela de título, ícone
- **v0.4** — fundação multiplayer (NetworkManager, ENet 7777) — aguardando polish

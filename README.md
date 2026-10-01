# Grimstone

RPG 2D top-down estilo Tibia/Rucoy, feito em Godot 4, alvo mobile (Play Store / App Store).

## Estrutura
- `game/` — projeto Godot 4.7
  - `assets/` — sprites (player/knight, enemy/rat), HUD e mapas
  - `scenes/` — cenas (world, entities, ui)
  - `scripts/` — GDScript (entities, autoload, ui)
- `docs/adapta-skills/` — skills migradas do Adapta One (estilo visual, sprites, monetização, sistemas)
- `todo.md` — roadmap

## Regras de arte
- Sprites 1x4 por animação, fundo magenta #FF00FF (removido via chroma key)
- Arma embutida no sprite (estilo Rucoy), classe definida pela arma

## Status
MVP em desenvolvimento: cidade 1 + caverna dos ratos com combate.

# Grimstone

RPG 2D top-down estilo Tibia/Rucoy, Godot 4, alvo mobile.

## Jogar (agora)
Abrir a pasta `game/` no **Godot 4.7+** e apertar F5.
- **Clique** para andar; o ataque é automático perto do inimigo
- Tecla **M** alterna entre cidade e caverna dos ratos (teste)
- HUD: vida / mana / XP + nível e mapa atual

## Estrutura
- `game/` — projeto Godot (scripts GDScript; sprites ficam na pasta `assets/` do projeto local)
- `docs/adapta-skills/` — skills migradas do Adapta One

## Regras de arte
- Sprites 1x4 por animação, fundo magenta #FF00FF removido por chroma key
- Arma embutida no sprite (estilo Rucoy), classe definida pela arma
- Texturas carregadas via `Image.load_from_file` (não dependem do cache de importação)

## Próximos passos
Ver `todo.md`.

# Grimstone

RPG 2D top-down estilo Tibia/Rucoy, Godot 4.7, alvo mobile.

## Como jogar
1. `git clone git@github.com:arielmarinho/grimstone.git`
2. Abrir a pasta `game/` no Godot 4.7+ (primeira vez: aguardar import)
3. F5

## Controles
- **Clique** para andar; ataque automático perto do inimigo
- **1-4** troca de arma = troca de classe (Rucoy): Espada/Guerreiro, Machado/Bárbaro, Arco/Arqueiro (flechas), Cajado/Mago (bolas de fogo)
- **T** túnica, **Y** cabelo, **C** painel de customização com preview
- Ande até o **bueiro** (sul da cidade) para descer à caverna dos ratos; a grade (norte da caverna) volta

## Sistemas
- Classes por arma (estilo Rucoy), skills sobem com uso, XP fórmula Tibia-like
- Ratos com IA (vaguear/perseguir/atacar), HP bar, respawn, drop de moedas
- Números de dano flutuantes
- Save/load automático em JSON (posição de mapa, nível, skills, arma, roupas, moedas)
- Sprites reais em `assets/**/*.b64` (base64 das folhas 1x4, decodificadas em runtime pelo TexHelper); fallback procedural se ausentes

## Estrutura
- `game/` — projeto Godot
- `docs/` — skills e notas do pipeline

## Roadmap
Ver `todo.md`.

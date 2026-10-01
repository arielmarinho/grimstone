# Grimstone

RPG 2D top-down estilo Tibia/Rucoy, Godot 4.7, alvo mobile.

## Como jogar (agora)
1. Clonar: `git clone git@github.com:arielmarinho/grimstone.git`
2. Abrir a pasta `game/` no Godot 4.7+
3. F5.

O jogo roda **só com o clone**: se os sprites reais não estiverem presentes, o TexHelper gera gráficos procedurais em runtime.

## Controles
- **Clique** para andar; ataque automático perto do inimigo
- Ande até o **bueiro** no topo da cidade para descer à caverna dos ratos
- Na caverna, ande até a grade para voltar
- HUD: vida / mana / XP + nível e mapa atual

## O que está pronto (Fase 1 — MVP)
- Player: click-to-move, animações (idle/walk/attack/death)
- Ratos: IA (vaguear/perseguir/atacar), HP bar flutuante, dano nos dois lados, morte com XP, respawn
- Skills sobem com uso (Espada/Defesa) — fórmula de XP Tibia-like
- Cidade 1 + caverna dos ratos com transição automática pelo bueiro
- Save/load automático em JSON (dados serializáveis, pronto pra online)
- TexHelper: sprites reais (PNG ou .b64) com fallback procedural

## Próximos passos
Ver `todo.md`.

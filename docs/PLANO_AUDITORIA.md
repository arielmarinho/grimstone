# GRIMSTONE — Plano de Auditoria por Especialistas

> Metodo: cada especialista audita SUA area do jogo do zero, aponta problemas,
> melhora ate aprovar. So entao passa pra proxima area. O usuario valida cada uma no final.

## Ordem de auditoria (do mais visivel pro menos)

| # | Area | Especialista | Escopo | Status |
|---|---|---|---|---|
| 1 | **Combate & Feedback** | gs-game-design + gs-pixel-art | flash de dano, numeros flutuando, morte, level up | OK (ciclo 1) |
| 2 | **Player & Skills** | gs-game-design | 4 classes, Q/E/R/G, flechas, critico, customizacao | implementado ciclo 2 (aguarda usuario) |
| 3 | **Monstros & IA** | gs-game-design | 8 tipos, IA wander/aggro/attack, loot | OK (ciclo 4b) |
| 4 | **Mapas & Mundo** | gs-level-design | 4 mapas, transicoes, colisores, spawners | implementado ciclo 5 (aguarda usuario) |
| 5 | **Itens & Economia** | gs-combat-balance | itens, lojas, precos, drops, pocoes | implementado ciclo 6 (aguarda usuario) |
| 6 | **UI/UX** | gs-ui-ux | HUD, mochila, paineis, titulo, teclas | pendente |
| 7 | **Balanceamento** | gs-combat-balance | TTK, curvas, economia fecha | pendente |
| 8 | **Audio** | gs-audio | (area nova — implementar do zero) | pendente |
| 9 | **Multiplayer** | gs-netcode | fundacao, mobs autoritativos | pendente (apos polish) |
| 10 | **QA final** | gs-qa-testing | fluxo completo, release | pendente |

## Regra do usuario
- Ciclos de 10 min; se nao terminar ou ficar ruim, o proximo ciclo APRIJORA o mesmo item
- Especialista so avanca quando achar que esta BOM
- Usuario valida cada area no final

## Log de auditoria

### Area 1 — Combate & Feedback (02:51-03:01) OK

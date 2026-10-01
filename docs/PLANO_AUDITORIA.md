# GRIMSTONE — Plano de Auditoria por Especialistas

> Método: cada especialista audita SUA área do jogo do zero, aponta problemas,
> melhora até aprovar. Só então passa pra próxima área. O usuário valida cada uma no final.

## Ordem de auditoria (do mais visível pro menos)

| # | Área | Especialista | Escopo | Status |
|---|---|---|---|---|
| 1 | **Combate & Feedback** | gs-game-design + gs-pixel-art | flash de dano, números flutuando, morte, level up | ✅ APROVADO (ciclo 1) |
| 2 | **Player & Skills** | gs-game-design | 4 classes, Q/E, flechas, crítico, customização | ⬜ |
| 3 | **Monstros & IA** | gs-game-design | 8 tipos, IA wander/aggro/attack, loot | ⬜ |
| 4 | **Mapas & Mundo** | gs-level-design | 4 mapas, transições, colisores, spawners | ⬜ |
| 5 | **Itens & Economia** | gs-combat-balance | itens, lojas, preços, drops, poções | ⬜ |
| 6 | **UI/UX** | gs-ui-ux | HUD, mochila, painéis, título, teclas | ⬜ |
| 7 | **Balanceamento** | gs-combat-balance | TTK, curvas, economia fecha | ⬜ |
| 8 | **Áudio** | gs-audio | (área nova — implementar do zero) | ⬜ |
| 9 | **Multiplayer** | gs-netcode | fundação, mobs autoritativos | ⬜ (após polish) |
| 10 | **QA final** | gs-qa-testing | fluxo completo, release | ⬜ |

## Regra do usuário
- Ciclos de 10 min; se não terminar ou ficar ruim, o próximo ciclo APRIJORA o mesmo item
- Especialista só avança quando achar que está BOM
- Usuário valida cada área no final

## Log de auditoria
### Área 1 — Combate & Feedback (02:51-03:01) ✅
- Mapeado: dano era só número na barra, SEM flash, SEM números flutuantes, morte instantânea
- Implementado: flash branco no sprite ao levar hit (0.15s), número de dano flutuante (sobe e some), morte com fade (corpo desvanece 0.8s+1.2s), level up com anel dourado expandindo + texto
- Validado: Godot headless 0 erros

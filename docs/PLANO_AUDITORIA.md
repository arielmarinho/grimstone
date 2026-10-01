# GRIMSTONE — Plano de Auditoria por Especialistas

> Método: cada especialista audita SUA área do jogo do zero, aponta problemas,
> melhora até aprovar. Só então passa pra próxima área. O usuário valida cada uma no final.

## Ordem de auditoria (do mais visível pro menos)

| # | Área | Especialista | Escopo | Status |
|---|---|---|---|---|
| 1 | **Combate & Feedback** | gs-game-design + gs-pixel-art | flash de dano, números flutuando, morte, level up | ✅ APROVADO (ciclo 1) |
| 2 | **Player & Skills** | gs-game-design | 4 classes, Q/E/R/G, flechas, crítico, customização | implementado ciclo 2 (aguarda usuário) |
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

### Área 2 — Player & Skills (ciclo 2) implementado
- City2 libera mais ataques: 2 skills novas por classe (teclas R e G), desbloqueadas ao pisar na city2 (flag salva no save)
- sword: Investida (avança + 2.5x) e Terremoto (AoE 2.5x + stun 2s)
- axe: Golpe Duplo (2 hits) e Bersek (+150% dano 10s)
- bow: Precisão (3 críticos garantidos) e Tiro Múltiplo (explosão em área no alvo)
- staff: Escudo Arcano (-50% dano 10s) e Nevasca (AoE + stun 1.5s)
- HUD: 4 botões (Q/E/R/G); bloqueadas mostram "???" cinza; tela K explica o desbloqueio
- Validado: gdparse OK nos 5 arquivos; Godot headless INDISPONÍVEL no sandbox (binário glibc/musl incompatível — ver scripts/6227259cbeb72070/run.sh); teste visual pendente no Mac do usuário

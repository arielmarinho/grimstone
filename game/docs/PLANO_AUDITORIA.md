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
| 5 | **Itens & Economia** | gs-combat-balance | itens, lojas, precos, drops, pocoes | OK (ciclo 6) |
| 6 | **UI/UX** | gs-ui-ux | HUD, mochila, paineis, titulo, teclas | implementado ciclo 7 (aguarda usuario) |
| 7 | **Balanceamento** | gs-combat-balance | TTK, curvas, economia fecha | OK (ciclo 8) |
| 8 | **Audio** | gs-audio | AudioManager procedural, 12 SFX, 3 musicas | OK (ciclo 9) |
| 9 | **Multiplayer** | gs-netcode | fundacao, mobs autoritativos | fase 2 OK ciclo 14 + interpolacao/lag 150ms OK ciclo 15 (server+A+B localhost PASSOU) — teste no Mac pendente |
| 10 | **QA final** | gs-qa-testing | fluxo completo, release | teste multiplayer real PASSOU ciclo 13+15 (server+2 clientes localhost: registro, chat, posicao, dano em mob) — teste no Mac pendente |
| 11 | **Raridade & Fusao** | gs-game-design | 5 tiers, loot com tier, fusao painel F | RARIDADE+FUSAO+ESTIMATIVAS implementadas ciclos 18-20 (v0.6.0/v0.6.1/v0.6.2) — aguarda usuario |
| 12 | **Quests & NPC** | gs-game-design | missoes de caca com NPC, recompensas | implementado ciclo 21 (v0.6.3) — aguarda usuario |
| 13 | **Banco/Depósito** | gs-game-design | NPC banco, depositar/sacar itens | implementado ciclo 23 (v0.6.5) — aguarda usuario |
| 14 | **Bestiário** | gs-game-design | registro de caça, ficha dos 8 mobs, tecla N | implementado ciclo 24 (v0.6.6) — aguarda usuario |
| 15 | **Decoracao** | gs-level-design | postes, flores, barris, bandeiras, barraca | implementado ciclo 26 (v0.6.8) — aguarda usuario |
| 16 | **Sprites direcionais** | gs-pixel-art | mobs com down/up/side reais, rato procedural | implementado ciclo 27 (v0.6.9) — aguarda usuario |

## Regra do usuario
- Ciclos de 10 min; se nao terminar ou ficar ruim, o proximo ciclo APRIJORA o mesmo item
- Especialista so avanca quando achar que esta BOM
- Usuario valida cada area no final

## Log de auditoria
### Area 16 — Sprites direcionais dos mobs (ciclo 27, v0.6.9) implementado
- mobs com down/up/side REAIS (up = costas sem rosto, side = perfil com flip_h); FIX grave: rato INVISIVEL em up/side (so existia PNG "down") — rato procedural completo nas 3 direcoes + death
- Validacao VISUAL headless: tests/preview_mobs.gd (folha 8 mobs x 3 direcoes) + tests/preview_mobs2.gd (up/side ampliados 2x) — direcoes confirmadas distintas
- Headless 0 erros de script; GitHub sincronizado (mob.gd/mob_sprites.gd/preview_mobs.gd blob SHA byte-exato)
- Pendente: teste no Mac do usuario
### Area 15 — Decoracao (ciclo 26, v0.6.8) implementado
- scripts/world/decor.gd NOVO: postes de luz (braco+lampada+glow aditivo), canteiros de flores (seed fixa), barris (aros de metal), caixotes (diagonal), bandeiras onduladas nos portoes, barraca de feira (toldo listrado + mercadorias)
- Solidos com colisor (StaticBody2D r=26 no decor + rects casando no colliders.gd); integrado ao switch_map apos build_colliders
- Headless 0 erros; blob SHA verificado 3/3 byte-exato (decor/main/colliders)
- Pendente: teste no Mac do usuario
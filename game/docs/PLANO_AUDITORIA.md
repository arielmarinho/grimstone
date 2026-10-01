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
| 17 | **Integridade GitHub↔local** | gs-qa-testing | auditoria blob SHA de todos os arquivos | OK ciclo 28 (v0.6.10) — 32/36 byte-exatos, 4 = encoding MCP, nenhum corrompido |
| 18 | **Checklist teste Mac** | gs-qa-testing | TESTE_MAC.md consolidado + regressao 7/7 testes | OK ciclo 29 (v0.6.10) — aguarda usuario testar |

## Regra do usuario
- Ciclos de 10 min; se nao terminar ou ficar ruim, o proximo ciclo APRIJORA o mesmo item
- Especialista so avanca quando achar que esta BOM
- Usuario valida cada area no final

## Log de auditoria
### Area 18 — Checklist de teste no Mac (ciclo 29, v0.6.10) CONCLUIDA
- Regressao completa: 7/7 testes unitarios OK (fusion/estimates/quests/food/bank/bestiary/runes), headless 0 erros
- docs/TESTE_MAC.md criado e pushado (blob SHA byte-exato) — 13 secoes cobrindo v0.5.6..v0.6.10
- Fila: teste no Mac do usuario OU build APK
### Area 17 — Auditoria de integridade GitHub↔local (ciclo 28, v0.6.10) CONCLUIDA
- Auditoria completa de TODOS os arquivos do repo via blob SHA (git hash-object local vs get_file_contents remoto): 32/36 byte-exatos
- 4 divergencias = encoding de acentos + newline do MCP (game_manager semanticamente completo, 12/12 features) — NENHUM arquivo corrompido/truncado no remoto
- Godot headless 0 erros
### Area 16 — Sprites direcionais dos mobs (ciclo 27, v0.6.9) implementado
- mobs com down/up/side REAIS (up = costas sem rosto, side = perfil com flip_h); FIX grave: rato INVISIVEL em up/side (so existia PNG "down") — rato procedural completo nas 3 direcoes + death
- Validacao VISUAL headless: tests/preview_mobs.gd (folha 8 mobs x 3 direcoes) + tests/preview_mobs2.gd (up/side ampliados 2x) — direcoes confirmadas distintas
- Headless 0 erros de script; GitHub sincronizado (mob.gd/mob_sprites.gd/preview_mobs.gd blob SHA byte-exato)
3:### Area 15 — Decoracao das cidades (ciclo 26, v0.6.8) implementado
- postes de luz com braco+lampada+glow aditivo, canteiros de flores (seed 77), barris/caixotes com colisor, bandeiras nos portoes, barraca de feira
- decor.gd novo integrado ao switch_map apos build_colliders; headless 0 erros
### Area 14 — Bestiario (ciclo 24, v0.6.6) implementado
- GameManager.BESTIARY_INFO (8 mobs: nome/onde/lore), bestiary_kill/seen persistidos, tecla N, nao vistos = "???", kills offline+online (RPC mob_reward), NOVO JOGO zera
- BESTIARY_TEST_OK; headless 0 erros
### Area 13 — Banco/Deposito (ciclo 23, v0.6.5) implementado
- NPC banco nas 2 cidades (tecla T), depositar/sacar (libera mochila 20), tier preservado ("espada#2" slot proprio), save persistido, NOVO JOGO zera
- BANK_TEST_OK (8 casos); headless 0 erros
### Area 12 — Quests & NPC (ciclo 21, v0.6.3) implementado
- 6 missoes de caca em cadeia (ratos→esqueletos), NPC Mestre das Missoes nas 2 cidades (tecla J), recompensas moedas+xp, save persistido, offline+online (mob_type no _rpc_mob_reward)
- QUEST_TEST_OK; headless 0 erros
### Area 11 — Raridade & Fusao (ciclos 18-20, v0.6.0/v0.6.1/v0.6.2) implementado
- rarity.gd 5 tiers (Comum 70% → Lendario 0.5%, +10%/+25%/+50%/+100% dano), chave "espada#tier", loot com RARITY_BONUS por mob, aura colorida no drop + "RARO!"
- fusao: 3 iguais do mesmo tier + 50 moedas = tier seguinte (lendario nao funde), UI no painel B
- estimativas na tela K: skill_xp_need lvl^2*5, taxas 240/60/450 xp/min, "up em ~Xmin" + "Proximo LEVEL em ~Ymin"
- FUSION_TEST_OK + ESTIMATE_TEST_OK; headless 0 erros
### Area 10 — QA final (ciclos 13+15) teste multiplayer real PASSOU
- server + 2 clientes localhost: registro simultaneo, chat A<->B, sync posicao 15Hz, dano em mob via RPC validado, lag 150ms OK
- Harness scripts/tests/net_test.gd (--nettest=server|clientA|clientB), log em arquivo com flush
### Area 9 — Multiplayer (ciclos 14-15) fase 2 OK
- mobs autoritativos (MobAuthority, snapshot 10Hz, espelhos NetMob interpolados ~120ms atras), dano via RPC validado no servidor (range), XP/loot pro ultimo golpe (Rucoy)
- interpolacao por buffer + lag artificial --netlag=<ms> testado
### Area 8 — Audio (ciclo 9) OK
- AudioManager 100% procedural (12 SFX + 3 musicas chiptune em GDScript, zero binarios), pool 8 players, crossfade por mapa
### Area 7 — Balanceamento (ciclo 8) OK
- hp/mana max funcao do level (save nunca desincroniza), level-up Tibia (+30/+15 em combate), cura fora de combate 5%/2s, XP mobs iniciais +75%, pocoes P 15/18
### Area 6 — UI/UX (ciclo 7) implementado
- 4 bugs de HUD corrigidos + cooldown numerico Q/E/R/G + feedback na tela + loja/titulo polidos
### Area 5 — Itens & Economia (ciclo 6) OK
- arco/cajado equalizados, dano endgame -30%, loot +30%, curva skill XP quadratica, variancia de dano ±10%, pocoes G dropam
### Area 4 — Mapas & Mundo (ciclo 5) implementado
- colliders refeitos (portoes=arte, abertura 224px), fix grave saida N da floresta, city2 zona segura, REGEN Tibia (mana sempre, HP fora de combate)
### Area 3 — Monstros & IA (ciclo 4b) OK
- hit sem dano em player morto, range 110px no golpe, leash 700px, dummy simplificado
### Area 2 — Player & Skills (ciclo 2) implementado
- skills R/G por classe (8 skills), desbloqueio na city2 (flag persistida), HUD 4 slots Q/E/R/G, dummy de treino
### Area 1 — Combate & Feedback (ciclo 1) OK
- flash de dano no mob, numeros flutuantes, morte com fade, level up com anel dourado

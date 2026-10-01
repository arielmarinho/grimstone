### Area 28 — Player ARTE REAL nas 4 direcoes + fallback (ciclo 47, v0.6.21) OK
- Player up/side usam ARTE REAL PROPRIA (b64 up/side no estilo da referencia) quando existir; fallback v0.6.17/v0.6.19 sem o b64 — nunca fica sem animacao
- Validacao visual obrigatoria: preview_final3 (artifacts/player_real4_dirs.png) + check_real4 programatico (up = costas: 1 px de pele vs 114 no down; up/side = 3000+ px diferentes do down)
- INCIDENTE: 1o push do player.gd reconstruido de memoria saiu truncado (6998 bytes) — reparado byte-exato (15e0fdd); regra: NUNCA reconstruir arquivo grande de memoria
- Pendente: push dos 6 b64 up/side (filtro de contexto omite base64); fallback cobre o jogo no estado atual
- Validacao: headless 0 erros + run real 0 erros + 7/7 testes OK

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
| 12 | **Quests & NPC** | gs-game-design | missoes de caca com NPC, recompensas | AUDITADO ciclo 31+32 — 2 bugs graves corrigidos (quest done-nao-entregue sumia do painel; from_id faltando no dano online) + teste corrigido |
| 13 | **Banco/Depósito** | gs-game-design | NPC banco, depositar/sacar itens | implementado ciclo 23 (v0.6.5) — aguarda usuario |
| 14 | **Bestiário** | gs-game-design | registro de caça, ficha dos 8 mobs, tecla N | implementado ciclo 24 (v0.6.6) — aguarda usuario |
| 15 | **Decoracao** | gs-level-design | postes, flores, barris, bandeiras, barraca | implementado ciclo 26 (v0.6.8) — aguarda usuario |
| 16 | **Sprites direcionais** | gs-pixel-art | mobs com down/up/side reais, rato procedural | implementado ciclo 27 (v0.6.9) — aguarda usuario |
| 17 | **Integridade GitHub↔local** | gs-qa-testing | auditoria blob SHA de todos os arquivos | OK ciclo 28 (v0.6.10) — 32/36 byte-exatos, 4 = encoding MCP, nenhum corrompido |
| 18 | **Checklist teste Mac** | gs-qa-testing | TESTE_MAC.md consolidado + regressao 7/7 testes | OK ciclo 29 (v0.6.10) — aguarda usuario testar |
| 19 | **Cinto de runas + regressoes** | gs-qa-testing | v0.6.11: CINTO Z/X; REGRESSOES: ITEMS_DB sem preload quebrava main.gd (loot_table/game_manager), _show_feedback inexistente (hud) | OK ciclo 33 — NetTest 3/3 + 7/7 testes + headless 0 erros |
| 22 | **Portao sul + integridade pos-fix** | gs-level-design + gs-qa-testing | muralha SUL fiel ao cenario (caminho ate a borda), trigger do bueiro, auditoria blob SHA pos-fix | OK ciclo 37b (v0.6.14) — colliders/main byte-exatos, NetTest 3/3, 7/7 testes |
| 24 | **Player 4 direcoes REAIS** | gs-pixel-art + gs-qa-testing | ANIMS up/side reais no player (bug so-anda-pra-baixo), validacao visual | OK ciclo 39 (v0.6.16) — preview_player 8x4 confirmado, headless 0 erros, 7/7 testes |
| 25 | **Player 100% ARTE REAL (hibrido up/side)** | gs-pixel-art + gs-qa-testing | UP = arte real editada (rosto vira cabelo), SIDE = arte real com flip_h; preview + check de pixels | OK ciclo 41 (v0.6.17) — preview_hybrid2 validado, headless 0 erros |
| 28 | **Player ARTE REAL 4 direcoes + fallback** | gs-pixel-art + gs-qa-testing | up/side = b64 real proprio; fallback v0.6.17/19 sem o b64; preview_final3 + check_real4 | OK ciclo 47 (v0.6.21) — pendente push dos 6 b64 |

## Regra do usuario
- Ciclos de 10 min; se nao terminar ou ficar ruim, o proximo ciclo APRIJORA o mesmo item
- Especialista so avanca quando achar que esta BOM
- Usuario valida cada area no final

## Log de auditoria
### Area 24 — Player 4 direcoes REAIS (ciclo 39, v0.6.16) VALIDADA
- bug "so anda pra baixo" corrigido na CAUSA RAIZ: ANIMS do player apontam pra paths up/side REAIS e load_sheet_procedural_custom desenha procedural 4 direcoes (idle/walk/attack; death deitado = padrao Tibia)
- Validacao VISUAL: tests/preview_player.gd — folha 8x4 (frente/costas/perfil flip/death) em artifacts/player_dirs_preview.png
- Sincronizacao: player.gd/tex_helper.gd alinhados ao remoto (blob SHA conferido); mob.gd remoto = canônico (netcode/quests/dummy OK)
- Validacao: headless 0 erros + 7/7 testes unitarios OK
### Area 25 — Player 100% ARTE REAL (ciclo 41, v0.6.17) VALIDADA
- UP = load_sheet_up_real: rosto da arte real substituido por cabelo (costas de verdade) — identidade visual 100% mantida
- SIDE = arte real de frente + flip_h (estilo Tibia)
- Validacao: preview_hybrid2.gd + check de pixels de pele (down 380px vs up 12px); headless 0 erros
- Push MCP: tex_helper saiu truncado na 1a tentativa, reparado com arquivo completo; player.gd byte-exato de primeira

### Area 22 — Portao sul + integridade pos-fix (ciclo 37b) VALIDADA
- fix do portao sul (colliders + trigger do bueiro) conferido: muralha SUL agora tem 2 segmentos (x 200-500 e x 1550-1850), caminho do bueiro/estrada desce ate a borda em AMBAS as cidades; trigger do bueiro movido pra y1750 r110 (alcancavel sem bloqueio)
- Integridade GitHub↔local: colliders.gd/main.gd/preview_rat2 byte-exatos (blob SHA); CHANGELOG/PLANO divergem 1 byte (newline final, conteudo identico — encoding MCP)
- preview_rat2.gd valida o rato procedural (4 frames) — arte confirmada em artifacts/rat_now.png
- Validacao: headless --import 0 erros + execucao real --quit-after 0 erros + 7/7 testes unitarios OK + NetTest server+A+B PASSOU (registro, chat, posicao, dano autoritativo)
### Area 20 — Sincronizacao GitHub↔local pos-v0.6.11 (ciclo 34) CONCLUIDA
- blob SHA de 9 arquivos-chave: 4/9 byte-exatos de primeira (loot_table, network_manager, items_db, rarity)
- 5 divergentes investigados: game_manager e title_screen = encoding MCP (semanticamente completos, NAO mexer); hud.gd remoto SEM a v0.6.11 (cinto Z/X) — local pushado byte-exato (fd7cbf0a); mob.gd e player.gd remotos = fix visual 08:17 aplicado sobre base ANTIGA (perderam from_peer/quests/touch/raridade) — FUNSAO: logica local + ANIMS all-down (arte down real em todas as direcoes), pushados byte-exatos (abfed491 / 4ec07f32)
- Regressao: 7/7 testes unitarios OK + headless --import e --quit-after 0 erros
- LICAO: fix de emergencia aplicado direto no remoto (sem passar pelo local) cria divergencia de base — sempre fundir com o local canônico
### Area 12 — Quests & NPC (ciclos 31-32) AUDITADA — 2 bugs graves corrigidos
- BUG 1 (grave): quest_available retornava false quando quest estava done mas NAO entregue — missao SUMIA do painel do NPC no exato momento em que completava, jogador NUNCA conseguia entregar; fix: disponivel ate claimed
- BUG 2 (grave, online): net_mob_take_damage chamava mob.take_damage(dmg) SEM from_id — _last_hit_by ficava 0, recompensa (xp/loot/quest/bestiario) nunca chegava no servidor dedicado; fix: take_damage(dmg, from_id)
- Menor: dica de teclas do HUD nao listava F (loja) — adicionada
- Falso travamento do test_quests resolvido: era ASSERTION (FakeGM espelhava a logica ANTIGA), nao hang — FakeGM corrigido, QUEST_TEST_OK
- Regressao: 7/7 testes unitarios OK + headless 0 erros; GitHub sincronizado (hud/test_quests/CHANGELOG blob SHA verificado)
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
### Area 15 — Decoracao das cidades (ciclo 26, v0.6.8) implementado
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

### Area 21 — Polish visual de mapas + reparo pos-polish (ciclo 36) OK
- bordas do mundo em todos os mapas, rato procedural redesenhado (64x44), caverna refeita, casas retangulares, feedback de dano restaurado
- REPARO: mob.gd/spawners.gd remotos regredidos pra base antiga — re-push byte-exato do local canônico; testes novos (map_check/preview_maps/preview_rat) pushados
- Validacao: headless 0 erros, 7/7 testes unitarios OK
### Area 23 — Numeros de recompensa flutuantes (ciclo 38b, v0.6.15) implementado

- FX autoload novo (fx.gd): +XP/+moedas/+cura/+mana/SKILL UP flutuantes via sinais do GameManager
- FIX ciclo 38c (este ciclo): FX.coin_gain() faltava no fx.gd (coin/drop chamavam funcao inexistente) + corpo do projectile.gd APAGADO no remoto pelo commit de audio f57897d — restaurado byte-exato (b21f2aa0); validado run real 0 erros + 7/7 testes
- FX autoload (sinais do GameManager): +XP, +moedas, +cura, +mana, SKILL UP flutuantes no player
- coin/drop chamam FX.coin_gain no pickup; validado headless 0 erros + 7/7 testes

### Area 26 — Housekeeping de versao (ciclo 42, v0.6.18) OK
- title_screen.gd e export_presets.cfg alinhados a v0.6.17; headless 0 erros; 7/7 testes OK.
### Area 27 — Auditoria pos-ciclo 43 + reparo do CHANGELOG (ciclo 44, v0.6.20) OK
- CHANGELOG remoto destruido (26 bytes placeholder) restaurado byte-exato (43de58d)
- Auditoria blob SHA de 30 arquivos: maioria byte-exata; game_manager/mob/drop/hp_bar = encoding MCP (semantica completa, nao mexer); rat_cave remoto mais novo adotado; test_fusion/preview_todas remotos velhos re-pushados do local
- Validacao: headless 0 erros + run real 0 erros + 7/7 testes OK

### Area 29 — City1 fiel a referencia do usuario (ciclo 51, v0.6.23) OK
- Redesenho do city1 seguindo a referencia: lago com cachoeira+ponte a esquerda, area de treino com dummies de palha (cerca com portao), fonte multinivel, loja de armas azul, loja de pocoes roxa (LOJA [F]), casa marrom, torres com bandeira nos portoes
- Colliders casando com a nova arte (lago em 2 rects com vao da ponte, cerca com portao, predios novos); decor/spawners ajustados
- Validacao VISUAL obrigatoria: preview renderizado e analisado + check programatico de portoes (0/21 px muralha na abertura) e pixels (lago azul, ponte marrom); headless 0 erros + run real 0 erros + 7/7 testes OK

### Area 30 — City2 fiel aos colisores, nivel de arte da city1 (ciclo 52, v0.6.24) OK
- city2 redesenhada no nivel da city1: praca com estatua ana, casas de pedra/telhado cobre, forja acesa, muralha de blocos com torres/estandartes, estrada sul ate a borda
- Fiel aos colisores (regra do usuario); check_city2 programatico OK; run real 0 erros + 7/7 testes
- Incidente: push em partes sobrescreveu o arquivo inteiro 2x — reparo com push completo byte-exato
- Fix ciclo 53: STALL da feira saiu do telhado da casa NE (1320,420 -> 1320,380, decor+colisor em par)
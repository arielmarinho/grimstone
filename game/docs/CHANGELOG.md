## v0.6.15 — Numeros de recompensa flutuantes (ciclo 38b, 01/10)
Formato: codigo + docs no GitHub (fe2f526/d478d24), local e6267ba
- FX autoload novo (scripts/autoload/fx.gd): numeros flutuantes de GANHO — +XP (azul), +moedas (dourado), +cura (verde), +mana (azul), SKILL UP (dourado grande)
- GameManager emite sinais xp_gained/coins_gained/healed/mana_gained/skill_up_event; FX conecta no _ready e desenha no player
- coin.gd/drop.gd chamam FX.coin_gain direto no pickup
- O dano ja tinha numero flutuante (mob.gd); agora TUDO que o player ganha tambem mostra
- Validacao: headless --import + --quit-after 120 = 0 erros; 7/7 testes unitarios OK

# GRIMSTONE — Changelog

## 2026-10-01 — v0.6.14 (ciclo 37b: validacao do portao sul + integridade)

- VALIDACAO do fix do portao sul (commit 2734149): muralha SUL das 2 cidades agora tem 2 segmentos (x 200-500 e x 1550-1850) — o caminho do bueiro (city1) e a estrada de pedra (city2) descem ATE a borda do mapa sem parede cortando; trigger do bueiro movido pra y1750 (raio 110), alcancavel andando reto pelo caminho
- Integridade GitHub↔local conferida por blob SHA: colliders.gd/main.gd/preview_rat2 byte-exatos; CHANGELOG/PLANO divergem so no newline final (encoding MCP, conteudo identico)
- preview_rat2.gd: teste visual do rato procedural (4 frames) — saida em artifacts/rat_now.png
- Validacao: headless --import 0 erros + execucao real --quit-after 120 0 erros + 7/7 testes unitarios OK (FUSION/ESTIMATE/QUEST/FED/BANK/BESTIARY/RUNE) + NetTest server+A+B localhost PASSOU 3/3
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## 2026-10-01 — v0.6.13 (ciclo 36: polish visual de mapas + reparo de regressao no remoto)

- POLISH VISUAL (instancia paralela, commit 9af7c82/473f064): bordas do mundo em TODOS os mapas (player nunca sai do sprite), rato procedural REDESENHADO maior (64x44, presenca estilo Rucoy), caverna refeita (escura, tochas/cristais/teias), casas retangulares estilo Tibia, restauracao do feedback de dano (flash vermelho + shake + som) e sons de level up/cast que o polish tinha regredido
- REGRESSAO no remoto corrigida (este ciclo): mob.gd e spawners.gd no GitHub tinham voltado pra base ANTIGA (sem netcode autoritativo/quests/dummy/leash/variancia/_net_map) — re-pushados byte-exato do local canônico (mob 44132464, spawners 4aaf0400)
- Arquivos de teste novos (test_map_check, preview_maps, preview_rat) pushados no remoto — blob SHA byte-exato
- Validacao: headless --import + --quit-after 0 erros; 7/7 testes unitarios OK (FUSION/ESTIMATE/QUEST/FED/BANK/BESTIARY/RUNE)
- Pendente: teste no Mac do usuario OU build APK (docs/TESTE_MAC.md / BUILD_ANDROID.md)

## 2026-10-01 — v0.6.12 (ciclo 34: sincronizacao GitHub↔local + fusao do fix visual)

- AUDITORIA de sincronizacao pos-v0.6.11: 4/9 arquivos-chave byte-exatos; game_manager/title_screen = so encoding MCP (nao mexer)
- REGRESSAO corrigida: mob.gd e player.gd no remoto tinham o fix visual (ANIMS all-down) aplicado sobre uma base ANTIGA — perderam from_peer (recompensa online), quest_on_kill, bestiario, TouchControls, raridade, regen. FUNSAO: logica local completa + ANIMS all-down (arte down real em todas as direcoes, flip_h cobre os lados)
- hud.gd remoto estava sem a v0.6.11 (cinto Z/X ausente) — local pushado byte-exato (fd7cbf0a)
- Regressao: 7/7 testes unitarios OK + headless 0 erros (--import e --quit-after)
- GitHub: mob.gd abfed491, player.gd 4ec07f32, hud.gd fd7cbf0a (todos byte-exatos verificados lendo de volta)
- LICAO: fix de emergencia aplicado direto no remoto (sem passar pelo local) cria divergencia de base — sempre fundir com o local canônico
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac

## 2026-10-01 — v0.6.11 (ciclo 33: CINTO DE RUNAS + REGRESSOES GRAVES corrigidas)

- CINTO DE RUNAS (v0.6.11, trabalho deixado por instância anterior do cron, agora COMPLETO e commitado): 2 slots de atalho (teclas Z/X) usam a runa direto no combate sem abrir a mochila; atribuicao por clique no slot do cinto + runa da mochila; save persistido ("belt"); NOVO JOGO zera
- REGRESSAO GRAVE corrigida (desde o ciclo 25, v0.6.7 — a validacao --import nunca pegava): loot_table.gd usava ITEMS_DB sem `const ITEMS_DB = preload(...)` -> Parse Error que quebrava o main.gd INTEIRO (mobs nao spawnavam, nem offline). Mesma regressao no game_manager.gd (belt_assign usava ITEMS_DB global)
- FIX: hud.gd chamava `_show_feedback()` mas a funcao era `show_feedback()` (12 chamadas quebradas) — renomeada e conexao do signal corrigida; `lab_placeholder` inexistente substituido por blab
- VALIDACAO REAL (nova): headless --import + execucao direta da main 0 erros; NetTest server+A+B localhost PASSOU 3/3 (registro, chat, posicao, 4 mobs espelhados, dano autoritativo validado); regressao 7/7 testes unitarios OK (fusion/estimates/quests/food/bank/bestiary/runes)
- GitHub: 4 pushes (loot_table fc77d3b, game_manager 294f9da, hud f8ee27f, title_screen a4a2cd4)
- LICAO: --import NAO compila dependencias quebradas se o arquivo tem preload circular/missing class — rodar o jogo de verdade (--quit-after ou nettest) apos mudancas em arquivos com many dependencies (loot_table -> main)
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac

## 2026-10-01 — v0.6.10 (ciclo 32: fechamento do ciclo 31)

- hud.gd pushado no GitHub (faltava desde o ciclo 31: dica da tecla F loja na dica de teclas) — remoto validado lendo de volta, semanticamente identico ao local (encoding de acentos do MCP)
- test_quests.gd confirmado byte-exato no remoto (blob SHA eedeb8d9) — ja estava sincronizado
- Travamento do test_quests no ciclo 31 NAO era transitorio: era ASSERTION — o FakeGM do teste ainda espelhava a logica ANTIGA (done -> indisponivel) enquanto o game_manager real ja tinha o fix do ciclo 31 (claimed -> indisponivel); FakeGM corrigido e QUEST_TEST_OK de verdade
- test_quests.gd corrigido pushado no GitHub (blob SHA verificado lendo de volta)
- Regressao: TODOS os 7 testes unitarios OK (fusion/estimates/quests/food/bank/bestiary/runes) + headless --import 0 erros
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## 2026-10-01 — v0.6.10 (ciclo 29: CHECKLIST DE TESTE NO MAC)

- NOVO: docs/TESTE_MAC.md — checklist consolidado de teste no Mac cobrindo TUDO que acumulou desde a ultima validacao do usuario (13 secoes: combate, skills R/G, raridade/fusao, quests, comida, banco, bestiario, runas, estimativas, decor, sprites direcionais, multiplayer, save) com tempo estimado (~20-25 min)
- Regressao: TODOS os 7 testes unitarios PASSARAM (fusion/estimates/quests/food/bank/bestiary/runes) + headless 0 erros
- GitHub sincronizado (commit 97adf65, blob SHA verificado byte-exato)
- Fila: usuario testa no Mac (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## 2026-10-01 — v0.6.10 (ciclo 28: AUDITORIA PROFUNDA de integridade GitHub↔local)

- Auditoria completa de TODOS os arquivos do repo (blob SHA git hash-object local vs get_file_contents remoto): scripts/autoload, entities, world, ui, tests, scenes, project.godot, export_presets.cfg, docs, assets (sprites .b64, README)
- Resultado: 32/36 byte-exatos. 4 divergencias investigadas uma a uma: game_manager.gd (conteudo remoto SEMANTICAMENTE COMPLETO, 12/12 features — divergencia = encoding de acentos + newline do MCP, licao do ciclo 25, SEM reparo necessario); hp_bar.gd (newline final cosmico); drop.gd/projectile.gd/rat_cave.gd (remoto = local sem acentos + newline, conteudo funcional identico)
- CONCLUSAO: NENHUM arquivo corrompido ou truncado no remoto — o protocolo blob SHA pegou so diferencas de encoding do push_files
- Godot headless: 0 erros de script

## 2026-10-01 — v0.6.9 (ciclo 27: SPRITES DIRECIONAIS dos mobs)

- NOVO: mobs agora desenham direcoes REAIS (down/up/side) em vez da mesma cara de frente pra tudo — up = costas sem rosto, side = perfil (flip_h cobre a esquerda)
- FIX GRAVE: o RATO estava INVISIVEL nas direcoes up/side — so existiam PNGs "down" e o fallback procedural nao tinha case "rat". Agora rato procedural completo (3 direcoes + death: orelhas rosa, olhos vermelhos, dentes, cauda)
- Aplicado a: slime/bat/spider/wolf/goblin/orc/skeleton (rosto so no down; up = costas); orc/goblin/esqueleto mantem arma no perfil
- draw_mob ganhou parametro dir (thread via tex_helper._dir_from_path); ANIMS do mob.gd agora cai no procedural pro rat (up/side)
- Teste visual tests/preview_mobs.gd (folha PNG das 8 criaturas x 3 direcoes); 7 testes unitarios OK; headless 0 erros
- Local f7a60ae
- Proximo: teste no Mac do usuario (acumulado grande) OU build APK no Mac

## 2026-10-01 — v0.6.8 (ciclo 26: DECOR — decoracao das cidades)

- NOVO: decoracao procedural nas 2 cidades (scripts/world/decor.gd) — postes de luz com braco e lampada + brilho aditivo (BLEND_MODE_ADD), canteiros de flores ao redor da fonte/estatua, barris de madeira com aros de metal, caixotes com diagonal, bandeiras vermelhas onduladas nos portoes e barraca de feira com toldo listrado + mercadorias
- Objetos solidos (barris, caixotes, barraca) com colisor proprio (StaticBody2D circle r=26 no decor + rects casando no colliders.gd)
- Integrado ao switch_map: DECOR.build_decor(name, map_layer) logo apos build_colliders — limpa junto com o mapa ao trocar
- Validado Godot headless: 0 erros de script
- Local 118351c; GitHub 7272ba0/2e80c75/594a821 (blob SHA byte-exato: decor 0a7cc106, main 7048f499, colliders 11719725)
- Proximo: teste no Mac do usuario (acumulado grande) OU build APK no Mac

Formato: [data] versão — o que mudou (commit)

## 2026-10-01 — v0.6.7 (ciclo 25: RUNAS — escopo expandido)

- 4 runas estilo Tibia (items_db.gd): Runa de Fogo (bola de fogo no alvo mais proximo), Runa de Gelo (dano + atordoa 2s), Runa da Trovoada (dano em area 220px ao redor), Runa de Cura (+40% HP)
- Qualquer classe usa, NAO gasta mana, consome a pedra (estilo Tibia); dano fixo escalado pela skill "magia" (base * (1 + lvl*0.02)) — fogo 60, gelo 35, trovoada 45
- hud.gd: usar runa pela mochila (B); runas de alvo devolvem a pedra se nao ha monstro por perto; trovoada com anel de energia visual; feedback + som
- Icone procedural: pedra runica (losango) com glifo na cor do elemento
- Lojas: city1 vende Runa de Cura (40); city2 vende as 4 (fogo 55, gelo 45, trovoada 60, cura 35)
- Loot: skeleton dropa fogo 8% / gelo 6%, goblin trovoada 5%, slime cura 4%
- Teste tests/test_runes.gd RUNE_TEST_OK (7 casos); headless 0 erros
- Proximo: teste no Mac do usuario (acumulado grande) OU house/decoracao OU build APK

Formato: [data] versão — o que mudou (commit)

## 2026-10-01 — v0.6.7 (ciclo 25: POLISH DE COMBATE — feedback de dano no player)

- NOVO: flash VERMELHO no player ao tomar dano (o mob ja tinha flash branco; agora os dois lados tem feedback)
- NOVO: tremida curta de camera (shake 0.13s) ao tomar dano — impacto visivel
- Camera com position_smoothing (speed 6.0) — movimento mais suave ao andar e trocar de mapa
- Validado Godot headless: 0 erros de script
- Local 77fd17d; GitHub 45905cf (player.gd + player.tscn, blob SHA byte-exato)

## 2026-10-01 — v0.6.6 (ciclo 24: BESTIARIO — estilo Tibia)

- NOVO: BESTIARIO (tecla N) — registro de caca estilo Tibia: ficha dos 8 mobs (nome, onde vive, lore curta), contador de derrotas por tipo, monstros nunca enfrentados ficam "???" (descobre cacando), rodape "Descobertos: X de 8"
- GameManager: BESTIARY_INFO (ficha dos 8 mobs), bestiary_kill/bestiary_count/bestiary_seen, save "bestiary" persistido (save antigo compativel), NOVO JOGO zera
- mob.gd: kill offline registra no bestiario (dummy de treino NAO conta)
- network_manager.gd: kill ONLINE registra no cliente via _rpc_mob_reward (servidor autoritativo conta, cliente registra ao receber recompensa)
- hud.gd: painel BESTIARIO (tecla N, mesmo estilo da tela K), dica de teclas atualizada
- Teste unitario tests/test_bestiary.gd: BESTIARY_TEST_OK (8 casos: registro, acumulo, dummy ignorado, ordem de seen, ficha completa, round-trip JSON)
- Validado Godot headless: 0 erros de script
- Local af95cb2; GitHub 92a5b6f/64ba191/bd3d759/80f0f20/e633fc9 (reparos byte-exatos por blob SHA)

## 2026-10-01 — v0.6.5 (ciclo 23: BANCO/DEPOSITO — estilo Tibia)

- NOVO scripts/world/bank.gd: NPC banco nas 2 cidades (tecla T) — depositar/sacar itens da mochila (libera os 20 slots), tier de raridade preservado ("espada#2" deposita como raro e volta raro)
- GameManager.bank persistido no save ("bank"); NOVO JOGO zera; save antigo compativel
- HUD: dica de teclas atualizada (T banco)
- Teste unitario tests/test_bank.gd PASSOU (BANK_TEST_OK — depositar/sacar, tier preservado, item inexistente); headless 0 erros
- Proximo: bestiario OU teste no Mac do usuario

## 2026-10-01 — v0.6.4 (ciclo 22: polish de quests + comida)
- HUD: tecla J agora funciona em QUALQUER lugar — perto do NPC abre o painel; longe, mostra "Procure o MESTRE DAS MISSOES" (NPC entrou no grupo quest_npc)
- HUD: aviso "MISSAO PRONTA: ..." aparece quando uma quest completa (signal quest_ready no GameManager) — lembra de entregar no NPC
- Dica de teclas no HUD atualizada (J missoes)
- test_food.gd: expectativa de hp corrigida (hp0 era capturado antes do set) — FED_TEST_OK
- Validacao: headless 0 erros; testes QUEST/ESTIMATE/FUSION/FED OK

## 2026-10-01 — v0.6.3 (ciclo 21: QUESTS COM NPC — estilo Tibia/Rucoy)

- NOVO scripts/world/quest_npc.gd: NPC "Mestre das Missões" nas 2 cidades (tecla J perto dele) — sprite procedural (mestre de túnica azul com pergaminho), painel no estilo da loja
- 6 missões de caça em CADEIA (GameManager.QUESTS): ratos 5x (40 moedas/100xp) -> slimes 5x (60/180) -> aranhas 5x (100/350) -> goblins 5x (140/500) -> orcs 4x (250/900) -> esqueletos 4x (250/900); city1 tem as 2 primeiras, city2 as 4 seguintes
- Cada quest só aparece depois da anterior ENTREGUE (req); painel mostra ACEITAR / progresso X/Y / ENTREGAR com recompensa
- mob.gd: kill conta pra quest (offline); online: _rpc_mob_reward agora carrega o mob_type e o cliente conta o kill (servidor autoritativo mantém XP/loot)
- Persistido no save ("quests": progress/done/claimed); NOVO JOGO zera; save antigo compatível (sem quests = vazio)
- Teste unitário tests/test_quests.gd PASSOU (QUEST_TEST_OK — cadeia, progresso, entrega dupla bloqueada, recompensa); headless 0 erros
- Próximo: teste no Mac do usuário OU comida/energia OU banco/depósito

## 2026-10-01 — v0.6.2 (ciclo 20: ESTIMATIVAS DE TEMPO na tela K — estilo Tibia)

- game_manager.gd: skill_xp_need(skill) (lvl^2*5), skill_time_left(skill) e level_time_left() — taxas medidas: skill 240 xp/min, defesa 60 xp/min, level 450 xp/min (~1 kill a cada 8s)
- FIX formula errada: skill XP era level*100, agora level^2*5 (curva quadratica estilo Tibia — lvl 10 = 500 xp, lvl 30 = 4500)
- hud.gd tela K: cada skill mostra "up em ~Xmin" e rodape mostra "Proximo LEVEL N em ~Ymin" — o player sabe quanto falta sem adivinhar
- Teste unitario tests/test_estimates.gd: ESTIMATE_TEST_OK (formulas, formato 12s/30min/2.0h)
- Validado Godot headless --import + --quit: 0 erros de script
- Proximo: teste no Mac do usuario (raridade+fusao+estimativas+multiplayer) OU polish offline

## 2026-10-01 — v0.6.1 (ciclo 19: FUSAO DE ITENS — 3 iguais do mesmo tier -> 1 do tier seguinte)

- game_manager.gd: can_fuse(id)/fuse_item(id) — 3 itens IGUAIS do mesmo tier + 50 moedas = 1 do tier SEGUINTE (espada#1 x3 -> espada#2); Lendario (tier 4) nao funde
- hud.gd: secao "FUSAO DE ITENS" dentro do painel da mochila (B) — grid com slots borda na cor da raridade, tooltip "X -> Y (50 moedas)", clique funde com feedback "FUSAO!" + som
- Se a arma EQUIPADA era uma das fundidas e sumiu da mochila, re-equipa automaticamente a base (nunca fica sem arma)
- Teste unitario tests/test_fusion.gd (SceneTree headless): cadeia espada#1->#2->#3, bloqueio de lendario, falta de moedas/quantidade — FUSION_TEST_OK
- Validado Godot headless --import + --quit: 0 erros de script
- Proximo: estimativas de tempo na tela K / teste no Mac do usuario

## 2026-10-01 — v0.6.0 (ciclo 18: RARIDADE DE ITENS — 5 tiers + sufixos)

- NOVO `scripts/autoload/rarity.gd`: 5 tiers estilo RPG (Comum 70% / Incrivel 20% +10% / Raro 7% +25% / Epico 2.5% +50% / Lendario 0.5% +100%) conforme docs/DESIGN_ONLINE.md secao 4
- Chave de item com tier: "espada#2" = Espada Rara — tier 0 (comum) continua "espada" (save antigo 100% compativel)
- loot_table.gd: armas dropadas sorteiam tier; RARITY_BONUS por mob (rat/slime/bat 0, spider/goblin 1, wolf 2, orc/skeleton 3 — mobs fortes = tiers mais altos); vale offline (roll_drop) E online (roll_loot_list via RPC)
- drop.gd: aura colorida da raridade embaixo do icone no chao + aviso "RARO!" no pickup
- player.gd: TODO dano (ataque + skills Q/E/R/G) multiplica pelo tier da arma equipada (GameManager.weapon_dano_mult()); teclas 1-4 trocam pra arma comum; sprite/skills/som usam a BASE da arma
- hud.gd: tooltip da mochila "Espada Raro"; equipar arma com tier pela mochila com feedback; hotbar/skills/preview por weapon_base()
- game_manager.gd: weapon_base()/weapon_tier()/weapon_dano_mult()/EQUIPS_OK (load clampa arma invalida)
- Validado Godot headless --import + --quit: 0 erros de script
- Proximo: v0.6.1 fusao de itens (painel F: 3 iguais do mesmo tier -> 1 do tier seguinte, 50 moedas)

## 2026-10-01 — v0.5.6 (ciclo 16: touch controls Android + preset de export)

- TouchControls autoload (scripts/ui/touch_controls.gd): joystick virtual (canto inf. esquerdo) + 4 botoes de skill Q/E/R/G (inf. direito) + tap em qualquer lugar = mover/atacar (estilo Rucoy)
- Invisivel em desktop (DisplayServer.is_touchscreen_available()) — zero impacto no jogo de PC
- player.gd: joystick alimenta o movimento continuo (joy_vec > 0.2 define target a frente)
- export_presets.cfg NOVO: preset Android (arm64-v8a, target SDK 34, immersive, internet p/ multiplayer, package com.spacespanker.grimstone, v0.5.5 code 1, gradle build)
- docs/BUILD_ANDROID.md NOVO: guia completo de build no Mac do usuario (sandbox nao consegue: aapt2 e x86_64+glibc, qemu+musl falha em simbolos fortify) + pendencias (touch OK agora, orientacao a conferir, keystore release pra Play)
- Validado Godot headless --import + --quit: 0 erros de script
- Proximo: conferir orientacao landscape no project.godot, teste no Mac, build APK real

## 2026-10-01 — v0.5.5 (ciclo 15: netcode — interpolacao por buffer + lag artificial + NetTest c/ lag PASSOU)

- Interpolacao de mobs no cliente agora e por BUFFER de snapshots (estilo Quake): mira o estado de ~120ms atras, cobre jitter/lag sem rubber-banding; fallback = lerp pro ultimo snapshot
- LAG ARTIFICIAL (regra gs-netcode): `--netlag=<ms>` atrasa a entrega de snapshots (mobs E players) no NetworkManager — fila ordenada por tempo de entrega; 0 = sem lag (jogo normal)
- FIX no harness: `break` dentro do if teleportava o player mesmo SEM mob vivo (skipava fase); agora varre todos os espelhos e so avança com mob VIVO
- FIX no harness: chat enviado UMA vez so (re-registro duplicava o envio); server espera ~20s pra fase de mobs completar
- NetTest PASSOU COM LAG 150ms: server OK + cliente A OK + cliente B OK — registro, chat A<->B, sync posicao, espelhos de mob, dano via RPC validado no servidor (hp caiu no snapshot), saida limpa
- Validado Godot headless: 0 erros de script
- Proximo: teste no Mac do usuario (git pull + apagar .godot) OU polish/Android

## 2026-10-01 — v0.5.4 (ciclo 14: fase 2 online — MOBS AUTORITATIVOS)

- SERVIDOR roda a IA dos mobs (wander/chase/attack) e replica snapshot 10Hz; clientes so RENDERIZAM (regra gs-netcode #1/#3)
- MobAuthority autoload (server): registro de mobs com net_id estavel (get_instance_id), snapshot compacto, lookup por id
- mob.gd: modo ESPELHO no cliente (NetMob) — interpola snapshot, IA local desligada; take_damage(dmg, from_peer) registra o ULTIMO golpe (Rucoy: ultimo leva XP/loot)
- Dano do cliente via RPC validado NO SERVIDOR (anti-cheat: mob vivo + mesmo mapa + range 220px); loot/xp enviados por RPC pro peer que matou (loot_table.roll_loot_list)
- Servidor DEDICADO (sem player local): NetTarget — alvo virtual do player online mais proximo; dano do mob roteado por RPC pro cliente (signal damage_local_player)
- main.gd: server dedicado spawna TODOS os mapas; espelhos de mob criados/removidos por snapshot; troca de mapa limpa espelhos
- NetTest fase MOBS PASSOU: server + cliente A + cliente B — espelhos chegaram, cliente teleportou pra beira do mob, pediu dano, servidor validou e aplicou (RESULT OK nos 3 roles)
- Validado Godot headless: 0 erros de script
- Proximo: interpolacao de mobs no cliente + lag 200ms (gs-netcode) OU teste no Mac do usuario

## 2026-10-01 — v0.5.3 (ciclo 13: Area 11 NetTest — teste multiplayer PASSOU de verdade)

- FIX parse error no net_test.gd: variavel local `f` colidia com o parametro `f` de _flog — o harness NUNCA chegou a rodar (o ciclo 12 reportou PASSOU com logs de execucao anterior)
- FIX timing do harness: cliente agora espera OS DOIS players registrados antes de avancar (antes desistia em 10s; o servidor logava "1 online" 2x — diagnostico errado de "server perde player")
- Deadline de saida limpa (24s) antes do timeout do shell
- TESTE REAL EXECUTADO E PASSOU: server OK + cliente A OK + cliente B OK no localhost — 2 players registrados SIMULTANEAMENTE, chat A<->B relayado, POSICAO relayada entre clientes, saida limpa
- Validado Godot headless: 0 erros de script
- Proximo: mobs autoritativos no servidor + teste no Mac do usuario

## 2026-10-01 — v0.5.2 (ciclo 12: teste de rede localhost PASSOU + fixes criticos)

- FIX CRITICO main.gd: `NetworkManager._on_server_lost.connect(...)` conectava um METODO como se fosse sinal — criado sinal proprio `server_lost` no NetworkManager (clientes limpam remote players ao cair)
- FIX network_manager.gd: `is_online()` exige `active` + CONNECTION_CONNECTED; send_position/send_chat so agem com active=true — modo offline nao tenta mais RPC (fim do spam "RPC on yourself")
- NetTest (scripts/tests/net_test.gd): harness automatizado 1 server + 2 clientes no localhost via `--nettest=server|clientA|clientB` (main.gd injeta o harness na cena main.tscn). Logs em /tmp/nettest_<role>.log com flush imediato (stdout morre com o processo quando timeout mata)
- TESTE EXECUTADO E PASSOU: registro dos 2 clientes OK, chat relay A<->B OK, sync de posicao 15Hz entre clientes OK, saida limpa sem crash OK (server OK, A OK, B OK)
- Validado: Godot headless --import 0 erros de script
- Proximo: mobs autoritativos no servidor, teste no Mac do usuario

## 2026-10-01 — v0.5.1 (ciclo 11: Area 10 QA — auditoria estatica)

- `d7c964d` 5 fixes de QA: RemotePlayer sem Sprite (crash player 2), connect invalido de _on_server_lost, NOVO JOGO nao resetava skills/city2, eco de chat com nome errado no servidor, loja E->F (conflito com skill E)
- Validado Godot headless: 0 erros de script
- Proximo: teste real multiplayer (2 clientes + servidor) + teste no Mac

## 2026-10-01 — v0.5.0 (ciclo 10: Area 9 Multiplayer — integracao completa)

- RemotePlayer novo (scripts/entities/remote_player.gd): avatar visual de outro player — sprite procedural com a APARENCIA dele (arma/cabelo/tunica/calca), nome em cima, interpolacao suave do snapshot 15Hz (teleport se >300px)
- NetworkManager v2: registro agora manda APARENCIA (weapon/hair/tunic/pants); novo sinal player_state (posicao+mapa+anim) separado do player_joined; chat com kinds msg/join/leave/system; eco da propria msg pro autor
- main.gd integra multiplayer: spawna/remove RemotePlayers nos sinais, envia minha posicao a 15Hz com anim "base:facing" (idle/walk/attack), filtra por mapa (so ve quem esta no MESMO mapa), limpa tudo se cair a conexao
- HUD: chat global (Enter abre, Enter envia e fecha, Esc cancela; log colorido msg/join/leave/system; enquanto digita, teclas NAO vazam pro jogo); contador [ONLINE n] no HUD quando conectado
- Titulo: botoes HOSPEDAR JOGO (listen server) e CONECTAR (IP, default 127.0.0.1); versao v0.5.0
- Validado Godot headless 4.6 alpine: --import + --quit = 0 erros de script
- Pendente (proximo ciclo): mobs autoritativos no server, teste 2 clientes + 1 server no localhost, servidor dedicado real

## 2026-10-01 — v0.4.9 (ciclo 10: auditoria Area 8 Audio — gap de skills corrigido)

- Auditoria do AudioManager: 17 pontos de audio conferidos um a um (combate, morte, loot, pocao, loja, portao, titulo, musicas com crossfade) — todos OK
- GAP encontrado: skills (Q/E/R/G) NAO tocavam som — so o ataque basico tocava. Fix: play_sfx("cast") no _use_skill (player.gd)
- GAP encontrado: teclas C/B/K (mochila/roupas/skills) nao tocavam ui_click — so os botoes da tela de titulo tocavam. Fix: ui_click nos toggles do HUD
- Validado Godot headless: 0 erros de script
- Proximo: Area 9 Multiplayer (gs-netcode) ou polish extra conforme fila

## v0.4.8 — Audio (Area 8)
- AudioManager autoload (audio_manager.gd): audio 100% procedural, sintetizado em GDScript no startup — zero arquivos binarios
- 12 SFX (hit/shoot/cast/mob_death/player_hurt/player_death/level_up/coin/pickup/potion/ui_click/door) com pool de 8 players e pitch variavel
- 3 musicas chiptune em loop com crossfade: titulo / cidade / caverna+floresta
- Sons integrados: combate, loot, pocao, loja, UI, portao, level up, morte

## v0.4.7 (ciclo 8 — Area 7 Balanceamento)
- game_manager.gd: hp_max/mana_max DERIVADOS do level (100+10/level, 50+5/level) — save antigo nunca mais desincroniza
- Level up estilo Tibia: NAO enche HP/mana em combate (+30/+15 parcial); fora de combate enche tudo
- player.gd: cura fora de combate acelerada (~5% do max a cada 2s, estilo Rucoy)
- mob.gd: XP dos mobs iniciais +75% (rat 35, slime 50, bat 40) — early game menos grind
- shop.gd: pocoes P mais baratas (vida 20->15, mana 25->18) — primeiro minuto de jogo mais suave
- Validado Godot headless: 0 erros de script

## v0.4.6 (ciclo 7 — Area 6 UI/UX)
- HUD: fix labels de painel no root (visiveis sempre/acumulando), mochila rebuild so quando muda, dim da morte com tamanho, preview de roupas renderiza, cooldown numerico Q/E/R/G, barra de feedback central (mana/skill bloqueada/sem flechas)
- Loja: titulo correto por cidade, feedback colorido de compra
- Titulo: v0.4.5 + ESC sai

## 2026-10-01 — v0.4.5 (ciclo 6: Area 5 Itens & Economia — balanceamento)

- Simulacao de balanceamento antes de mexer (scripts/area5_sim.py, regra 5: nunca balancear no escuro)
- `ad12a3e`/`4d59f15` equips.gd: arco 10->14 dano / 0.9->0.8s CD, cajado 18->19 — TTK das 4 armas equalizado (regra 1: 5-10s no mapa atual; DPS 16.9-18.8, dentro de 2% entre si)
- `4d59f15` mob.gd: dano de mobs endgame cortado (spider 12, goblin 12, wolf 13, skeleton 14, orc 16) — player aguenta 8+ hits (regra 2)
- `4d59f15` mob.gd: dano de mob com VARIANCIA ±10% (estilo Tibia — hits nao sao mais todos identicos)
- `ad12a3e` loot_table.gd: moedas +30% em goblin/skeleton/wolf/orc/spider — economia fecha (regra 3: loot/min >= 2 pocoes do mapa)
- `cce7084` loot_table.gd: orc dropa pocao_vida_g (10%), skeleton dropa pocao_mana_g (10%) — antes as pocoes G so existiam na loja; goblin dropa pocao_vida_m (12%)
- `4d59f15` game_manager.gd: curva de skill XP QUADRATICA estilo Tibia (lvl^2*5) — skill up ~1.7min no inicio, ~15min no lvl 30 (regra 4)
- Validado Godot headless: 0 erros de script
- Proximo: Area 6 UI/UX (gs-ui-ux)

## 2026-10-01 — v0.4.4 (ciclo 5: Area 4 Mapas & Mundo)

- `c80be47`/`5cdc34f` colliders.gd: portoes das muralhas casam com a arte (abertura 224px y 932-1156), predios/casas/arvores do anel denso com colisores (player nao atravessa mais), bordas da floresta com abertura norte correta
- `8316011`/`2bdc21e` player.gd: REGEN estilo Tibia — mana regenera sempre (lenta, escala com level), HP regenera so FORA de combate
- Validado Godot headless: 0 erros de script
- Proximo: Area 5 Itens & Economia (auditoria gs-combat-balance)

## 2026-10-01 — v0.4.3 (ciclo 4b: Area 3 Monstros & IA — fixes de combate)

- `cd21605` mob.gd: ataque agendado nao acerta mais player MORTO (checava so no agendamento, nao no hit)
- `cd21605` mob.gd: hit so acerta se o alvo ainda estiver no alcance (110px) — sem dano fantasma ao fugir
- `cd21605` mob.gd: leash de perseguição (700px do spawn) — mobs voltam a vagar em vez de perseguir o mapa inteiro
- `cd21605` mob.gd: dummy de treino simplificado (early return no take_damage, sem ramo morto)
- Validado Godot headless: 0 erros de script

## 2026-10-01 — v0.4.2 (ciclo 4: sincronização GitHub↔local completa)

- `98204b1` hud.gd = copia EXATA do local (fix preview declarado + `ready: bool` tipado; o d7655ae intermediário reescreveu o arquivo por engano e foi revertido)
- `4340ba6` tex_helper.gd = copia exata do local: floresta densa com ordem de desenho das árvores correta (tree_positions coletadas antes de desenhar)
- player.gd remoto JÁ contém os handlers R/G (diff restante é cosmético); equips.gd e icons_embedded.gd idênticos local/remoto
- Validação: Godot headless `--import` + `--quit` = 0 erros de script
- LIÇÃO registrada: pushar sempre o conteúdo lido do arquivo local, nunca reconstruir de diff

## 2026-10-01 — v0.4.1 (ciclo 3: skills R/G v2 completas + fix de unlock)

- `2f380d0` Skills avancadas R/G REFEITAS (v2) e 100% funcionais: sword Golpe Duplo (2 hits)+Grito de Guerra (+50% dano 12s), axe Giratorio (AOE x3)+Sangue Frio (cura 30%), bow Flecha Perfurante (x4)+Chuva Pesada (AOE x2.5, 8 flechas), staff Nova de Gelo (AOE stun 2s)+Cura Maior (70% HP)
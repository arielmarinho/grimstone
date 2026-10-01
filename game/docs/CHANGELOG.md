# GRIMSTONE — Changelog

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
- FIX GRAVE: rato estava INVISIVEL nas direcoes up/side (PNGs so existiam pra down e o fallback procedural nao tinha case "rat") — _draw_rat procedural completo (3 direcoes + death)
- Validacao VISUAL headless: tests/preview_mobs.gd (folha 8 mobs x 3 direcoes) + tests/preview_mobs2.gd (up/side ampliados 2x) — direcoes confirmadas distintas (rato de perfil com cauda, costas sem rosto no up)
- Headless 0 erros de script

## 2026-10-01 — v0.6.8 (ciclo 26: DECOR — decoracao das cidades)

- NOVO scripts/world/decor.gd: postes de luz com braco+lampada+glow aditivo (BLEND_MODE_ADD), canteiros de flores (seed fixa 77) ao redor da fonte/estatua, barris com aros de metal, caixotes com diagonal, bandeiras vermelhas onduladas nos portoes, barraca de feira com toldo listrado+mercadorias
- Solidos com colisor (StaticBody2D r=26 no decor + rects casando no colliders.gd)
- Integrado ao switch_map apos build_colliders
- Headless 0 erros de script

## 2026-10-01 — v0.6.7 (ciclo 25: RUNAS — escopo expandido)

- 4 runas estilo Tibia: fogo (60 moedas, projetil), gelo (35, congela mob), trovoada (45, AOE 220px com anel visual), cura (40, +40% HP)
- Qualquer classe usa; NAO gasta mana; consome a pedra ao usar
- Dano escala com skill magia (base * (1 + lvl*0.02))
- Runa de dano sem monstro por perto = devolve a pedra (nao desperdica)
- Icone procedural (losango de pedra + glifo)
- Lojas: city1 vende cura (40), city2 vende as 4 (fogo 55/gelo 45/trovoada 60/cura 35)
- Loot: skeleton fogo 8%/gelo 6%, goblin trovoada 5%, slime cura 4%
- Teste unitario tests/test_runes.gd RUNE_TEST_OK
- Headless 0 erros de script

## 2026-10-01 — v0.6.7 (ciclo 25: POLISH DE COMBATE — feedback de dano no player)

- Flash VERMELHO no player ao tomar dano (mob ja tinha flash branco)
- Tremida curta de camera (shake 0.13s via offset tween)
- Camera com position_smoothing (speed 6.0) no player.tscn
- Headless 0 erros de script

## 2026-10-01 — v0.6.6 (ciclo 24: BESTIARIO — estilo Tibia)

- GameManager.BESTIARY_INFO: ficha dos 8 mobs (nome/onde aparece/lore)
- bestiary_kill/bestiary_seen persistidos no save (save antigo OK); NOVO JOGO zera
- mob.gd registra kill offline (dummy NAO conta); online: _rpc_mob_reward registra via network_manager
- hud.gd painel BESTIARIO tecla N (estilo tela K): mobs nao vistos = "???", vistos mostram ficha + contador de kills
- Teste unitario tests/test_bestiary.gd BESTIARY_TEST_OK
- Headless 0 erros de script

## 2026-10-01 — v0.6.5 (ciclo 23: BANCO/DEPOSITO — estilo Tibia)

- NPC BANCO nas 2 cidades (tecla T): deposita/saca itens da mochila (libera BAG_MAX 20)
- Tier de raridade preservado ("espada#2" e slot proprio no banco)
- Moedas ficam no bolso (nao depositaveis)
- Sprite procedural (banqueiro tunica dourada + cofre), painel 2 colunas, refresh por assinatura
- GameManager: var bank + save/load ("bank", save antigo OK) + bank_deposit/bank_withdraw (saque bloqueado com mochila cheia); NOVO JOGO zera
- Posicoes: city1 (1024,1420), city2 (1024,620) — sem colisor
- Teste unitario tests/test_bank.gd BANK_TEST_OK (8 casos)
- Headless 0 erros de script

## 2026-10-01 — v0.6.4 (ciclo 22: polish de quests + comida)

- Tecla J global no HUD (perto do NPC abre painel; longe mostra feedback "Procure o MESTRE DAS MISSOES")
- NPC no grupo quest_npc; signal quest_ready no GameManager + aviso "MISSAO PRONTA" no HUD (6s)
- COMIDA/ENERGIA: carne/queijo/peixe com "comida" (180/300/240s, cap 600s empilhando)
- well_fed = regen 2x (mana+HP fora de combate); indicador "BEM ALIMENTADO (Xmin) — regen 2x" no HUD; feedback "Nham!" ao comer
- Dropam de rat/bat/orc; na loja city1 (carne 8/6, queijo 5/4, peixe 8)
- Icones procedurais de queijo/peixe; persiste no save ("well_fed"), NOVO JOGO zera, save antigo OK
- Fix expectativa do test_food (hp0 capturado antes do set) — FED_TEST_OK
- Headless 0 erros de script

## 2026-10-01 — v0.6.3 (ciclo 21: QUESTS COM NPC — estilo Tibia/Rucoy)

- GameManager.QUESTS: 6 missoes de caca em cadeia (ratos 5x 40moedas/100xp → slimes 60/180 → aranhas 100/350 → goblins 140/500 → orcs 4x 250/900 → esqueletos 250/900)
- req em cadeia (cada quest exige a anterior completa); city1 tem 2, city2 tem 4
- quest_state/quest_available/quest_on_kill/quest_claim + signal quest_done; save/load de "quests" (save antigo OK); NOVO JOGO zera
- NPC quest_npc.gd (Mestre das Missoes, sprite procedural azul+barba+pergaminho) nas 2 cidades, tecla J
- mob.gd: quest_on_kill offline; online: _rpc_mob_reward leva mob_type (network_manager signal + rpc + main handler)
- Teste unitario tests/test_quests.gd QUEST_TEST_OK
- Headless 0 erros de script

## 2026-10-01 — v0.6.2 (ciclo 20: ESTIMATIVAS DE TEMPO na tela K — estilo Tibia)

- game_manager.gd: skill_xp_need (lvl^2*5), skill_time_left, level_time_left (taxas medidas: skill 240 xp/min, defesa 60 xp/min, level 450 xp/min)
- Tela K mostra "up em ~Xmin" por skill + "Proximo LEVEL em ~Ymin" no rodape
- FIX: tela K usava formula ERRADA (level*100) em vez da curva real (level^2*5)
- Teste unitario tests/test_estimates.gd ESTIMATE_TEST_OK
- Headless 0 erros de script

## 2026-10-01 — v0.6.1 (ciclo 19: FUSAO DE ITENS — 3 iguais do mesmo tier -> 1 do tier seguinte)

- game_manager.gd: can_fuse/fuse_item — 3 itens iguais do mesmo tier + 50 moedas = 1 do tier seguinte; lendario NAO funde
- UI no painel da mochila (B): secao FUSAO DE ITENS com grid (borda na cor da raridade, tooltip do resultado, feedback+som)
- Arma equipada fundida re-equipa a base
- Teste unitario tests/test_fusion.gd FUSION_TEST_OK
- Headless 0 erros de script

## 2026-10-01 — v0.6.0 (ciclo 18: RARIDADE DE ITENS — 5 tiers + sufixos)

- NOVO scripts/autoload/rarity.gd: 5 tiers (Comum 70% / Incrivel 20% +10% / Raro 7% +25% / Epico 2.5% +50% / Lendario 0.5% +100% de dano)
- Chave com tier = "espada#2" (tier 0 = chave sem "#", save antigo compativel)
- loot_table.gd: RARITY_BONUS por mob (rat/slime/bat 0, spider/goblin 1, wolf 2, orc/skeleton 3); armas dropadas sorteiam tier (offline roll_drop + online roll_loot_list)
- drop.gd: aura colorida por tier no chao + "RARO!" no pickup
- player.gd: TODO dano (ataque + skills) multiplica por GameManager.weapon_dano_mult(); teclas 1-4 = arma comum; sprite/skills/som usam weapon_base()
- hud.gd: tooltip "Espada Raro", equipar com tier pela mochila, hotbar/skills/preview por base
- game_manager.gd: weapon_base/tier/dano_mult/EQUIPS_OK (load clampa)
- Headless 0 erros de script

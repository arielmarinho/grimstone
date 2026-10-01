## v0.6.17 — Player 100% ARTE REAL (hibrido: down real + up real editada + side real flip) (ciclo 41, 01/10)
Formato: codigo no GitHub (3881b00 local, push MCP 99658a8/225fbf9/ece7d2a)
- Player UP = ARTE REAL editada: load_sheet_up_real substitui o rosto (pele) por cabelo = costas de verdade, mantendo 100% a identidade visual aprovada (NADA de procedural no player)
- Player SIDE = ARTE REAL de frente com flip_h (estilo Tibia — esquerda/direita cobertos pela mesma folha)
- Validacao VISUAL: tests/preview_hybrid2.gd (artifacts/player_hybrid2.png) + check programatico de pixels de pele (idle_down=380 px de rosto vs idle_up=12 px = rosto virou cabelo OK)
- INCIDENTE: 1o push do tex_helper saiu TRUNCADO (sem as funcoes de mapa) + typo _draw_rect — reparado com push do arquivo local COMPLETO, remoto validado lendo de volta (semanticamente identico, encoding de acentos do MCP so)
- Validacao: headless --import + --quit-after 120 = 0 erros
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.16 — Player 4 direcoes REAIS + validacao visual (ciclo 39, 01/10)
Formato: codigo no GitHub (509f48a local, push MCP), docs pushados
- FIX do bug "so anda pra baixo" na CAUSA RAIZ: player.gd ANIMS apontam pra paths up/side REAIS e tex_helper.load_sheet_procedural_custom desenha procedural 4 direcoes (idle/walk/attack em down/up/side; death deitado = padrao Tibia, cadaver nao tem direcao)
- Validacao VISUAL headless: tests/preview_player.gd — folha 8x4 confirmada (frente/costas/perfil com flip/death) em artifacts/player_dirs_preview.png
- Sincronizacao: player.gd/tex_helper.gd local alinhados ao remoto (comentarios 4-direcoes da instancia paralela, logica identica, blob SHA conferido); mob.gd remoto = canônico com netcode/quests/dummy (todas as features OK)
- Validacao: headless --import + --quit-after 120 = 0 erros; 7/7 testes unitarios OK; preview visual OK
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.15 — Numeros de recompensa flutuantes (ciclo 38b, 01/10)
Formato: codigo + docs no GitHub (fe2f526/d478d24), local e6267ba
- FX autoload novo (scripts/autoload/fx.gd): numeros flutuantes de GANHO — +XP (azul), +moedas (dourado), +cura (verde), +mana (azul), SKILL UP (dourado grande)
- GameManager emite sinais xp_gained/coins_gained/healed/mana_gained/skill_up_event; FX conecta no _ready e desenha no player
- coin.gd/drop.gd chamam FX.coin_gain direto no pickup
- FIX ciclo 38c: FX.coin_gain() NAO existia no fx.gd (coin/drop chamavam funcao inexistente — moeda nunca sumia, spam de erro) — funcao adicionada (local c15da91, GitHub f5be00b)
- FIX ciclo 38c: commit de audio f57897d tinha APAGADO o corpo inteiro do projectile.gd no remoto (_ready/_physics_process/_hit/_spawn_crit_text — flechas/bolas de fogo mortas no GitHub) — restaurado byte-exato (b21f2aa0)
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
- Resultado: 32/36 byte-exatos. 4 divergencias investigadas uma a uma: game_manager.gd (conteudo remoto SEMANTICAMENTE COMPLETO, 12/12 features — divergencia = encoding de acentos + newline do MCP, licao do ciclo 25, SEM reparo necessario); hp_bar.gd (newline final cosmico); drop.gd/projectile.gd/rat_cave.gd (remoto = local se

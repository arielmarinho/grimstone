## v0.6.16 — Player 4 direcoes REAIS + validacao visual (ciclo 39, 01/10)
Formato: codigo no GitHub (509f48a local, push MCP), docs pushados
- FIX do bug "so anda pra baixo" na CAUSA RAIZ: player.gd ANIMS apontam pra paths up/side REAIS e tex_helper.load_sheet_procedural_custom desenha procedural 4 direcoes (idle/walk/attack em down/up/side; death deitado = padrao Tibia, cadaver nao tem direcao)
- Validacao VISUAL headless: tests/preview_player.gd — folha 8x4 confirmada (frente/costas/perfil com flip/death) em artifacts/player_dirs_preview.png
- Sincronizacao: player.gd/tex_helper.gd local alinhados ao remoto (comentarios 4-direcoes da instancia paralela, logica identica, blob SHA conferido); mob.gd remoto = canônico com netcode/quests/dummy (todas as features OK)
- Validacao: headless --import + --quit-after 120 = 0 erros; 7/7 testes unitarios OK; preview visual OK
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

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
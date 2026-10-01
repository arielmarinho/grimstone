# GRIMSTONE — Changelog

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

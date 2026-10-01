# GRIMSTONE — Changelog

## 2026-10-01 — v0.6.10 (ciclo 32: fechamento do ciclo 31)

- hud.gd pushado no GitHub (faltava desde o ciclo 31: dica da tecla F loja na dica de teclas) — remoto validado lendo de volta, semanticamente identico ao local (encoding de acentos do MCP)
- test_quests.gd confirmado byte-exato no remoto (blob SHA eedeb8d9) — ja estava sincronizado
- Travamento do test_quests no ciclo 31 NAO era transitorio: era ASSERTION — o FakeGM do teste ainda espelhava a logica ANTIGA (done -> indisponivel) enquanto o game_manager real ja tinha o fix do ciclo 31 (claimed -> indisponivel); FakeGM corrigido e QUEST_TEST_OK de verdade
- test_quests.gd corrigido pushado no GitHub (blob SHA verificado lendo de volta)
- Regressao: TODOS os 7 testes unitarios OK (fusion/estimates/quests/food/bank/bestiary/runes) + headless --import 0 erros
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

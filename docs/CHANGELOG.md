# GRIMSTONE — Changelog

Formato: [data] versão — o que mudou (commit)

## 2026-10-01 — v0.4.5 (ciclo 6: Area 5 Itens & Economia — balanceamento)

- `ad12a3e`/`4d59f15` equips.gd: arco 10->14 dano / 0.9->0.8s CD, cajado 18->19 — TTK das 4 armas equalizado (regra 1: 5-10s no mapa atual)
- `4d59f15` mob.gd: dano de mobs endgame cortado (spider 12, goblin 12, wolf 13, skeleton 14, orc 16) — player aguenta 8+ hits (regra 2)
- `ad12a3e` loot_table.gd: moedas +30% em goblin/skeleton/wolf/orc/spider — economia fecha (regra 3: loot/min >= 2 pocoes)
- `4d59f15` game_manager.gd: curva de skill XP QUADRATICA estilo Tibia (lvl^2*5) — skill up ~1.7min no inicio, ~15min no lvl 30 (regra 4)
- Simulacao numerica antes/depois documentada em docs/PLANO_AUDITORIA.md (Area 5)
- Validado Godot headless: 0 erros de script
- Proximo: Area 6 UI/UX (gs-ui-ux)

## 2026-10-01 — v0.4.4 (ciclo 5: Area 4 Mapas & Mundo)

- `c80be47`/`5cdc34f` colliders.gd: portoes das muralhas casam com a arte (abertura 224px y 932-1156), predios/casas/arvores do anel denso com colisores (player nao atravessa mais), bordas da floresta com abertura norte correta
- `8316011`/`2bdc21e` player.gd: REGEN estilo Tibia — mana regenera sempre (lenta, escala com level), HP regenera so FORA de combate
- Validado Godot headless: 0 erros de script
- Proximo: Area 5 Itens & Economia (auditoria gs-combat-balance)

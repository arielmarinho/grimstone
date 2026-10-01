# GRIMSTONE — Changelog

Formato: [data] versão — o que mudou (commit)

## 2026-10-01 — v0.4 (ciclo 2: City2 libera mais ataques)

- Skills avançadas R/G por classe (8 novas): sword Investida+Terremoto (stun em área), axe Golpe Duplo+Bersek, bow Precisão (3 críticos)+Tiro Múltiplo (explosão em área), staff Escudo Arcano (-50% dano)+Nevasca (stun+dano)
- Desbloqueio ao PISAR na city2 (flag city2_unlocked salva no savegame) + aviso na tela
- HUD: 4 botões de skill (Q/E/R/G), skills bloqueadas aparecem como "???" (cinza) na tela K e nos botões
- Player: buffs bersek (x2.5 dano), escudo arcano (metade do dano recebido), precisão, golpe duplo (2 hits)

## 2026-10-01 — v0.3 → v0.4 (madrugada de trabalho autônomo)

- `26db787` Sistemas: skills_db (2 skills/classe + crítico), flechas como munição, calça colorida, loot de goblin/orc/esqueleto
- `0c92da3` Mobs: 8 tipos (goblin/orc/esqueleto novos com sprites), stun pra skill, projétil com crítico/bola de fogo
- `dcd3c6f` Player: skills Q/E estilo Rucoy, flechas como munição, crítico com feedback, calça colorida (U)
- `c276d62` Mundo: 4 mapas (city1, city2 vila anã, floresta, caverna), spawners por mapa, lojas com flechas
- `e4f7a95` TexHelper: calça colorida, roteamento CURRENT_MOB, mapas city2 e floresta novos
- `eb945d8` HUD: botões de skill Q/E estilo Rucoy, tela de skills (K), contador de flechas, calça no painel de roupas
- `cf7ff5c` Tela de título (continuar/novo jogo/sair) + ícone do jogo (lápide com espada)
- `e47966d` Fundação multiplayer: NetworkManager (ENet 7777, sync posição, chat) + DESIGN_ONLINE.md
- `9e89392` Área 1 (Combate & Feedback): flash de dano, números flutuantes, morte com fade, level up com anel dourado

## Fila (próximos ciclos)
- [ ] Polish: poções em níveis (pequena/média/grande)
- [ ] Polish: shops separados por função (armas / poções / flechas)
- [ ] Polish: dummies de treino na city2
- [ ] Polish: mana regen fora de combate, comida/energia
- [ ] Auditoria Área 2 (Player & Skills) — validação do usuário
- [ ] Balanceamento geral
- [ ] Multiplayer: mobs autoritativos, raridade, fusão, trade/party, contas
- [ ] Build Android

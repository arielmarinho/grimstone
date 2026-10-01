# GRIMSTONE — Changelog

Formato: [data] versão — o que mudou (commit)

## 2026-10-01 — v0.4.3 (ciclo 4b: Area 3 Monstros & IA — fixes de combate)

- `cd21605` mob.gd: ataque agendado nao acerta mais player MORTO (checava so no agendamento, nao no hit)
- `cd21605` mob.gd: hit so acerta se o alvo ainda estiver no alcance (110px) — sem dano fantasma ao fugir
- `cd21605` mob.gd: leash de perseguição (700px do spawn) — mobs voltam a vagar em vez de perseguir o mapa inteiro
- `cd21605` mob.gd: dummy de treino simplificado (early return no take_damage, sem ramo morto)
- Validado Godot headless: 0 erros de script

## 2026-10-01 — v0.4.2 (ciclo 4: sincronização GitHub↔local completa)

- `98204b1` hud.gd = copia EXATA do local (fix preview declarado + `ready: bool` tipado; o d7655ae intermediário reescreveu o arquivo por engano e foi revertido)
- `4340ba6` tex_helper.gd = copia exata do local: floresta densa com ordem de desenho das árvores correta (tree_positions coletadas antes de desenhar — árvores não sobrepõem cogumelos/pedras)
- player.gd remoto JÁ contém os handlers R/G (diff restante é cosmético); equips.gd e icons_embedded.gd idênticos local/remoto
- Validação: Godot headless `--import` + `--quit` = 0 erros de script
- LIÇÃO registrada: pushar sempre o conteúdo lido do arquivo local, nunca reconstruir de diff

## 2026-10-01 — v0.4.1 (ciclo 3: skills R/G v2 completas + fix de unlock)

- `2f380d0` Skills avancadas R/G REFEITAS (v2) e 100% funcionais: sword Golpe Duplo (2 hits)+Grito de Guerra (+50% dano 12s), axe Giratorio (AOE x3)+Sangue Frio (cura 30%), bow Flecha Perfurante (x4)+Chuva Pesada (AOE x2.5, 8 flechas), staff Nova de Gelo (AOE stun 2s)+Cura Maior (70% HP)
- `2f380d0` FIX: unlock usava flag errada (city2_unlocked vs city2_visited) — R/G nunca desbloqueava; agora _unlock_city2() seta as duas e salva no savegame
- `2f380d0` FIX: ids do skills_db nao tinham handler no player.gd (R/G gastava mana sem efeito) — todos os 8 ids tem match agora
- `2f380d0` FIX: shop.gd usava CATALOG constante inexistente na versao de lojas separadas — agora _catalog() por cidade

## 2026-10-01 — v0.4 (ciclo 2: City2 libera mais ataques)

- Skills avancadas R/G por classe (8 novas): sword Investida+Terremoto (stun em area), axe Golpe Duplo+Bersek, bow Precisao (3 criticos)+Tiro Multiplo (explosao em area), staff Escudo Arcano (-50% dano)+Nevasca (stun+dano)
- Desbloqueio ao PISAR na city2 (flag city2_unlocked salva no savegame) + aviso na tela
- HUD: 4 botoes de skill (Q/E/R/G), skills bloqueadas aparecem como "???" (cinza) na tela K e nos botoes
- Player: buffs bersek (x2.5 dano), escudo arcano (metade do dano recebido), precisao, golpe duplo (2 hits)

## 2026-10-01 — v0.3 → v0.4 (madrugada de trabalho autonomo)

- `26db787` Sistemas: skills_db (2 skills/classe + critico), flechas como municao, calca colorida, loot de goblin/orc/esqueleto
- `0c92da3` Mobs: 8 tipos (goblin/orc/esqueleto novos com sprites), stun pra skill, projetil com critico/bola de fogo
- `dcd3c6f` Player: skills Q/E estilo Rucoy, flechas como municao, critico com feedback, calca colorida (U)
- `c276d62` Mundo: 4 mapas (city1, city2 vila ana, floresta, caverna), spawners por mapa, lojas com flechas
- `e4f7a95` TexHelper: calca colorida, roteamento CURRENT_MOB, mapas city2 e floresta novos
- `eb945d8` HUD: botoes de skill Q/E estilo Rucoy, tela de skills (K), contador de flechas, calca no painel de roupas
- `cf7ff5c` Tela de titulo (continuar/novo jogo/sair) + icone do jogo (lapide com espada)
- `e47966d` Fundacao multiplayer: NetworkManager (ENet 7777, sync posicao, chat) + DESIGN_ONLINE.md
- `9e89392` Area 1 (Combate & Feedback): flash de dano, numeros flutuantes, morte com fade, level up com anel dourado

## Fila (proximos ciclos)
- [ ] Polish: mana regen fora de combate, comida/energia
- [ ] Auditoria Area 3 (Monstros & IA) — CONCLUÍDA no ciclo 4b
- [ ] Auditoria Area 4 (Mapas & Mundo)
- [ ] Auditoria Area 5 (Itens & Economia)
- [ ] Balanceamento geral
- [ ] Multiplayer: mobs autoritativos, raridade, fusao, trade/party, contas
- [ ] Build Android
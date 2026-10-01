# GRIMSTONE — CHANGELOG

## 2026-10-01 — v0.4.4 (ciclo 5: Area 4 Mapas & Mundo)

- `3c2edb9/ced7daa` FIX GRAVE: saida norte da floresta estava bloqueada por colisor — impossivel voltar pra city2; agora abertura x 932-1156 casando com a arte
- `3c2edb9/ced7daa` Colisores dos portoes casando com a ARTE (abertura 224px, antes 190px desalinhada) em city1 e city2
- `3c2edb9/ced7daa` Predios solidos: 3 predios city1 + 4 casas + forja city2 agora tem colisao
- `3c2edb9/ced7daa` City2 = ZONA SEGURA: so o dummy de treino spawna la (mobs agressivos removidos)
- `3c2edb9/ced7daa` Transicao pelo portao correspondente (arrive): voltar de floresta te coloca no portao sul da city2, nao no spawn default
- `3c2edb9/ced7daa` Spawns fora do alcance de aggro do spawn do player (nenhum mob ataca ao entrar no mapa)

## 2026-10-01 — v0.4.3 (ciclo 4: Area 3 Monstros & IA)

- `cd21605` FIX: ataque agendado do mob nao acerta mais player MORTO (checava so no agendamento, nao no hit)
- `cd21605` FIX: hit so acerta se o alvo ainda estiver no alcance do golpe (110px) — sem dano fantasma ao fugir
- `cd21605` Leash 700px do spawn: mob nao persegue o mapa inteiro
- `cd21605` Dummy de treino simplificado (estatico, imortal, mostra dano)

## 2026-10-01 — v0.4.2 (ciclo 3b: sincronizacao GitHub-local)

- `98204b1` hud.gd = copia exata do local (fix preview/ready)
- `4340ba6` tex_helper.gd = copia exata do local: floresta densa com ordem de desenho das árvores correta (tree_positions coletadas antes de desenhar)
- player.gd remoto JÁ contém os handlers R/G (diff restante é cosmético); equips.gd e icons_embedded.gd idênticos local/remoto
- Validação: Godot headless `--import` + `--quit` = 0 erros de script
- LIÇÃO registrada: pushar sempre o conteúdo lido do arquivo local, nunca reconstruir de diff

## 2026-10-01 — v0.4.1 (ciclo 3: skills R/G v2 completas + fix de unlock)

- `2f380d0` Skills avancadas R/G REFEITAS (v2) e 100% funcionais: sword Golpe Duplo (2 hits)+Grito de Guerra (+50% dano 12s), axe Giratorio (AOE x3)+Sangue Frio (cura 30%), bow Flecha Perfurante (x4)+Chuva Pesada (AOE x2.5, 8 flechas), staff Nova de Gelo (AOE stun 2s)+Cura Maior (70% HP)
- `2f380d0` FIX: unlock usava flag errada (city2_unlocked vs city2_visited) — R/G nunca desbloqueava; agora _unlock_city2() seta as duas e salva no savegame
- `2f380d0` FIX: ids do skills_db nao tinham handler no player.gd (R/G gastava mana sem efeito) — todos os 8 ids tem match agora
- `2f380d0` FIX: shop.gd usava CATALOG constante inexistente na versao de lojas separadas — agora _catalog() por cidade

## 2026-10-01 — v0.4 (ciclo 2: City2 libera mais ataques)

- `este` Skills avancadas R/G por classe (8 novas): sword Investida+Terremoto (stun em area), axe Golpe Duplo+Bersek, bow Precisao (3 criticos)+Tiro Multiplo (explosao em area), staff Escudo Arcano (-50% dano)+Nevasca (stun+dano)
- `este` Desbloqueio ao PISAR na city2 (flag city2_unlocked salva no savegame) + aviso na tela
- `este` HUD: 4 botoes de skill (Q/E/R/G), skills bloqueadas aparecem como "???" (cinza) na tela K e nos botoes
- `este` Player: buffs bersek (x2.5 dano), escudo arcano (metade do dano recebido), precisao, golpe duplo (2 hits)

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
- [ ] Auditoria Area 5 (Itens & Economia)
- [ ] Auditoria Area 6 (UI/UX)
- [ ] Polish: mana regen fora de combate, comida/energia
- [ ] Balanceamento geral
- [ ] Multiplayer: mobs autoritativos, raridade, fusao, trade/party, contas
- [ ] Build Android

## 2026-10-01 — v0.5.1 (ciclo 11: Area 10 QA — auditoria estatica)

- `d7c964d` 5 fixes de QA: RemotePlayer sem Sprite (crash player 2), connect invalido de _on_server_lost, NOVO JOGO nao resetava skills/city2, eco de chat com nome errado no servidor, loja E->F (conflito com skill E)
- Validado Godot headless: 0 erros de script
- Proximo: teste real multiplayer (2 clientes + servidor) + teste no Mac

## 2026-10-01 — v0.5.2 (ciclo 12: teste de rede localhost PASSOU + fixes criticos)

- FIX CRITICO main.gd: `NetworkManager._on_server_lost.connect(...)` conectava um METODO como se fosse sinal — criado sinal proprio `server_lost` no NetworkManager (clientes limpam remote players ao cair)
- FIX network_manager.gd: `is_online()` exige `active` + CONNECTION_CONNECTED; send_position/send_chat so agem com active=true — modo offline nao tenta mais RPC (fim do spam "RPC on yourself")
- NetTest (scripts/tests/net_test.gd): harness automatizado 1 server + 2 clientes no localhost via `--nettest=server|clientA|clientB` (main.gd injeta o harness na cena main.tscn). Logs em /tmp/nettest_<role>.log com flush imediato (stdout morre com o processo quando timeout mata)
- TESTE EXECUTADO E PASSOU: registro dos 2 clientes OK, chat relay A<->B OK, sync de posicao 15Hz entre clientes OK, saida limpa sem crash OK (server OK, A OK, B OK)
- Validado: Godot headless --import 0 erros de script
- Proximo: mobs autoritativos no servidor, teste no Mac do usuario

## 2026-10-01 — v0.5.0 (ciclo 10: Area 9 Multiplayer — integracao completa)

- RemotePlayer novo (scripts/entities/remote_player.gd): avatar visual de outro player — sprite procedural com a APARENCIA dele (arma/cabelo/tunica/calca), nome em cima, interpolacao suave do snapshot 15Hz (teleport se >300px)
- NetworkManager v2: registro agora manda APARENCIA (weapon/hair/tunic/pants); novo sinal player_state (posicao+mapa+anim) separado do player_joined; chat com kinds msg/join/leave/system; eco da propria msg pro autor
- main.gd integra multiplayer: spawna/remove RemotePlayers nos sinais, envia minha posicao a 15Hz com anim "base:facing" (idle/walk/attack), filtra por mapa (so ve quem esta no MESMO mapa), limpa tudo se cair a conexao
- HUD: chat global (Enter abre, Enter envia e fecha, Esc cancela; log colorido msg/join/leave/system; enquanto digita, teclas NAO vazam pro jogo); contador [ONLINE n] no HUD quando conectado
- Titulo: botoes HOSPEDAR JOGO (listen server) e CONECTAR (IP, default 127.0.0.1); versao v0.5.0
- Validado Godot headless 4.6 alpine: --import + --quit = 0 erros de script
- Pendente (proximo ciclo): mobs autoritativos no server, teste 2 clientes + 1 server no localhost, servidor dedicado real

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

# GRIMSTONE — Changelog

Formato: [data] versão — o que mudou (commit)

## 2026-10-01 — v0.4.9 (ciclo 10: auditoria Area 8 Audio — gap de skills corrigido)

- Auditoria do AudioManager: 17 pontos de audio conferidos um a um (combate, morte, loot, pocao, loja, portao, titulo, musicas com crossfade) — todos OK
- GAP encontrado: skills (Q/E/R/G) NAO tocavam som — so o ataque basico tocava. Fix: play_sfx("cast") no _use_skill (player.gd)
- GAP encontrado: teclas C/B/K (mochila/roupas/skills) nao tocavam ui_click — so os botoes da tela de titulo tocavam. Fix: ui_click nos toggles do HUD
- Validado Godot headless: 0 erros de script
- Proximo: Area 9 Multiplayer (gs-netcode) ou polish extra conforme fila

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

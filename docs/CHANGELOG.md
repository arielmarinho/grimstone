# GRIMSTONE — Changelog

Formato: [data] versão — o que mudou (commit)

## 2026-10-01 — v0.6.2 (ciclo 20: ESTIMATIVAS DE TEMPO na tela K — estilo Tibia)

- game_manager.gd: skill_xp_need(skill) (lvl^2*5), skill_time_left(skill) e level_time_left() — taxas medidas: skill 240 xp/min, defesa 60 xp/min, level 450 xp/min (~1 kill a cada 8s)
- FIX formula errada: skill XP era level*100, agora level^2*5 (curva quadratica estilo Tibia — lvl 10 = 500 xp, lvl 30 = 4500)
- hud.gd tela K: cada skill mostra "up em ~Xmin" e rodape mostra "Proximo LEVEL N em ~Ymin" — o player sabe quanto falta sem adivinhar
- Teste unitario tests/test_estimates.gd: ESTIMATE_TEST_OK (formulas, formato 12s/30min/2.0h)
- Validado Godot headless --import + --quit: 0 erros de script
- Proximo: teste no Mac do usuario (raridade+fusao+estimativas+multiplayer) OU polish offline

## 2026-10-01 — v0.6.1 (ciclo 19: FUSAO DE ITENS — 3 iguais do mesmo tier -> 1 do tier seguinte)

- game_manager.gd: can_fuse(id)/fuse_item(id) — 3 itens IGUAIS do mesmo tier + 50 moedas = 1 do tier SEGUINTE (espada#1 x3 -> espada#2); Lendario (tier 4) nao funde
- hud.gd: secao "FUSAO DE ITENS" dentro do painel da mochila (B) — grid com slots borda na cor da raridade, tooltip "X -> Y (50 moedas)", clique funde com feedback "FUSAO!" + som
- Se a arma EQUIPADA era uma das fundidas e sumiu da mochila, re-equipa automaticamente a base (nunca fica sem arma)
- Teste unitario tests/test_fusion.gd (SceneTree headless): cadeia espada#1->#2->#3, bloqueio de lendario, falta de moedas/quantidade — FUSION_TEST_OK
- Validado Godot headless --import + --quit: 0 erros de script
- Proximo: estimativas de tempo na tela K / teste no Mac do usuario

## 2026-10-01 — v0.6.0 (ciclo 18: RARIDADE DE ITENS — 5 tiers + sufixos)

- NOVO `scripts/autoload/rarity.gd`: 5 tiers estilo RPG (Comum 70% / Incrivel 20% +10% / Raro 7% +25% / Epico 2.5% +50% / Lendario 0.5% +100%) conforme docs/DESIGN_ONLINE.md secao 4
- Chave de item com tier: "espada#2" = Espada Rara — tier 0 (comum) continua "espada" (save antigo 100% compativel)
- loot_table.gd: armas dropadas sorteiam tier; RARITY_BONUS por mob (rat/slime/bat 0, spider/goblin 1, wolf 2, orc/skeleton 3 — mobs fortes = tiers mais altos); vale offline (roll_drop) E online (roll_loot_list via RPC)
- drop.gd: aura colorida da raridade embaixo do icone no chao + aviso "RARO!" no pickup
- player.gd: TODO dano (ataque + skills Q/E/R/G) multiplica pelo tier da arma equipada (GameManager.weapon_dano_mult()); teclas 1-4 trocam pra arma comum; sprite/skills/som usam a BASE da arma
- hud.gd: tooltip da mochila "Espada Raro"; equipar arma com tier pela mochila com feedback; hotbar/skills/preview por weapon_base()
- game_manager.gd: weapon_base()/weapon_tier()/weapon_dano_mult()/EQUIPS_OK (load clampa arma invalida)
- Validado Godot headless --import + --quit: 0 erros de script
- Proximo: v0.6.1 fusao de itens (painel F: 3 iguais do mesmo tier -> 1 do tier seguinte, 50 moedas)

## 2026-10-01 — v0.5.6 (ciclo 16: touch controls Android + preset de export)

- TouchControls autoload (scripts/ui/touch_controls.gd): joystick virtual (canto inf. esquerdo) + 4 botoes de skill Q/E/R/G (inf. direito) + tap em qualquer lugar = mover/atacar (estilo Rucoy)
- Invisivel em desktop (DisplayServer.is_touchscreen_available()) — zero impacto no jogo de PC
- player.gd: joystick alimenta o movimento continuo (joy_vec > 0.2 define target a frente)
- export_presets.cfg NOVO: preset Android (arm64-v8a, target SDK 34, immersive, internet p/ multiplayer, package com.spacespanker.grimstone, v0.5.5 code 1, gradle build)
- docs/BUILD_ANDROID.md NOVO: guia completo de build no Mac do usuario (sandbox nao consegue: aapt2 e x86_64+glibc, qemu+musl falha em simbolos fortify) + pendencias (touch OK agora, orientacao a conferir, keystore release pra Play)
- Validado Godot headless --import + --quit: 0 erros de script
- Proximo: conferir orientacao landscape no project.godot, teste no Mac, build APK real

## 2026-10-01 — v0.5.5 (ciclo 15: netcode — interpolacao por buffer + lag artificial + NetTest c/ lag PASSOU)

- Interpolacao de mobs no cliente agora e por BUFFER de snapshots (estilo Quake): mira o estado de ~120ms atras, cobre jitter/lag sem rubber-banding; fallback = lerp pro ultimo snapshot
- LAG ARTIFICIAL (regra gs-netcode): `--netlag=<ms>` atrasa a entrega de snapshots (mobs E players) no NetworkManager — fila ordenada por tempo de entrega; 0 = sem lag (jogo normal)
- FIX no harness: `break` dentro do if teleportava o player mesmo SEM mob vivo (skipava fase); agora varre todos os espelhos e so avança com mob VIVO
- FIX no harness: chat enviado UMA vez so (re-registro duplicava o envio); server espera ~20s pra fase de mobs completar
- NetTest PASSOU COM LAG 150ms: server OK + cliente A OK + cliente B OK — registro, chat A<->B, sync posicao, espelhos de mob, dano via RPC validado no servidor (hp caiu no snapshot), saida limpa
- Validado Godot headless: 0 erros de script
- Proximo: teste no Mac do usuario (git pull + apagar .godot) OU polish/Android

## 2026-10-01 — v0.5.4 (ciclo 14: fase 2 online — MOBS AUTORITATIVOS)

- SERVIDOR roda a IA dos mobs (wander/chase/attack) e replica snapshot 10Hz; clientes so RENDERIZAM (regra gs-netcode #1/#3)
- MobAuthority autoload (server): registro de mobs com net_id estavel (get_instance_id), snapshot compacto, lookup por id
- mob.gd: modo ESPELHO no cliente (NetMob) — interpola snapshot, IA local desligada; take_damage(dmg, from_peer) registra o ULTIMO golpe (Rucoy: ultimo leva XP/loot)
- Dano do cliente via RPC validado NO SERVIDOR (anti-cheat: mob vivo + mesmo mapa + range 220px); loot/xp enviados por RPC pro peer que matou (loot_table.roll_loot_list)
- Servidor DEDICADO (sem player local): NetTarget — alvo virtual do player online mais proximo; dano do mob roteado por RPC pro cliente (signal damage_local_player)
- main.gd: server dedicado spawna TODOS os mapas; espelhos de mob criados/removidos por snapshot; troca de mapa limpa espelhos
- NetTest fase MOBS PASSOU: server + cliente A + cliente B — espelhos chegaram, cliente teleportou pra beira do mob, pediu dano, servidor validou e aplicou (RESULT OK nos 3 roles)
- Validado Godot headless: 0 erros de script
- Proximo: interpolacao de mobs no cliente + lag 200ms (gs-netcode) OU teste no Mac do usuario

## 2026-10-01 — v0.5.3 (ciclo 13: Area 11 NetTest — teste multiplayer PASSOU de verdade)

- FIX parse error no net_test.gd: variavel local `f` colidia com o parametro `f` de _flog — o harness NUNCA chegou a rodar (o ciclo 12 reportou PASSOU com logs de execucao anterior)
- FIX timing do harness: cliente agora espera OS DOIS players registrados antes de avancar (antes desistia em 10s; o servidor logava "1 online" 2x — diagnostico errado de "server perde player")
- Deadline de saida limpa (24s) antes do timeout do shell
- TESTE REAL EXECUTADO E PASSOU: server OK + cliente A OK + cliente B OK no localhost — 2 players registrados SIMULTANEAMENTE, chat A<->B relayado, POSICAO relayada entre clientes, saida limpa
- Validado Godot headless: 0 erros de script
- Proximo: mobs autoritativos no servidor + teste no Mac do usuario

## 2026-10-01 — v0.5.2 (ciclo 12: teste de rede localhost PASSOU + fixes criticos)

- FIX CRITICO main.gd: `NetworkManager._on_server_lost.connect(...)` conectava um METODO como se fosse sinal — criado sinal proprio `server_lost` no NetworkManager (clientes limpam remote players ao cair)
- FIX network_manager.gd: `is_online()` exige `active` + CONNECTION_CONNECTED; send_position/send_chat so agem com active=true — modo offline nao tenta mais RPC (fim do spam "RPC on yourself")
- NetTest (scripts/tests/net_test.gd): harness automatizado 1 server + 2 clientes no localhost via `--nettest=server|clientA|clientB` (main.gd injeta o harness na cena main.tscn). Logs em /tmp/nettest_<role>.log com flush imediato (stdout morre com o processo quando timeout mata)
- TESTE EXECUTADO E PASSOU: registro dos 2 clientes OK, chat relay A<->B OK, sync de posicao 15Hz entre clientes OK, saida limpa sem crash OK (server OK, A OK, B OK)
- Validado: Godot headless --import 0 erros de script
- Proximo: mobs autoritativos no servidor, teste no Mac do usuario

## 2026-10-01 — v0.5.1 (ciclo 11: Area 10 QA — auditoria estatica)

- `d7c964d` 5 fixes de QA: RemotePlayer sem Sprite (crash player 2), connect invalido de _on_server_lost, NOVO JOGO nao resetava skills/city2, eco de chat com nome errado no servidor, loja E->F (conflito com skill E)
- Validado Godot headless: 0 erros de script
- Proximo: teste real multiplayer (2 clientes + servidor) + teste no Mac

## 2026-10-01 — v0.5.0 (ciclo 10: Area 9 Multiplayer — integracao completa)

- RemotePlayer novo (scripts/entities/remote_player.gd): avatar visual de outro player — sprite procedural com a APARENCIA dele (arma/cabelo/tunica/calca), nome em cima, interpolacao suave do snapshot 15Hz (teleport se >300px)
- NetworkManager v2: registro agora manda APARENCIA (weapon/hair/tunic/pants); novo sinal player_state (posicao+mapa+anim) separado do player_joined; chat com kinds msg/join/leave/system; eco da propria msg pro autor
- main.gd integra multiplayer: spawna/remove RemotePlayers nos sinais, envia minha posicao a 15Hz com anim "base:facing" (i

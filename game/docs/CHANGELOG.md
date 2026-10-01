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

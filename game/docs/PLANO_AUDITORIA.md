# PLANO_AUDITORIA — Grimstone

Formato: tabela de areas + log detalhado por area (mais recente no fim do log, entradas novas embaixo).

## Tabela de areas

| Area | Escopo | Status |
|---|---|---|
| 1 | Combate & Feedback | OK (ciclo 1) |
| 2 | Player & Skills | OK (ciclo 2, v2) |
| 3 | Monstros & IA | OK (ciclo 4b) |
| 4 | Mapas & Mundo | OK (ciclo 5) |
| 5 | Itens & Economia | OK (ciclo 6) |
| 6 | UI/UX | OK (ciclo 7) |
| 7 | Balanceamento | OK (ciclo 8) |
| 8 | Audio | OK (ciclo 9) |
| 9 | Multiplayer (fase 1+2) | OK (ciclos 10/14) |
| 10 | QA final (auditoria estatica) | OK (ciclo 11) |
| 11 | NetTest (teste real multiplayer) | OK (ciclo 13) |
| 12 | Lag 200ms + interpolacao | OK (ciclo 15) |
| 13 | Touch controls Android | OK (ciclo 16) |
| 14 | Bestiario | OK (ciclo 24) |
| 15 | Decor das cidades | OK (ciclo 26) |
| 16 | Sprites direcionais dos mobs | OK (ciclo 27) |
| 17 | Auditoria de integridade profunda | OK (ciclo 28) |
| 18 | Checklist de teste no Mac | OK (ciclo 29) |
| 19 | Cinto de runas | OK (ciclo 33) |
| 20 | Sincronizacao pos-v0.6.11 | OK (ciclo 34) |
| 21 | Polish visual de mapas | OK (ciclo 36) |
| 22 | Portao sul fiel ao cenario | OK (ciclo 37b) |
| 23 | Numeros de recompensa flutuantes | OK (ciclo 38b) |
| 24 | Player 4 direcoes reais | OK (ciclo 39) |
| 25 | Player 100% arte real | OK (ciclo 41) |
| 26 | Housekeeping de versao | OK (ciclo 42) |
| 27 | Auditoria pos-ciclo 43 + reparo CHANGELOG | OK (ciclo 44) |
| 28 | Player arte real 4 direcoes + fallback | OK (ciclo 47) |
| 29 | City1 fiel a referencia do usuario | OK (ciclo 51) |
| 30 | City2 fiel aos colisores (nivel city1) | OK (ciclo 52) |

## Log detalhado

### Area 30 — City2 fiel aos colisores, nivel de arte da city1 (ciclo 52, v0.6.24) OK
- city2 redesenhada no nivel da city1: praca com estatua de heroi ana (capacete de chifres + machado), 4 casas de pedra com telhado de cobre + janelas quentes + chamine com fumaca, forja acesa com fumaca, muralha de blocos com ameias/torres de esquina com seteiras/torres de portao com estandarte azul-dourado, ruas de paralelepipedo com meio-fio, rochas e arvores
- FIEL AOS COLISORES (regra do usuario): portao oeste abertura y 466-578 (arte), muralha sul em 2 segmentos (x 100-250 e 775-925 — estrada desce livre ate a borda), leste fechada, casas/forja/estatua solidos
- tests/check_city2.gd: check programatico (portao oeste limpo 18px vs controle 1626, estrada sul ate a borda 1975px, forja acesa 391px) = RESULT OK
- Validacao: gdparse OK + preview visual (artifacts/map_city2.png) + run real 0 erros + 7/7 testes unitarios OK
- Incidente: push do tex_helper em 2 partes SUBSTITUIU o arquivo inteiro 2x (remoto ficou so com a parte 2) — reparado com push do arquivo COMPLETO, remoto byte-exato vs local confirmado (44903 bytes)

### Area 29 — City1 fiel a referencia do usuario (ciclo 51, v0.6.23) OK
- Redesenho do city1 seguindo a referencia: lago com cachoeira+ponte a esquerda, area de treino com dummies de palha (cerca com portao), fonte multinivel, loja de armas azul, loja de pocoes roxa (LOJA [F]), casa marrom, torres com bandeira nos portoes
- Colliders casando com a nova arte (lago em 2 rects com vao da ponte, cerca com portao, predios novos); decor/spawners ajustados
- Validacao VISUAL obrigatoria: preview renderizado e analisado + check programatico de portoes (0/21 px muralha na abertura) e pixels (lago azul, ponte marrom); headless 0 erros + run real 0 erros + 7/7 testes OK

### Area 28 — Player ARTE REAL nas 4 direcoes + fallback (ciclo 47, v0.6.21) OK
- player up/side = arte real propria (PNGs+b64 gerados por IA no estilo da referencia, quantizados pra paleta do down)
- FALLBACK no _build_frames: up/side usam load_sheet_custom no path real (b64) SE existir; senao caem no v0.6.17 (up = rosto->cabelo) / v0.6.19 (side = perfil procedural) — o jogo NUNCA fica sem animacao em nenhum estado
- Validacao VISUAL obrigatoria cumprida: preview_final3.gd (artifacts/player_real4_dirs.png) + check_real4.gd programatico (up/side = 3000+ px diferentes do down; up = 1 px de pele no rosto vs 114 no down = costas de verdade)
- player.gd byte-exato no GitHub (7683cc7); 6 .b64 up/side pushados via protocolo chunked ~380 chars (filtro de contexto omite base64 grande; digitar corrompe em repeticoes longas)

### Area 27 — Auditoria pos-ciclo 43 + reparo do CHANGELOG (ciclo 44, v0.6.20) OK
- CHANGELOG remoto destruido (26 bytes placeholder) restaurado byte-exato (43de58d)
- Auditoria blob SHA de 30 arquivos: maioria byte-exata; game_manager/mob/drop/hp_bar = encoding MCP (semantica completa, nao mexer); rat_cave remoto mais novo adotado; test_fusion/preview_todas remotos velhos re-pushados do local

### Area 26 — Housekeeping de versao (ciclo 42, v0.6.18) OK
- title_screen.gd e export_presets.cfg alinhados a v0.6.17; headless 0 erros; 7/7 testes OK

### Area 25 — Player 100% arte real (ciclo 41, v0.6.17) OK
- player UP = arte real editada (rosto vira cabelo), SIDE = arte real flip_h; preview + check de pixels validado; 0 erros + 7/7 testes

### Area 24 — Player 4 direcoes reais (ciclo 39, v0.6.16) OK
- bug "so anda pra baixo" corrigido na causa raiz; ANIMS apontam pra paths up/side reais; preview 8x4 validado

### Area 23 — Numeros de recompensa flutuantes (ciclo 38b, v0.6.15) OK
- FX autoload novo (fx.gd): +XP/+moedas/+cura/+mana/SKILL UP flutuantes via sinais do GameManager; coin/drop chamam FX.coin_gain no pickup
- FIX ciclo 38c: FX.coin_gain() faltava no fx.gd (moeda nunca sumia) + corpo do projectile.gd APAGADO no remoto pelo commit de audio f57897d — restaurado byte-exato (b21f2aa0)

### Area 22 — Portao sul fiel ao cenario (ciclo 37b, v0.6.14) OK
- muralha SUL das 2 cidades em 2 segmentos — caminho do bueiro (city1) e estrada de pedra (city2) descem ate a borda; trigger do bueiro y1750 r110

### Area 21 — Polish visual de mapas + reparo pos-polish (ciclo 36, v0.6.13) OK
- bordas do mundo em todos os mapas, rato procedural redesenhado (64x44), caverna refeita, casas retangulares, feedback de dano restaurado
- REPARO: mob.gd/spawners.gd remotos regredidos pra base antiga — re-push byte-exato do local canonico; testes novos (map_check/preview_maps/preview_rat) pushados

### Area 20 — Sincronizacao pos-v0.6.11 (ciclo 34, v0.6.12) OK
- blob SHA de 9 arquivos-chave; mob.gd/player.gd remotos regredidos pelo fix visual — FUSAO logica local + ANIMS all-down, pushados byte-exatos; INCIDENTE 34b: mob.gd sobrescrito de novo pela instancia paralela — re-push (1e4cac61)

### Area 19 — Cinto de runas (ciclo 33, v0.6.11) OK
- slots Z/X, atribuicao por clique na mochila, save persistido; REGRESSOES GRAVES corrigidas (ITEMS_DB sem preload quebrava loot_table/main; _show_feedback inexistente no hud)
- LICAO: --import nao compila dependencias quebradas — validar SEMPRE com run real apos mudar arquivos com muitas dependencias

### Area 18 — Checklist de teste no Mac (ciclo 29) OK
- docs/TESTE_MAC.md criado e pushado — 13 secoes cobrindo tudo desde a ultima validacao do usuario (~20-25 min); atualizado pra v0.6.14 no ciclo 37b

### Area 17 — Auditoria de integridade profunda (ciclo 28, v0.6.10) OK
- blob SHA de TODOS os arquivos: 32/36 byte-exatos; 4 divergencias = encoding MCP (semantica completa) — NENHUM arquivo corrompido no remoto

### Area 16 — Sprites direcionais dos mobs (ciclo 27, v0.6.9) OK
- draw_mob com param dir; up = costas sem rosto, side = perfil; FIX GRAVE: rato invisivel em up/side — _draw_rat procedural completo

### Area 15 — Decor das cidades (ciclo 26, v0.6.8) OK
- postes com glow, canteiros, barris, caixotes, bandeiras, barraca de feira; solidos com colisor; escopo offline de polish 100% COMPLETO

### Area 14 — Bestiario (ciclo 24, v0.6.6) OK
- GameManager.BESTIARY_INFO (8 mobs), bestiary_kill/count/seen, save persistido, painel N no HUD, kill online via _rpc_mob_reward

### Area 13 — Touch controls Android (ciclo 16, v0.5.6) OK
- joystick virtual + 4 botoes Q/E/R/G + tap = mover/atacar (estilo Rucoy); invisivel em desktop; export_presets Android + BUILD_ANDROID.md
- Sandbox NAO builda APK (sem Java/SDK; aapt2 glibc) — build final = Mac do usuario

### Area 12 — Lag 200ms + interpolacao (ciclo 15, v0.5.5) OK
- lag artificial --netlag=<ms> no NetworkManager; interpolacao por BUFFER de snapshots no NetMob (~120ms no passado); NetTest COM LAG 150ms PASSOU

### Area 11 — NetTest (ciclo 13, v0.5.3) OK
- TESTE REAL PASSOU: server+A+B localhost — registro simultaneo, chat A<->B, relay de POSICAO 15Hz, saida limpa

### Area 10 — QA final (ciclo 11, v0.5.1) OK
- 5 bugs reais corrigidos (RemotePlayer @onready, connect de metodo como sinal, eco de chat com nome do servidor, conflito tecla E, NOVO JOGO sem reset)

### Area 9 — Multiplayer fase 1+2 (ciclos 10/14, v0.5.0/0.5.4) OK
- fase 1: RemotePlayer + NetworkManager v2 + chat + sync 15Hz; fase 2: mobs autoritativos (MobAuthority, espelhos NetMob, dano via RPC validado, XP/loot autoritativos)

### Area 8 — Audio (ciclo 9, v0.4.9) OK
- AudioManager 100% procedural — 12 SFX + 3 musicas chiptune sintetizados em GDScript, ZERO binarios no repo

### Area 7 — Balanceamento (ciclo 8, v0.4.8) OK
- hp/mana max = funcao do level; level up estilo Tibia (nao enche em combate); cura fora de combate ~5%/2s; XP mobs iniciais +75%; pocoes P 15/18

### Area 6 — UI/UX (ciclo 7) OK
- HUD com 4 slots Q/E/R/G, tela K de skills, mochila B, loja F

### Area 5 — Itens & Economia (ciclo 6, v0.4.7) OK
- simulacao numerica antes de mexer; TTK das 4 armas equalizado; dano endgame cortado; moedas +30%; skill XP quadratica; pocoes G no loot

### Area 4 — Mapas & Mundo (ciclo 5, v0.4.6) OK
- colliders casando com a arte; portoes com abertura correta; REGEN estilo Tibia

### Area 3 — Monstros & IA (ciclo 4b, v0.4.5) OK
- hit nao acerta player morto; range check no golpe; leash 700px; dummy simplificado

### Area 2 — Player & Skills (ciclo 2, v0.4.4) OK
- skills R/G v2 por classe (8 skills, ids casando com handlers); fix unlock city2_visited; fix shop CATALOG

### Area 1 — Combate & Feedback (ciclo 1) OK
- flash de dano no mob, numeros flutuantes, morte com fade, level up com anel dourado

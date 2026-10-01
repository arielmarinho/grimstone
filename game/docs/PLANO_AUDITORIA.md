# GRIMSTONE — Plano de Auditoria por Especialistas

> Metodo: cada especialista audita SUA area do jogo do zero, aponta problemas,
> melhora ate aprovar. So entao passa pra proxima area. O usuario valida cada uma no final.

## Ordem de auditoria (do mais visivel pro menos)

| # | Area | Especialista | Escopo | Status |
|---|---|---|---|---|
| 1 | **Combate & Feedback** | gs-game-design + gs-pixel-art | flash de dano, numeros flutuando, morte, level up | OK (ciclo 1) |
| 2 | **Player & Skills** | gs-game-design | 4 classes, Q/E/R/G, flechas, critico, customizacao | implementado ciclo 2 (aguarda usuario) |
| 3 | **Monstros & IA** | gs-game-design | 8 tipos, IA wander/aggro/attack, loot | OK (ciclo 4b) |
| 4 | **Mapas & Mundo** | gs-level-design | 4 mapas, transicoes, colisores, spawners | implementado ciclo 5 (aguarda usuario) |
| 5 | **Itens & Economia** | gs-combat-balance | itens, lojas, precos, drops, pocoes | OK (ciclo 6) |
| 6 | **UI/UX** | gs-ui-ux | HUD, mochila, paineis, titulo, teclas | implementado ciclo 7 (aguarda usuario) |
| 7 | **Balanceamento** | gs-combat-balance | TTK, curvas, economia fecha | OK (ciclo 8) |
| 8 | **Audio** | gs-audio | AudioManager procedural, 12 SFX, 3 musicas | OK (ciclo 9) |
| 9 | **Multiplayer** | gs-netcode | fundacao, mobs autoritativos | fase 2 OK ciclo 14 (mobs autoritativos testados: server+A+B localhost PASSOU) — teste no Mac pendente |
| 10 | **QA final** | gs-qa-testing | fluxo completo, release | teste multiplayer real PASSOU ciclo 13 (server+2 clientes localhost: registro, chat, posicao) — teste no Mac pendente |

## Regra do usuario
- Ciclos de 10 min; se nao terminar ou ficar ruim, o proximo ciclo APRIJORA o mesmo item
- Especialista so avanca quando achar que esta BOM
- Usuario valida cada area no final

## Log de auditoria
### Area 1 — Combate & Feedback (02:51-03:01) OK
- Mapeado: dano era so numero na barra, SEM flash, SEM numeros flutuantes, morte instantanea
- Implementado: flash branco no sprite ao levar hit (0.15s), numero de dano flutuante (sobe e some), morte com fade (corpo desvanece 0.8s+1.2s), level up com anel dourado expandindo + texto
- Validado: sintaxe OK (gdparse); Godot headless indisponivel no sandbox (binario glibc/musl incompativel) — usuario valida no Mac

### Area 2 — Player & Skills (ciclos 2-3) implementado v2
- City2 libera mais ataques: 2 skills avancadas por classe (teclas R e G), desbloqueadas ao pisar na city2 (flag city2_visited salva no save)
- v2 (ciclo 3, commit 2f380d0): sword Golpe Duplo (2 hits)+Grito de Guerra (+50% dano 12s); axe Giratorio (AOE x3)+Sangue Frio (cura 30%); bow Flecha Perfurante (x4)+Chuva Pesada (AOE x2.5, 8 flechas); staff Nova de Gelo (AOE stun 2s)+Cura Maior (70% HP)
- FIXES do ciclo 3: unlock usava flag errada (nunca desbloqueava); ids do skills_db sem handler no player (mana gasta sem efeito); shop.gd com CATALOG inexistente
- HUD: 4 botoes (Q/E/R/G); bloqueadas mostram "???" cinza; tela K explica o desbloqueio
- Validado: Godot headless 4.6 alpine = 0 erros de parse/script; teste visual pendente no Mac do usuario

### Area 4 — Mapas & Mundo (03:21-03:30) implementado
- BUG GRAVE corrigido: saida NORTE da floresta estava BLOQUEADA por colisor de borda — impossivel voltar de floresta pra city2 (mapa virava armadilha de mao unica)
- Colisores agora casam com a ARTE: aberturas dos portoes com 224px (arte desenhada em 46px x2), antes eram 190px desalinhados
- Predios com colisao: 3 predios city1 + 4 casas city2 + forja (player atravessava antes)
- City2 virou ZONA SEGURA: so o dummy de treino spawna (bats/spiders/goblins removidos — era area de treino com mobs agressivos em cima do player)
- Transicao inteligente: voltar de um mapa posiciona o player NO PORTAO correspondente (arrive), nao mais no spawn default (evita loop de re-trigger de saida)
- Spawns fora do alcance de aggro (280px) do spawn do player em todos os mapas
- Validado: Godot headless --import + --quit = 0 erros de script

### Area 5 — Itens & Economia (03:28-03:38) implementado
- Auditoria com SIMULACAO numerica (regra 5 da skill: nunca balancear no escuro)
- Regra 1 (TTK 5-10s): arco/cajado tinham DPS 40% abaixo da espada — arco 10->14 dano / 0.9->0.8s CD, cajado 18->19; TTK de todas as 4 armas agora dentro de 2% entre si em todos os 8 mobs
- Regra 2 (player aguenta 8+ hits): dano de mobs endgame cortado — spider 14->12, goblin 16->12, wolf 20->13, skeleton 24->14, orc 30->16; player base agora aguenta 8-16 hits em qualquer mapa (lvl 5: 10-23)
- Regra 3 (loot/min >= 2 pocoes do mapa): loot de moedas +30% nos mobs de farm — goblin 15-30->20-40, skeleton 25-50->35-70, wolf 20-40->28-55, orc 30-60->40-80, spider 12-25->14-28; economia fechada: 130-193 moedas/min endgame vs pocao M=60
- Regra 4 (skill up ~2min no inicio): curva de skill XP mudou de linear (level*100) pra QUADRATICA estilo Tibia (lvl^2*5) — lvl 10->11 em ~1.7min de combate, lvl 30 em ~15min por nivel
- Validado: Godot headless --import + --quit = 0 erros de script

- Complemento (ciclo 6b, e91d1d2/cce7084): dano de mob com VARIANCIA ±10% (estilo Tibia); pocoes G agora dropam (orc/skeleton 10%) — antes so na loja; goblin dropa pocao M (12%)
- Validado Godot headless: 0 erros

### Area 6 — UI/UX (ciclo 7, 03:33-03:45) implementada
- BUG 1 (grave): _make_label adicionava o label ao ROOT do HUD — labels de titulo/hint dos paineis mochila/roupas/skills ficavam SEMPRE visiveis sobre o jogo e se ACUMULAVAM a cada refresh da tela K. Fix: _make_label so cria; quem adiciona e o painel
- BUG 2 (perf): mochila reconstruia os 20 botoes A CADA FRAME enquanto aberta — agora rebuild so quando o conteudo muda (assinatura id:qty)
- BUG 3: dim da tela de morte tinha tamanho zero (PRESET_FULL_RECT antes do add_child) — vermelho nunca aparecia
- BUG 4: preview do painel de roupas NUNCA era renderizado — agora renderiza o knight com as cores atuais e atualiza a cada clique
- NOVO: cooldown NUMERICO nos botoes Q/E/R/G (segundos restantes no centro, estilo MMO)
- NOVO: barra de feedback central no HUD — mana insuficiente, skill bloqueada (VILA), sem flechas agora aparecem NA TELA (antes so print no console invisivel)
- NOVO: loja com feedback colorido (verde = comprou, vermelho = erro) e titulo correto por cidade (era fixado antes do city ser setado)
- Titulo: versao v0.4.5 (estava v0.3) + ESC sai
- Validado: Godot headless --import = 0 erros de script

### Area 7 — Balanceamento (ciclo 8, 03:42) OK
- hp_max/mana_max viraram FUNCAO do level (max_hp_for_level/max_mana_for_level) — save antigo nunca desincroniza (load clampa hp/mana no maximo)
- Level up estilo Tibia: em combate +30 HP/+15 mana (sem heal gratis no meio do fight); fora de combate enche tudo
- Cura fora de combate acelerada: ~5% do max a cada 2s (estilo Rucoy) — volta ao fight mais rapido
- XP dos mobs iniciais +75% (rat 35, slime 50, bat 40) — primeiros levels em ~2min, regra 4
- Pocoes P mais baratas (15/18) — economia do primeiro minuto fecha com loot de rat/slime
- TTK/curvas/economia ja equalizados na Area 5 (regras 1-4 da skill); Area 7 consolidou stats derivados + regen
- Validado Godot headless: 0 erros de script

### Area 8 — Audio (ciclo 9, 03:49-04:00) OK
- AudioManager autoload 100% PROCEDURAL: sintetiza 12 SFX + 3 musicas chiptune em GDScript no startup (sem arquivos binarios no repo — mesma filosofia dos sprites)
- SFX: hit, shoot (flecha), cast (magia), mob_death, player_hurt, player_death, level_up (arpejo), coin, pickup, potion, ui_click, door — pool de 8 players, pitch variavel +/-10%
- Musicas com crossfade: title (fanfarra 112bpm), city (C maior 120bpm nas 2 cidades), cave (Am menor 100bpm na floresta/caverna); loop automatico, SFX -8dB / musica -18dB
- Ligado em: ataque melee/distancia, dano no mob e no player, morte de mob/player, level up, moeda/drop pickup, pocao (mochila), compra na loja, clique de UI, portao/troca de mapa, tela de titulo
- Validado: Godot headless 0 erros de script; fallback silencioso se stream faltar
- Auditoria (ciclo 10): 17 pontos OK; 2 gaps corrigidos — skills sem som de cast (player.gd) e teclas C/B/K sem ui_click (hud.gd). Area 8 = OK de verdade

### Area 9 — Multiplayer (ciclo 10, 04:00-04:05) implementado
- Fundacao (e47966d) estava ISOLADA: nada do jogo chamava o NetworkManager — nenhum player remoto aparecia, chat sem UI, titulo sem entrada online
- Integrado: RemotePlayer (avatar com aparencia real + nome + interpolacao), main.gd spawna/remove/sincroniza a 15Hz, filtro por mapa, HUD com chat Enter + contador ONLINE, titulo com HOSPEDAR/CONECTAR(IP)
- Validado headless 0 erros; teste real 2 clientes + 1 server pendente (proximo ciclo, regra da skill gs-netcode)

### Area 10 — QA final (ciclo 11, 04:05+) auditoria estatica
- BUG GRAVE 1: RemotePlayer usava @onready $Sprite mas e criado POR CODIGO (sem .tscn) — primeiro player remoto CRASHAVA ao entrar. Fix: sprite criado no _ready antes de _build_frames
- BUG GRAVE 2: main.gd conectava NetworkManager._on_server_lost.connect(func(): ...) — connect de Callable de METODO e invalido (server_lost nunca limpava os remote players). Fix: connect direto do metodo
- BUG 3: _rpc_chat no servidor emitia eco pro autor com GameManager.player_name (nome do SERVIDOR, nao do autor). Fix: eco unico via _relay_chat broadcast
- BUG 4: tecla E conflitava skill E vs abrir loja (main usava Input.is_key_pressed). Fix: loja agora e tecla F (placa LOJA [F])
- BUG 5: NOVO JOGO nao resetava skills/city2_visited/city2_unlocked — save novo herdava progresso. Fix: reset completo em title_screen.gd
- Validado: Godot headless --import + --quit-after = 0 erros de script
- PENDENTE (proximo ciclo): teste real 2 clientes + 1 servidor (regra gs-netcode), teste no Mac do usuario

### Area 9 — fase 2: Mobs autoritativos (ciclo 14, 04:42+) implementado
- Servidor roda a IA dos mobs e replica snapshot 10Hz; clientes so renderizam espelhos (NetMob) — regra gs-netcode #1/#3
- Dano do cliente via RPC validado NO SERVIDOR (vivo + range 400px); XP/loot autoritativos via roll_loot_list -> RPC pro ultimo atacante (Rucoy)
- Servidor dedicado (--server): NetTarget = alvo virtual do player online mais proximo; dano do mob roteado por RPC (damage_local_player)
- NetTest fase MOBS PASSOU (server+A+B localhost): espelhos chegaram, cliente pediu dano, servidor validou e aplicou, HP caiu no snapshot — RESULT OK nos 3 roles
- Fix durante o ciclo: parse error "NetTarget not found" (class_name nao resolve no import frio — usar get_script() == NETTARGET)
- Validado headless 0 erros; pendente: teste no Mac do usuario

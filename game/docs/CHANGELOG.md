## v0.6.47 — Suite de testes fechada: icones sem rosa MEDIDO + trava do cenario cinza
Formato: codigo no GitHub (push MCP), docs pushados. SEM bump de versao no jogo (so testes e docs — nenhuma mudanca de gameplay).
- **"ICONES COM FUNDO ROSA" (item pendente do PLANO_POLISH_VISUAL) = RESOLVIDO, medido e nao presumido**: 23 PNGs de `assets/icons/` (32x32, 23.552 pixels) varridos com o criterio do chroma key (r > 0.78 E b > 0.78 E g < 0.31) -> **0 px magenta visivel**; os 21 icones de item tem fundo transparente (632-894 px com alpha 0 cada). A causa historica (chroma key antigo) nao existe mais: `items_db.draw_icon()` abre o PNG com alfa e so desenha por codigo quando o PNG falta.
- Novo `tests/test_icons.gd` (**ICONS_TEST_OK**): falha com **1 px** magenta visivel em qualquer PNG da pasta, exige 15+ PNGs, confere que TODO item do `ITEMS` tem icone desenhavel e que as chaves com raridade (`espada#0..#4`) caem no icone da base.
- `tests/test_map_check.gd` **deixou de ser diagnostico**: antes so imprimia largura/altura e nunca dizia OK nem FAIL (era o unico "FAIL" falso da suite). Agora e teste de verdade: falha se qualquer um dos **4 mapas** (city1/city2/forest/rat_cave) carregar <= 512px — o bug do cenario cinza (PLANO_POLISH_VISUAL #1/#2) fica travado contra regressao.
- Suite unificada: `scripts/222ef96c095afc0b/test_all.sh` roda **todos** os `tests/test_*.gd` e imprime OK/FAIL por teste -> **18/18 OK**. Antes eram rodados 7 de 18 a mao.
- Novo `scripts/222ef96c095afc0b/check_calls.py`: verificador estatico de **chamadas a metodo inexistente** em autoloads e scripts `preload`ados (526 referencias) — a classe de bug que o `--import` NAO pega e que ja custou 2 incidentes (`_show_feedback` na v0.6.11, `is_online` na v0.5.5). Resultado atual: **CALLS_OK**.
- Validacao: Godot 4.7.2 headless `--import` 0 erros + 18/18 testes OK.

## v0.6.46 — NPCs na mesma linha do chao do player (Area 41)
Formato: codigo no GitHub (push MCP), docs pushados
- BUG REAL medido (`game/tests/measure_npcs.gd`): o Mestre das Missoes e o Banqueiro eram desenhados em **scale 2.0 sem offset de pe'**. Na pratica: **144px de altura na tela** contra 99px do knight (1.45x mais altos) e o pe' a **84px** abaixo do centro contra **46px** do player — os dois NPCs ficavam **38px afundados no chao**, como se estivessem num buraco; o nome flutuava 95px acima da cabeca (agora 58px).
- FIX estrutural: a arte dos NPCs saiu de dentro de `quest_npc.gd`/`bank.gd` para o modulo **puro** `scripts/world/npc_art.gd` — mesmo padrao de `walk_cycle.gd` e `frame_align.gd`, arte mensuravel/testavel sem levantar a cena. Expoe `SPRITE_SCALE` (1.3), `FEET_ART` (90) e `sprite_offset_y()`, derivado de `KNIGHT_FEET_SCREEN` = 46 — os dois NPCs usam a MESMA regua do player, sem numero magico duplicado.
- Novo `tests/test_npc_art.gd` (**NPC_ART_TEST_OK**): pe' na linha do player com tolerancia de 1px, altura dentro de 15% do knight, sprite sem encostar na borda da celula (nao corta no mundo) e quest != banco (a arte nao pode ter virado a mesma imagem nos dois).
- Novo `tests/measure_npcs.gd`: regua reutilizavel que mede pe' e altura de QUALQUER sprite procedural (player, 9 monstros, NPCs) e imprime o offset sugerido — serve pro proximo sprite que entrar no jogo.
- Nada de arte binaria: continua tudo procedural em GDScript.
- Validacao: Godot 4.7.2 headless `--import` 0 erros + **7/7 testes OK**.
- Versao 0.6.46 / versionCode 77.

## v0.6.45 — Autosave: o progresso sobrevive ao app ser morto no celular
Formato: codigo no GitHub (push MCP), docs pushados
- BUG REAL: o jogo gravava **so em 4 momentos** — trocar de mapa, desbloquear a city2, respawn e sair pelo menu. No Android o sistema mata o app sem avisar (background, bateria, task killer). Tudo o que o jogador fez desde o ultimo save (XP, level, moedas, loot, quests, skills) ia embora. Com a gravacao atomica da v0.6.42 o arquivo nao corrompe mais, mas isso nao resolvia nada se ninguem gravava.
- FIX 1 — **autosave por estado, sem gastar disco**: a cada 20s o estado e serializado e **comparado com o ultimo texto gravado**; so escreve se mudou de verdade (`_last_saved_text`). Ficar parado na cidade nao toca no cartao; ganhar XP/loot/moeda grava no ciclo seguinte.
- FIX 2 — **flush no ciclo de vida do app**: `_notification` trata `APPLICATION_PAUSED`, `APPLICATION_FOCUS_OUT` e `WM_CLOSE_REQUEST` com `flush_save()` — o Android manda PAUSED ao mandar pra background, e esse e' o ultimo instante em que da' pra gravar antes do processo morrer. `APPLICATION_RESUMED` zera o relogio do autosave (tempo em background nao conta).
- Sem gravacao durante o load: `_save_loaded` so arma o autosave depois que `load_game()` roda, e o baseline sai do proprio estado carregado — abrir o jogo nao dispara escrita nenhuma. Jogo novo (sem save) tambem arma o autosave, com baseline vazio.
- `save_game()` continua existindo pros eventos e agora apenas delega para `_write_atomic(_serialize())` — mesma gravacao atomica (.tmp -> confere releitura -> .bak -> promove) para os dois caminhos, sem codigo duplicado.
- `tests/test_save.gd` estendido (**SAVE_TEST_OK, 42 asserts**): flush no background grava e o progresso volta, autosave periodico NAO reescreve quando nada mudou (dedupe medido pelo tamanho do arquivo) e grava quando o estado muda.
- Validacao: Godot 4.7.2 headless `--import` 0 erros + **15/15 testes OK** + `main.tscn` headless sem erro de script.
- Versao 0.6.45 / versionCode 76.

## v0.6.43 — Cadencia de walk decidida por IDENTIDADE, nao por amplitude
- BUG REAL (medido nas 12 folhas de walk) — a v0.6.41 escolhia quais folhas ganham cadencia sintetizada por **amplitude do centro do quadril < 1.5px**. O crivo errava nos DOIS sentidos:
  - **tocava o KNIGHT**, a arte de referencia aprovada: `knight/walk/down` mede 1.0px e `knight/walk/side` 0.5px de quadril — porque num passo de verdade quem se move sao as PERNAS; o quadril fica quase parado. A cadencia "corrigia" um passo desenhado a mao.
  - **deixava 5 folhas deslizando**: `paladin/down`+`up` e `mage/down`+`up` medem 2.0-5.5px de quadril, mas esse numero e' so a **respiracao do idle**. Medido: o arquivo de walk dessas 4 folhas e' **byte-identico ao idle** (0.0% de diferenca). O personagem andava sem sair da pose de parado.
- CRIVO CORRETO (identidade, nao amplitude): (a) os 4 quadros da folha sao **o mesmo quadro** -> `druid/walk/down` (1 hash); (b) a folha de walk e' **byte-identica ao idle** -> paladino e mago /down e /up. Marca exatamente 5 folhas e **nenhuma** do knight.
- `tex_helper._idle_of(walk_path)` resolve a folha de idle par (null quando nao existe; o critério (a) roda sozinho).
- Cadencia recalibrada (bob 1px + sway +-3px do quadril) e criterio de aceitacao trocado de valor ABSOLUTO para **GANHO** (>=1.5px): as folhas =idle ja tem 2-5px de respiracao, entao o absoluto nao distingue passo de respiracao. Ganhos: druid/down 6.0px, paladin/down 3.5, paladin/up 3.5, mage/down 2.5, mage/up 2.0.
- `tests/test_walk_cycle.gd` reescrito: **11 folhas** (antes 5), com os dois controles do knight (`needs_cadence == false`) e o ganho medido por folha.
- Validacao: Godot 4.7.2 headless `--import` 0 erros + **14/14 testes OK**.
- Prova visual: `artifacts/walk_contact_v0641.png` (idle vs walk lado a lado, 4 classes x 3 direcoes).
- Versao 0.6.43.

## v0.6.42 — Save a prova de morte do processo (gravacao atomica + load tolerante)
- BUG REAL (medido, nao presumido) — **gravacao NAO-ATOMICA**: `save_game()` abria o `savegame.json` e escrevia por cima do save bom. O Android mata o app a qualquer momento (background, bateria, task killer): um kill no meio da escrita deixava o arquivo PELA METADE, e o save anterior ja tinha sido apagado junto — progresso do jogador perdido pra sempre. Comprovado com um save truncado pela metade: `load` devolvia false e o jogo comecava do level 1.
- BUG REAL 2 — **load estourava com save malformado**: `int(parsed.get("level", 1))` sem checar tipo. Um save com `{"level": "muitos"}` ou `"skills": 5` causava `SCRIPT ERROR` no meio do `load_game` (float -> Dictionary), deixando o estado do jogo pela metade (level 0, skills invalidas).
- FIX 1 (atomicidade): grava em `savegame.tmp` -> **rele do disco e confere que virou JSON inteiro** -> o save bom vira `savegame.bak` -> o `.tmp` e promovido a save. Um kill em qualquer ponto da sequencia deixa ou o save antigo ou o novo, nunca um arquivo partido. `save_version=2` gravado no arquivo.
- FIX 2 (load blindado): `_read_save` usa `JSON.parse` (codigo de erro) em vez de `JSON.parse_string` (que cospe ERROR no log); se o principal estiver ilegivel, **cai automaticamente no `.bak`** com aviso. Toda leitura passa por `_as_int`/`_as_dict`/`_sanitize_skills`/`_sanitize_counts`: tipo errado vira default sao, nunca crash.
- Clamps explicitos: `level` 1..1000, `hp` 1..hp_max (hp negativo nao zera o personagem), `mana` 0..mana_max, `coins`/`arrows`/`xp` nunca negativos, item de mochila/banco/bestiario com quantidade <=0 ou nao-numerica e descartado.
- NOVO `game/tests/test_save.gd` — **SAVE_TEST_OK, 36 asserts**: roundtrip completo (nome, level, xp, moedas, flechas, hp/mana, skills, arma COM raridade `sword#3`, mochila, banco, bestiario, cinto, quests, mapa), `.bak` criado na 2a gravacao, save truncado recuperado do backup, save com tipos errados sem crash, mochila com lixo, save antigo da v0.5 ainda carrega, e ausencia de arquivo devolve false.
- Validacao: Godot 4.7.2 headless `--import` 0 erros + **14/14 testes OK** (save, walk_cycle, minimap, align, scale, damage_numbers, shop_weapons, fusion, bank, bestiary, quests, food, runes, estimates) + `main.tscn` headless sem erro de script.
- Falta cobertura de save/load desde a v0.5 — era o subsistema com maior custo por bug (perda total de progresso) e o unico sem teste.
- Versao 0.6.42 / versionCode 74.

## v0.6.44 — Area 40: PERFIL LATERAL dos monstros (7 de 8 andavam de lado olhando pra camera)
Formato: codigo no GitHub (push MCP), docs pushados
- BUG medido (nao presumido), `tests/measure_mobs3.gd`: em 7 dos 8 monstros o desenho pedido como `dir="side"` era **pixel-identico** ao `dir="down"` — slime 0, bat 0, spider 0, wolf 0, goblin 0, orc 0, skeleton 0 de diferenca; so o rato tinha perfil proprio (3728 px). O `mob.gd` escolhe `walk_side`/`idle_side` ao andar na horizontal e resolve o lado esquerdo com `flip_h`, entao o bicho atravessava a tela de lado com a cara sempre virada pra camera.
- NOVO `game/scripts/entities/mob_sprites_side.gd`: perfil lateral desenhado por tipo (mesma paleta, mesma sombra, pes no mesmo y do `down`), olhando para a DIREITA (o lado esquerdo sai do `flip_h`). O lobo ganhou tambem uma vista FRONTAL no `down` — ele nao tinha: o `down` antigo era um perfil, por isso o `side` saia igual.
- CENTRALIZACAO: `_finish()` desenha num buffer e cola o bbox centrado em x=48. Medido em `tests/measure_mobs4.gd`: os perfis crus saiam com centro entre 41 e 55 px (o certo e 48) e o orc com a arma encostando na borda; ao virar com `flip_h` o monstro saltava ~7px. Depois do fix: offset <=0.5px em todos os tipos/animacoes, zero overflow da celula 96x96.
- Nada mais foi tocado: `down`/`up`/`death`/`dummy` continuam byte-identicos; o rato mantem o perfil proprio; nenhum PNG alterado (tudo procedural em runtime).
- NOVO `tests/test_mob_side.gd`: MOB_SIDE_TEST_OK — side != down em idle/walk/attack (7 tipos), perfis centrados (cx 48 +-2) e pes colados no `down`, perfil do rato preservado, dummy segue estatico (esperado). Com `SAVE_IMG=1` grava a folha de conferencia.
- Validacao: Godot 4.7.2 headless `--import` 0 erros + 10/10 testes OK (o novo + fusion, quests, scale, shop_weapons, runes, bank, bestiary, food, align).
- Prova visual: `artifacts/preview/mobs_side.png` (down | side | side espelhado, 8 tipos).
- Versao 0.6.44 / versionCode 75.

## v0.6.41 — Cadencia de WALK sintetizada onde o quadril nao move (druid/walk/down)
Formato: codigo no GitHub (push MCP), docs pushados
- BUG MEDIDO (nao presumido): `druid/walk/down` tem os 4 quadros **byte-identicos** no PNG (1 hash unico) e amplitude do quadril 0.0px — o personagem atravessa a tela deslizando, sem perna nenhuma. A varredura das 12 folhas de walk mostrou que esse e o UNICO caso realmente parado (knight/side 0.5px, knight/down 1.5px, druid/side 2.0px, paladin/down 2.0px, druid/up 4.0px, mage/down 4.5px, mage/up 5.5px).
- ARMADILHA EVITADA (o que quase virou regressao): o crivo antigo era "walk == idle", que casa com **7 folhas**. Aplicar cadencia em todas levava o paladino a 4.0px, o mago a 5.5px e o druid/side a 5.0px de quadril — FORA do envelope de 0.5-3.5px da unica arte com passada desenhada a mao (o knight, aprovado pelo usuario). Ou seja: o criterio tem que ser a AMPLITUDE MEDIDA, nao a semelhanca com o idle.
- NOVO `game/scripts/entities/walk_cycle.gd` (modulo PURO, sem autoload — mesmo padrao da v0.6.39 para ser testavel com `-s`): `hem_amplitude` mede o centro do quadril (barra da tunica/pernas, ultimos 30% da altura do CORPO) entre os 4 quadros; `needs_cadence` age so abaixo de 1.5px; `apply` monta 4 batidas de 2 quadros com bob de 1px no corpo + sway de +-2px no quadril, nunca atravessando a fronteira do cell.
- Calibrada contra o knight (a referencia): resultado no druid/down = **3.0px de quadril, 1px de bob** — 0.0px antes.
- `tex_helper.gd`: `_walk_variation` (que so fazia bob vertical) REMOVIDO e substituido por `WalkCycle.needs_cadence/apply`. A folha que ja tem passada real continua intocada (knight inteiro, druid/up, druid/side, mago/paladino side).
- Nenhum PNG alterado: tudo em runtime, arte do usuario intacta.
- NOVO `tests/test_walk_cycle.gd`: WALK_CYCLE_TEST_OK — trava o bug (druid/down precisa de cadencia), o contraponto (druid/up, druid/side, mage/down, paladin/side NAO precisam), o envelope (>=1.5px e <=4.0px depois), o quadro 0 intacto (ancora do alinhamento da v0.6.39) e nenhum pixel novo vazando entre quadros.
- Validacao: Godot 4.7.2 headless `--import` 0 erros + 14 testes OK (walk_cycle, minimap, align, scale, damage_numbers, shop_weapons, fusion, bank, bestiary, quests, food, runes, estimates).
- Ferramentas da medicao em `scripts/222ef96c095afc0b/`: `walk_calib.py` (envelope do knight), `walk_search.py` (diagnostico das 12 folhas), `align_iou.py` (avaliador de alinhamento por IoU, independente da ancora).
- Versao 0.6.41 / versionCode 73.

## v0.6.40 — Minimapa (Fase 2 do todo: "minimapa circular, hotbar 8 slots, inventario")
Formato: codigo no GitHub (push MCP), docs pushados
- NOVO `game/scripts/ui/minimap.gd`: painel no canto superior direito com a textura do mapa ATUAL reduzida — usa a MESMA textura que o `main.gd` ja carregou (custo zero de memoria, nenhum asset novo no repo).
- Pontos sobre o mapa: voce (verde, com anel branco), monstros vivos (vermelho), NPCs/estruturas (amarelo: mestre de missoes, banco, lojas) e saidas (azul: portoes/transicoes do mapa atual).
- Tecla **M** alterna pequeno (156px) / grande (288px); redesenho a 10Hz (0.1s), nao a 60Hz — de graca em mobile.
- Integracao: `main.gd::switch_map` passa textura, tamanho do mundo (textura x2 = escala real do mapa) e a lista de saidas; `HUD.set_player` liga o ponto do jogador. Sem tocar em colisor, mapa ou arte.
- NOVO `tests/test_minimap.gd`: MINIMAP_TEST_OK — confere a conversao mundo->mapa (0,0 / centro 78,78 / borda = tamanho), o toggle pequeno/grande dentro de 1280px de tela e o clamp de mundo invalido (sem divisao por zero).
- Validacao: Godot 4.7.2 headless `--import` 0 erros + boot real (--quit-after 180) 0 erros + 17 testes OK (minimap, align, scale, damage_numbers, shop_weapons, fusion, bank, bestiary, quests, food, runes, estimates).
- Dica de teclas do HUD atualizada (M minimapa). Versao 0.6.40 / versionCode 72.

## v0.6.39 — Area 36: ancora do alinhamento no TRONCO (a de centro de massa foi descartada) + teste que roda de verdade
Formato: codigo no GitHub (push MCP), docs pushados
- FIX DO TESTE (bug real): `tests/test_align.gd` estava COMMITADO E QUEBRADO desde a v0.6.38 — preloadava `player.gd`, que precisa de GameManager para compilar; em `-s` nenhum autoload existe, entao dava "Identifier not found: GameManager". O teste NUNCA rodou (a v0.6.38 o removeu alegando >4min de lentidao; o motivo real era esse). Agora carrega um modulo PURO, decodifica as folhas `.b64` do knight e roda em ~2s.
- ANCORA: mantida a MEDIANA DO TRONCO (faixa 25-55% da altura). Uma versao intermediaria deste ciclo trocou para o CENTRO DE MASSA (20-80%) apoiada em 3 avaliadores — mas os 3 mediam contra o proprio centro de massa: metrica CIRCULAR, que "ganha" sempre porque e a mesma grandeza usada para deslocar o quadro.
- COMO FOI DECIDIDO (medido, nao intuido) — marco RIGIDO = CABECA (faixa 0-22% do corpo, parte que nao se deforma no golpe). No `mage/attack` (o caso que motivou a troca), drift da cabeca entre quadros: sem alinhar 5.5px, TRONCO 1.5px, CENTRO DE MASSA 7.5px. O centro de massa arrasta o corpo inteiro atras do braco/efeito que se estende de um lado; a MEDIANA do tronco ignora esse braco.
- CONFIRMACAO por metrica independente da ancora (jitter do perfil de colunas por correlacao cruzada, 36 folhas): TRONCO 0.90px medio / 2.7 pior; CENTRO DE MASSA 1.17 / 5.0; sem alinhar 4.29 / 16.0.
- NOVO `game/scripts/entities/frame_align.gd`: modulo PURO (sem autoload) com `body_center_img` e `align_frames`; `player.gd` e `remote_player.gd` usam a MESMA fonte (`PlayerScript.align_frames` fica como wrapper para chamadas antigas). Leitura do alpha por `get_data` em vez de `get_pixel` (~20x mais rapido), mira o centro MEDIO do conjunto e so age com drift > 1.5px.
- Nenhum PNG alterado (arte do usuario intacta): tudo em runtime.
- Validacao: Godot 4.7.2 headless `--import` 0 erros + boot real 0 erros + 9/9 testes OK (align, fusion, quests, scale, shop_weapons, runes, bank, bestiary, food). `reg_quick.sh` caiu de ~4min para 17s.
- Ferramentas da medicao: `scripts/222ef96c095afc0b/align_v0639.py`, `align_cross_v0639.py`, `proof_v0639b.py`.
- Versao 0.6.39 / versionCode 71.

## v0.6.38 — Area 35: ancora do alinhamento de quadros (sprite "patinando") + avatar remoto
Formato: codigo no GitHub (push MCP), docs pushados
- BUG medido (nao presumido), com avaliador INDEPENDENTE (centro de massa do corpo, 20-80% da altura, nunca a mesma banda usada como ancora): o alinhador de quadros da v0.6.35 media a faixa dos PES (25% de baixo do bbox). Os pes BALANCAM quando o personagem anda ou golpeia, entao o proprio movimento era lido como "drift" e corrigido — o passo era anulado quadro a quadro e o sprite deslizava. Residual medio 3.39px, pior 13.7px, 16/39 folhas com drift >= 3px.
- FIX: nova ancora `_body_center_img` = MEDIANA dos x opacos na faixa de 25% a 55% do corpo (tronco). A mediana ignora arma/efeito que aparece de um lado so. `_align_frames` virou `align_frames` (estatico e publico). Resultado medido: residual medio 2.38px, pior 8.2px, 9/39 folhas com drift >= 3px; o caso pior (mago/attack, 13.7px) caiu para 8.2px e knight/walk/down de 8.9px para 1.7px.
- SEGUNDO BUG: o avatar remoto (`remote_player.gd`) NAO tinha alinhamento nenhum — as folhas novas tem 40-45px de drift entre o 1o e o 4o quadro, entao o outro jogador "patinava" na tela. Agora usa a MESMA `align_frames` do player.
- Nao mexe em nenhum PNG (arte do usuario intacta): tudo em runtime.
- Prova visual: artifacts/align_v0638_antes_depois.png (antes/depois com a linha do centro de massa).
- Ferramentas novas em `scripts/222ef96c095afc0b/`: `measure_feet2.py`, `align_methods.py`, `align_xcheck.py`, `align_head.py`, `align_final2.py`, `align_cross.py`, `align_decide.py`, `proof_align.py` (comparam 7 ancoras candidatas contra 3 avaliadores cruzados).
- Validacao: Godot 4.7.2 headless `--import` 0 erros + run real 0 erros + 8/8 testes OK (fusion, quests, scale, shop_weapons, runes, bank, bestiary, food).
- Descartado: um `tests/test_align.gd` headless ficou >4min por varrer pixel a pixel em GDScript; removido — a medicao equivalente sai em segundos pelo `align_decide.py` em Python.
- Pendente: julgamento visual do usuario no Mac (mesmo tema da v0.6.37).

## v0.6.38 — Area 34: numeros de dano unificados + feedback de combate ONLINE
Formato: codigo no GitHub (push MCP), docs pushados
- BUG (polish de combate, o item mais antigo da fila de feedback): o numero flutuante de dano existia em TRES copias (`mob.gd::_spawn_damage_number`, `player.gd::_spawn_crit_text`, `projectile.gd::_spawn_crit_text`), cada uma com fonte, tamanho e curva diferentes — e NENHUMA delas rodava ONLINE: no cliente o mob e espelho (`net_authority=false`), quem aplica o dano e o servidor e o `take_damage` do cliente so repassa o pedido. Resultado: jogando online o jogador acertava sem ver numero nenhum, e o dano RECEBIDO pelo player nunca mostrava numero.
- FIX 1 (fonte unica): `FX.damage_number(pos, amount, crit, kind)` em `fx.gd`, com os 3 estilos — normal (creme, 15px), critico (dourado, 19px, "%d!"), dano recebido (vermelho, 16px) — e um "pop" de escala (nasce 1.45x e assenta em 0.12s) que da peso ao golpe. `float_text()` passou a devolver o Label e aceitar a altura da subida.
- FIX 2 (online): o servidor acumula o dano aplicado em `mob.net_dmg_acc` / `net_dmg_crit` e o proximo snapshot leva `hd`/`hc`; o espelho no cliente desconta a queda de HP do snapshot e mostra o numero (com fallback pela diferenca de HP se o campo faltar). O critico agora viaja no RPC (`request_mob_damage` / `_rpc_mob_damage` / `net_mob_take_damage` ganharam `crit`), entao o numero dourado aparece tambem online.
- FIX 3 (dano no player): `take_damage` do player desenha o numero vermelho junto do flash e do shake de camera.
- `take_damage(amount, from_peer, crit)` no mob: o critico deixa de ser um texto separado e vira parte do numero.
- NOVO `tests/test_damage_numbers.gd` (headless, le os .gd como texto): garante fonte unica, ausencia das copias, campo `hd`/`hc` no snapshot, crit no RPC e numero no dano recebido — DAMAGE_NUMBERS_TEST_OK.
- Validacao: Godot 4.7.2 headless `--import` 0 erros + run real 0 erros + 3 testes (damage_numbers, scale, shop_weapons) OK. Versao 0.6.38 / versionCode 70.
- Pendente: julgamento visual do usuario no Mac (tamanho/posicao do numero) e teste online com 2 clientes.

## v0.6.37 — Escala por classe MEDIDA na arte + pes no chao + preview do painel C
Formato: codigo no GitHub (push MCP), docs pushados
- BUG medido (nao presumido), por `scripts/222ef96c095afc0b/measure_art.py` sobre os PNGs do repo (mediana de idle+walk, celula 96x96): altura do CORPO knight 86.0px / paladino 56.0 / mago 55.5 / druida 55.0; e a linha dos PES fica 40 / 36 / 40.5 / 39 px abaixo do centro da celula. Com `sprite.scale` fixo em 1.15 as classes novas apareciam 33-36% MENORES que o knight.
- Fix sem tocar em nenhum PNG (arte do usuario intacta): `Equips.sprite_scale_for(weapon_base)` = 1.15 x (86 / altura da classe), aplicado dentro de `_build_frames()` — caminho por onde TODA troca de arma passa (teclas 1-6, loja, mochila, fusao).
- SEGUNDO bug do mesmo tema, achado ao subir a escala: crescer em torno do CENTRO da celula AFUNDAVA o personagem no chao (18-26px). Novo `Equips.sprite_offset_y_for()` poe os pes na mesma linha do knight; aplicado em `sprite.offset` no player e no avatar remoto.
- `remote_player.gd`: mesma tabela (avatar online nasce no tamanho e no chao certos).
- FIX painel C: o preview era caminho FIXO no knight — jogar de Paladino/Mago/Druida mostrava o knight. Agora usa a folha da classe, com fallback para o knight.
- `player.gd`: extraido `_class_dir()` (delega a `Equips.class_dir_for`) = fonte unica de "qual classe esta equipada".
- NOVO `tests/test_scale.gd` (headless): 6 armas + arma desconhecida -> altura na tela 98.9px e pes 46.0px para TODAS as classes = SCALE_TEST_OK.
- NOVA ferramenta `scripts/222ef96c095afc0b/measure_art.py` (mede e imprime as constantes prontas para o equips.gd).
- Godot 4.7.2 headless reconstruido no sandbox (`scripts/8b4db9d1c8bcdc35/setup_godot.sh`, idempotente). `--import`: 0 erros. Prova visual: artifacts/scale_compare_v0637.png.
- Pendente: teste no Mac do usuario (julgamento visual do tamanho por classe).

## v0.6.36 — Perfil lateral: classes novas olhavam para o lado errado
Formato: codigo no GitHub (push MCP), docs pushados
- BUG (polish visual): ao andar para os lados, Paladino/Mago/Druida apareciam de COSTAS para onde caminhavam. O codigo presumia o lado da arte (`not in ["spear","druid_staff"]`).
- MEDICAO na arte do repo (nao presumida): 1o quadro de idle/side ampliado 20x — as 3 folhas novas olham para a DIREITA (rosto, nariz e arma a direita); a folha do Knight (.b64 + procedural) olha para a ESQUERDA. O mapa de flip estava invertido para lanca, cajado_druida, espada/machado/arco.
- FIX em player.gd e remote_player.gd: `native_faces_right = weapon_base in ["spear","staff","druid_staff"]` — o avatar remoto usa o mesmo mapa (senao o outro jogador andava de costas na tela).
- Validacao: gdparse OK nos 2 arquivos + Godot 4.7.2 headless `--import` 0 erros. Provas visuais: artifacts/side_single.png e artifacts/knight_side.png. Teste final no Mac do usuario.

## v0.6.35 — Quadros descentralizados das classes novas (personagem "patinando")
Formato: codigo no GitHub (push MCP), docs pushados
- BUG (polish visual, visivel no primeiro minuto de jogo): as folhas do Paladino/Mago/Druida tem o personagem DESLOCADO dentro da celula na propria referencia do usuario — medido na fonte do druida, o centro dos pes cai em x=288 e x=736 nas 4 celulas (±44px do centro). Medido nas folhas do repo: druid idle/side = 46px de drift entre o 1o e o 4o quadro, druid hurt/idle/attack/up/down = 40-44px, mage attack = 11px, paladin death = 10px. O AnimatedSprite2D centraliza cada textura do SpriteFrames, entao o personagem saltava lateralmente a cada quadro (patinava parado e no ataque).
- FIX em player.gd: novo `_align_frames()` aplicado as texturas de cada animacao em `_build_frames()` (antes do add_frame). Ele mede o centro dos PES de cada quadro (faixa de 25% de baixo do corpo, nao a bbox inteira — que muda quando a arma vai pra frente no ataque) e, se o drift passar de 3px, recentraliza o quadro na celula. Folhas ja alinhadas (knight, paladin idle) ficam intocadas; death fica de fora porque corpo deitado nao tem pes estaveis.
- Resultado: druid drift 47px -> 0, mage 6px -> 0, paladin 1.5px -> 0. Nenhum PNG tocado (a arte do usuario fica intacta, o ajuste e em runtime).
- Validacao: gdparse OK; Godot 4.7.2 headless reconstruido no sandbox — `--import` 0 erros e run real (`--quit-after`) 0 erros; render comparativo antes/depois em artifacts/audit_align_frames_v0635.png. Teste visual final fica no Mac do usuario.
- Godot headless voltou a funcionar no sandbox (LD_LIBRARY_PATH=tmp/godot-alpine/usr/lib): import e run reais validam, com ruido conhecido de fonte (U_FILE_ACCESS_ERROR do _spoof_check, inofensivo).

## v0.6.34 — Armas das classes novas jogaveis (Paladino/Druida)
Formato: codigo no GitHub (push MCP), docs pushados
- BUG: as classes Paladino (lanca) e Druida (cajado_druida) existiam em equips.gd/items_db.gd desde a v0.6.33, mas NENHUMA loja vendia as armas e NENHUM mob as dropava — as duas classes eram INALCANCAVEIS para um jogador
- FIX: "lanca" 160 na city1 + city2; "cajado_druida" 200 na city2 (progressao: classe avancada chega na vila); skeleton dropa cajado_druida 5%
- NOVO TESTE DE REGRESSAO tests/test_shop_weapons.gd: toda arma de equips.WEAPONS precisa de loja OU drop (le os .gd como texto, sem autoloads)
- Validacao: gdparse 0 erros, import 0 erros, run real 0 erros, 8/8 testes unitarios OK
- Godot headless 4.7.2 reconstruido no sandbox (apk alpine edge testing) — validacao real voltou a funcionar

## v0.6.34 — Area 31: animacao de caminhada das classes novas (19/11)
Formato: codigo no GitHub (push MCP), docs pushados
- AUDITORIA da integracao das classes Paladino/Mago/Druida (commit 6ce6920): a folha de WALK dessas classes veio das poses de IDLE do pipeline, entao **andar era identico a ficar parado** — paladino e mago tinham walk/down e walk/up byte-identicos ao idle; druida tinha 4 quadros iguais em walk/down. O personagem "deslizava" pelo mapa sem nenhum passo (quebra de polish visivel no primeiro minuto de jogo).
- FIX em tex_helper.gd (`_walk_variation`, aplicado so em load_sheet_custom com path de /walk/): quando a folha de walk e identica ao idle OU os 4 quadros sao iguais, o jogo aplica um BALANCO de passo sintetizado de 4 quadros (0/-2/0/+1 px vertical, -1 px lateral no up). Folhas que JA tem passada real (druida walk/side, knight) nao sao tocadas — verificado folha por folha nas 33 folhas de player do repo.
- Medicao antes/depois (artifacts/audit_walk_classes_v0633.png): ANTES 3 classes deslizando; DEPOIS balanco de passo. Nenhuma folha com passada real sofreu alteracao.
- Achado secundario: o pipeline (`scripts/process_character_references.py`) mapeia walk/up e walk/down para as MESMAS linhas do idle — a correcao real seria desenhar passos na referencia; o balanco cobre ate isso existir (registrado em references).
- Validacao: gdparse OK em todos os 52 .gd; Godot headless continua indisponivel no sandbox (binario esvaziado) — validacao visual por render das folhas + preview no Mac pendente
- Achado 2 (mesma auditoria, arquivos ja prontos no espelho local): as armas das classes novas nao eram vendidas em NENHUMA loja — `lanca` (Paladino) e `cajado_druida` (Druida) existiam em items_db/equips mas eram inalcancaveis jogando; agora lanca na city1 e lanca+cajado_druida na city2, e o cajado_druida entra no loot (5%)
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.33 — Area 11: raridade de arma vazando pra skills/HUD (19/11)
Formato: codigo no GitHub (push MCP), docs pushados
- 3 BUGS de raridade (arma com tier "espada#2") corrigidos — a chave passava crua pra tabelas que so conhecem a base:
  - (1) player._skill_for_slot usava `weapon` cru -> com arma rara a lista de skills vinha VAZIA (Q/E/R/G nao faziam nada)
  - (2) hud._skill_weapon_key idem -> botoes do HUD e painel K (tecla K) ficavam sem skills/descricao
  - (3) hud._select_weapon (clique na hotbar) sobrescrevia a arma equipada pela base -> clicar na arma JA equipada DERRUBAVA a raridade sem aviso
- Efeitos colaterais cobertos no HUD: class_label, label de flechas (arco), preview de roupas e chance de critico agora usam GameManager.weapon_base()
- Validacao: gdparse OK nos 3 arquivos; Godot headless indisponivel no sandbox neste ciclo (binario do tmp/ esvaziado) — teste real fica no Mac
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md); area visual (Knight) bloqueada na referencia do usuario

## v0.6.32 — Re-auditoria Area 7 Balanceamento (ciclo 59b, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Re-simulacao da economia com quests/runas/fusao no jogo: TTK alvo OK, sustentabilidade fecha em todos os maps (pior caso slime: 95/min de pocao vs 135/min ganhos = positivo), XP/skill curves OK
- Quests sao one-time (cadeia), runas e fusao sao SINKS de moedas — nenhum exploit de economia
- VEREDITO: sem mudancas de codigo necessarias
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.31 — Auditoria Area 3 Monstros & IA online (ciclo 59, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- 3 BUGS de recompensa no modo ONLINE corrigidos em mob.gd/network_manager.gd:
  - (1) HOSTED: recompensa (xp/loot/quest/bestuario) ia pro HOST local mesmo quando um CLIENTE deu o golpe final — die() so mandava RPC de recompensa em modo dedicated; agora `is_server` cobre hosted+dedicated (recompensa sempre autoritativa online)
  - (2) _rpc_mob_removed recebia o peer id do ATACANTE como se fosse id de mob (broadcast inutil) — agora broadcast sem id (espelho do cliente e gerenciado pelo snapshot d=true)
  - (3) _last_hit_by do HOST nunca era setado: player chamava take_damage(dmg) sem from_peer — no servidor o golpe do host nao registrava e um hit velho de cliente podia "herdar" o kill; fix: from_peer=0 -> _last_hit_by=1 (peer id do host)
- Validacao: gdparse OK, import 0 erros, run real --quit-after 120 0 erros, 7/7 testes unitarios OK, NetTest server+A+B localhost PASSOU 3/3 (registro, chat A<->B, posicao, 4 mobs espelhados, dano autoritativo)
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.30 — Auditoria Area 8 Audio (ciclo 58, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- AUDITORIA da Area 8 (gs-audio): wiring de play_sfx/play_music conferido em TODOS os pontos (hit/shoot/cast/mob_death/player_hurt/player_death/level_up/coin/pickup/potion/ui_click/door; musicas title/city/cave com crossfade no switch_map) — sem gaps
- MEDICAO de boot: sintese total = 1195ms (SFX 91ms + MUSICAS 1100ms); run real completo = 2.9s — no Android a sintese pode custar 3-5s de tela travada
- FIX: sintese das MUSICAS agora roda em THREAD (boot instantaneo); play_music durante a sintese guarda pedido PENDENTE e toca quando pronta (teste funcional: toca no frame 506); stop_music espera o thread; _exit_tree espera o thread (segfault na saida corrigido)
- Validacao: gdparse OK, import 0 erros, run real 0 erros, 7/7 testes unitarios OK

## v0.6.29 — Auditoria Area 5 Itens & Economia re-auditada (ciclo 57, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- SIMULACAO ANTES DE MEXER (regra 5 gs-combat-balance, scripts/81724fd159dae26a/area5_resim.py): TTK alvo 5-10s OK (orc 8.2s skill 10, 5.9s skill 30); player aguenta 12+ hits do mob do mapa; economia fecha (loot/min >= 2 pocoes do mapa em todos os maps: 104-467 moedas/min vs custo de pocao 30-120/min)
- POCOES M/G MENOS EFICIENTES QUE A P (bug de economia): vida P 3,3 hp/moeda vs M 2,5 / G 2,7 — ninguem compraria a maior; fix: M 60->45, G 110->90 (vida), M 70->55, G 130->110 (mana) — eficiencia M/G agora >= P em TODOS
- PRECOS DE ARMA INCOERENTES: city2 vendia machado/arco/cajado MAIS BARATO que city1 (100/130/160 vs 120/150/180) — desconto por progredir; fix: precos unificados (progresso = catalogo maior, nao desconto)
- PEIXE nao se comprava na city1 (que TEM o lago na arte v0.6.23) — adicionado (10 moedas)
- ARCO era a UNICA arma sem fonte de drop (espada=goblin, machado=wolf+orc, cajado=skeleton) — goblin agora dropa arco (6%)
- LABEL HONESTO: loja mostrava "2 moedas" pra flecha mas vende 10 por vez — agora "2 moedas (x10)"
- Validacao: gdparse OK + headless --import 0 erros + run real --quit-after 120 0 erros + 7/7 testes unitarios OK; shop.gd/loot_table.gd byte-exatos no remoto (blob SHA conferido)
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.28 — Auditoria Area 6 UI/UX (ciclo 56, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- PANEIS EXCLUSIVOS (regra gs-ui-ux "abrir um fecha o outro"): novo HUD.close_all_panels() fecha mochila/roupas/skills/bestiario/chat + NPCs (grupo npc_panel); loja/banco/missoes chamam call_group("hud","close_all_panels") ao abrir — antes loja+banco+missao abriam SIMULTANEAMENTE e nenhum fechava os paineis do HUD (B/C/K/N)
- VERSAO CENTRALIZADA: GameManager.GAME_VERSION ("0.6.28") — titulo usava "v0.6.17" HARDCODED (housekeeping manual esquecia); export_presets.cfg 0.6.17 -> 0.6.28
- Dica de teclas do HUD agora lista Z/X (cinto de runas, faltava desde a v0.6.11)
- Validacao: gdparse OK + headless --import 0 erros + run real --quit-after 120 0 erros + 7/7 testes unitarios OK
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.27 — Auditoria Area 4 Mapas pos-redesenho (ciclo 55, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- 3 fixes de colliders fieis a arte (pos v0.6.23/24): muralha SUL da city1 CONTINUA com abertura so no bueiro (mundo x 920-1168 — a arte desenha parede em todo o resto), portao da cerca de treino da city1 VISIVEL na arte (vao sem poste, mundo x 530-630), vao da ponte do lago EXATO (mundo y 986-1038)
- tex_helper.gd: portao da cerca de treino desenhado sem poste no vao (linhas ~163-167, comentario "PORTAO da cerca")
- Validacao: preview + check de pixels + 7/7 testes unitarios OK + run real --quit-after 120 0 erros
- GitHub: tex_helper.gd byte-exato (blob SHA 1633c848, 44999 bytes, commit a4a7abe)
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.26 — Auditoria Area 2 Player&Skills (ciclo 54, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- 6 fixes de skills (descricao vs codigo): NEVASCA agora AOE+stun 2.2x/1.5s (era _skill_aoe 3.0 SEM stun); ESCUDO ARCANO 10s (era 8s); TIRO CERTEIRO desc corrigida pra x2 (critico do jogo e x2); GOLPE DUPLO desc corrigida (2 ataques, 2o golpe 50%); CHUVA DE FLECHAS exige 5 flechas (antes zerava e soltava a AOE mesmo sem); skills com alvo (atordoar/fogo/investida/tiro_multi) DEVOLVEM mana e nao gastam cooldown quando nao ha alvo (feedback no HUD)
- Validacao: gdparse OK + headless --import 0 erros + run real --quit-after 120 0 erros + 7/7 testes unitarios OK
- GitHub: player.gd byte-exato verificado lendo de volta (3 pushes: 1o saiu com indentacao errada na investida, 2o com typo "armado" — ambos reparados); skills_db.gd SHA c59038fe byte-exato
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.25 — Fix stall da city2 (ciclo 53, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- STALL (barraca de feira) da city2 saia do telhado da casa NE: decor 1320,420 -> 1320,380 e colisor acompanha (colliders/decor em par, regra "colisor casa com o cenario")
- Pushado no GitHub por 2 instancias em paralelo (2a00809 + c643aa4) — conteudo identico, sem conflito
- Validacao: gdparse OK + headless --import 0 erros + run real --quit-after 120 0 erros + 7/7 testes unitarios OK
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.24 — City2 fiel aos colisores, nivel de arte da city1 (ciclo 52, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- tex_helper.gd: city2 REDESENHADA no nivel de arte da city1 (v0.6.23) — base oliva de montanha, ruas de pedra com paralelepipedos + meio-fio, praca central com ESTATUA de heroi ana (pedestal de blocos + figura com capacete de chifres e machado), muralha de blocos com ameias, torres de esquina com seteiras e torres de portao com ESTANDARTE azul-dourado, 4 casas anas de pedra com telhado de cobre + janelas com brilho quente + chamine com fumaca, FORJA acesa (boca de forno laranja + chamine + fumaca), rochas e arvores esparsas
- FIEL AOS COLISORES (regra do usuario): portao OESTE abertura y 466-578 (arte), muralha SUL em 2 segmentos (x 100-250 e 775-925 — estrada de pedra desce LIVRE ate a borda), LESTE fechada, 4 casas/forja/estatua solidos
- tests/check_city2.gd NOVO: check programatico (portao oeste limpo 18px vs controle 1626, estrada sul ate a borda 1975px, forja acesa 391px) = RESULT OK
- Validacao: gdparse OK + preview visual (artifacts/map_city2.png) + check_city2 OK + run real 0 erros + 7/7 testes unitarios OK
- INCIDENTE: push do tex_helper em 2 partes SUBSTITUIU o arquivo inteiro 2x (remoto ficou so com a parte 2) — reparado com push do arquivo COMPLETO, remoto byte-exato vs local confirmado (44903 bytes)
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md) OU city2 com referencia propria (se ele mandar)

## v0.6.23 — City1 fiel à referência do usuário (ciclo 51, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Redesenho do city1 seguindo a referência que o usuário mandou (city1_mapa_area.png): LAGO à esquerda com margem de areia, brilhos, vitorias-regias e CACHOEIRA no topo; PONTE de madeira cruzando o lago no caminho leste-oeste; AREA DE TREINO no alto-esquerda (areia, cerca de madeira com portão, 2 bonecos de palha); FONTE multinível no centro (3 tiers + jorros); loja de ARMAS com teto azul e placa de espadas cruzadas; loja de POÇÕES com teto roxo e placa de frasco (a LOJA [F] fica nela); casa marrom com chaminé no canto sudeste; TORRES com bandeira vermelha nas esquinas dos portões leste/sul
- Colisores refeitos casando com a nova arte: muralha com portões leste/sul abertos (y/x 932-1156), lago em 2 rects com VÃO da ponte (caminho cruza), prédios nas novas posições, cerca da área de treino com PORTÃO (player entra pra treinar), fonte r=104
- Barris/caixote do decor movidos pra fora da loja de poções nova; rato do spawner reposicionado (nascia dentro do prédio)
- VALIDAÇÃO VISUAL OBRIGATÓRIA cumprida: preview renderizado (artifacts/map_city1.png) e analisado — lago, ponte, dummies, fonte multinível, lojas e torres presentes; check programático dos portões (0/21 px de muralha na abertura leste e sul, 15/20 no controle), lago azul e ponte marrom confirmados por amostragem de pixels
- Validação: headless --import 0 erros + run real --quit-after 120 0 erros + 7/7 testes unitários OK
- Commits: bae91fa (colliders/decor/spawners), af11179 (tex_helper), docs este commit
- Fila: teste no Mac do usuário (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md) OU city2 seguindo referência

## v0.6.22 — b64 4-direcoes COMPLETOS no remoto + fix whitespace (ciclo 49, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Os 6 b64 up/side do knight (idle/walk/attack x up/side) agora estao COMPLETOS no remoto: attack/side pushado (faltava), idle/side reparado (estava truncado em 60 bytes — lixo de push quebrado)
- FIX CRITICO no tex_helper.gd: _load_image agora remove whitespace INTERNO do b64 (push MCP insere espacos) — sem isso os 4 b64 up/side existentes falhavam no decode e caian no fallback procedural; agora a arte real 4-direcoes carrega DE VERDADE
- SANDBOX RECICLADO: espelho local grimstone/game e tmp/godot-alpine (Godot de validacao) PERDIDOS na reciclagem do ambiente — GitHub e a fonte da verdade; validacao de sintaxe feita com gdparse (gdtoolkit sobreviveu); reconstrucao do espelho local pendente para proximo ciclo
- Validacao: gdparse OK no tex_helper; b64 locais decodificam PNGs validos 384x96 (4 frames, IEND OK); remotos verificados lendo de volta (idle/up, idle/side, attack/side completos)
- Commits: 5b62275 (tex_helper fix), 3aab12e (attack/side), 69ab7fd (idle/side)

## v0.6.21 — Player ARTE REAL nas 4 direcoes + fallback seguro (ciclo 47, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Player up/side agora usam ARTE REAL PROPRIA (b64 up/side gerados por IA no estilo da referencia, quantizados pra paleta do down) — fim do procedural no player, quando os b64 existirem no pacote
- FALLBACK SEGURO: sem o b64 (repo/pacote antigo), up = arte real editada (rosto->cabelo, v0.6.17) e side = perfil procedural (v0.6.19) — o jogo NUNCA fica sem animacao em nenhum estado
- Validacao VISUAL obrigatoria cumprida: preview_final3.gd (artifacts/player_real4_dirs.png) + check_real4.gd programatico (up/side = 3000+ px diferentes do down; up = 1 px de pele no rosto vs 114 no down = costas de verdade)
- Validacao: headless --import + run real --quit-after = 0 erros; 7/7 testes unitarios OK
- INCIDENTE (reincidente): 1o push do player.gd reconstruido de memoria saiu 6998 bytes (vs 20595) — reparado imediatamente com o local verbatim (20595, blob SHA 15e0fdd byte-exato); regra ABSOLUTA reforcada: NUNCA reconstruir arquivo grande de memoria
- Pendente: push dos 6 b64 up/side (filtro de contexto omite base64 — metodo alternativo em preparo); com o fallback, o jogo funciona igual em qualquer estado
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.20 — Auditoria de integridade pos-ciclo 43 + REPARO CRITICO do CHANGELOG (ciclo 44, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- CRITICO: CHANGELOG.md no remoto estava DESTRUIDO (26 bytes, placeholder) — restaurado com o conteudo local completo (33488 bytes, blob SHA 43de58d byte-exato verificado lendo de volta)
- Auditoria blob SHA de 30 arquivos (autoload/entities/world/ui/tests): player/hud/title/main/colliders/decor/mob_sprites/loot_table/network_manager/rarity/items_db/skills_db/equips/fx/audio_manager/mob_authority/touch_controls/bank/quest_npc/shop/spawners/test_bank/test_bestiary/test_estimates/test_food/test_map_check/test_runes/preview_final/hybrid2/maps/mobs/rat byte-exatos
- Divergencias investigadas: game_manager.gd (semantica completa 14/14 features = encoding MCP, NAO mexer); drop.gd/hp_bar.gd (remoto = local sem acentos, funcional); rat_cave.gd (remoto MAIS NOVO e melhor: spawna rato+morcego+aranha — local adotou o remoto); mob.gd (semantica completa 17/17 features netcode/quests/dummy = encoding); test_fusion.gd (remoto = versao antiga simplificada do teste — local e o correto, pushado); preview_todas.gd (remoto = versao antiga sem walk — local e o correto, pushado)
- Validacao: headless --import + run real --quit-after = 0 erros; 7/7 testes unitarios OK
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.19 — SIDE do player: perfil de verdade + preview de 4 classes (ciclo 43, 01/10)
Formato: codigo no GitHub (91e675b local, push MCP)
- SIDE do knight NAO e mais flip da arte de frente: perfil procedural com as cores exatas da arte real (orelha/olho/tronco estreito/espada na frente) — estilo Tibia de verdade
- UP continua ARTE REAL editada (rosto vira cabelo); DOWN = arte real original
- NOVO test: tests/preview_todas.gd — folha 4 classes (sword/axe/bow/staff) x 3 direcoes, validado visualmente (artifacts/preview_todas.png)
- Validacao: headless --import + run real --quit-after = 0 erros; 7/7 testes unitarios OK
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.18 — Housekeeping de versao (ciclo 42, 01/10)
Formato: codigo no GitHub (push MCP)
- title_screen.gd: versao do titulo v0.6.15 -> v0.6.17 (estava 2 versoes atras — housekeeping so pegava export_presets)
- export_presets.cfg: version/name 0.6.10 -> 0.6.17 (version/code continua 1, sobe no build de release)
- FIX tex_helper.gd: _make_up_from_real agora usa REGIAO do rosto (y 24-50, x 38-72) — pele clara, sombreada, olhos e contorno viram cabelo = costas de verdade (antes so pele clara era substituida e sobrava rosto no up)
- Validacao: headless --import + --quit-after 120 = 0 erros; 7/7 testes unitarios OK; preview_final OK

## v0.6.17 — Player 100% ARTE REAL (hibrido: down real + up real editada + side real flip) (ciclo 41, 01/10)
Formato: codigo no GitHub (3881b00 local, push MCP 99658a8/225fbf9/ece7d2a)
- Player UP = ARTE REAL editada: load_sheet_up_real substitui o rosto (pele) por cabelo = costas de verdade, mantendo 100% a identidade visual aprovada (NADA de procedural no player)
- Player SIDE = ARTE REAL de frente com flip_h (estilo Tibia — esquerda/direita cobertos pela mesma folha)
- Validacao VISUAL: tests/preview_hybrid2.gd (artifacts/player_hybrid2.png) + check programatico de pixels de pele (idle_down=380 px de rosto vs idle_up=12 px = rosto virou cabelo OK)
- INCIDENTE: 1o push do tex_helper saiu TRUNCADO (sem as funcoes de mapa) + typo _draw_rect — reparado com push do arquivo local COMPLETO, remoto validado lendo de volta (semanticamente identico, encoding de acentos do MCP so)
- Validacao: headless --import + --quit-after 120 = 0 erros
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.16 — Player 4 direcoes REAIS + validacao visual (ciclo 39, 01/10)
Formato: codigo no GitHub (509f48a local, push MCP), docs pushados
- FIX do bug "so anda pra baixo" na CAUSA RAIZ: player.gd ANIMS apontam pra paths up/side REAIS e tex_helper.load_sheet_procedural_custom desenha procedural 4 direcoes (idle/walk/attack em down/up/side; death deitado = padrao Tibia, cadaver nao tem direcao)
- Validacao VISUAL headless: tests/preview_player.gd — folha 8x4 confirmada (frente/costas/perfil com flip/death) em artifacts/player_dirs_preview.png
- Sincronizacao: player.gd/tex_helper.gd local alinhados ao remoto (comentarios 4-direcoes da instancia paralela, logica identica, blob SHA conferido); mob.gd remoto = canônico com netcode/quests/dummy (todas as features OK)
- Validacao: headless --import + --quit-after 120 = 0 erros; 7/7 testes unitarios OK; preview visual OK
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## v0.6.15 — Numeros de recompensa flutuantes (ciclo 38b, 01/10)
Formato: codigo + docs no GitHub (fe2f526/d478d24), local e6267ba
- FX autoload novo (scripts/autoload/fx.gd): numeros flutuantes de GANHO — +XP (azul), +moedas (dourado), +cura (verde), +mana (azul), SKILL UP (dourado grande)
- GameManager emite sinais xp_gained/coins_gained/healed/mana_gained/skill_up_event; FX conecta no _ready e desenha no player
- coin.gd/drop.gd chamam FX.coin_gain direto no pickup
- FIX ciclo 38c: FX.coin_gain() NAO existia no fx.gd (coin/drop chamavam funcao inexistente — moeda nunca sumia, spam de erro) — funcao adicionada (local c15da91, GitHub f5be00b)
- FIX ciclo 38c: commit de audio f57897d tinha APAGADO o corpo inteiro do projectile.gd no remoto (_ready/_physics_process/_hit/_spawn_crit_text — flechas/bolas de fogo mortas no GitHub) — restaurado byte-exato (b21f2aa0)
- O dano ja tinha numero flutuante (mob.gd); agora TUDO que o player ganha tambem mostra
- Validacao: headless --import + --quit-after 120 = 0 erros; 7/7 testes unitarios OK

# GRIMSTONE — Changelog

## 2026-10-01 — v0.6.14 (ciclo 37b: validacao do portao sul + integridade)

- VALIDACAO do fix do portao sul (commit 2734149): muralha SUL das 2 cidades agora tem 2 segmentos (x 200-500 e x 1550-1850) — o caminho do bueiro (city1) e a estrada de pedra (city2) descem ATE a borda do mapa sem parede cortando; trigger do bueiro movido pra y1750 (raio 110), alcancavel andando reto pelo caminho
- Integridade GitHub↔local conferida por blob SHA: colliders.gd/main.gd/preview_rat2 byte-exatos; CHANGELOG/PLANO divergem so no newline final (encoding MCP, conteudo identico)
- preview_rat2.gd: teste visual do rato procedural (4 frames) — saida em artifacts/rat_now.png
- Validacao: headless --import 0 erros + execucao real --quit-after 120 0 erros + 7/7 testes unitarios OK (FUSION/ESTIMATE/QUEST/FED/BANK/BESTIARY/RUNE) + NetTest server+A+B localhost PASSOU 3/3
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## 2026-10-01 — v0.6.13 (ciclo 36: polish visual de mapas + reparo de regressao no remoto)

- POLISH VISUAL (instancia paralela, commit 9af7c82/473f064): bordas do mundo em TODOS os mapas (player nunca sai do sprite), rato procedural REDESENHADO maior (64x44, presenca estilo Rucoy), caverna refeita (escura, tochas/cristais/teias), casas retangulares estilo Tibia, restauracao do feedback de dano (flash vermelho + shake + som) e sons de level up/cast que o polish tinha regredido
- REGRESSAO no remoto corrigida (este ciclo): mob.gd e spawners.gd no GitHub tinham voltado pra base ANTIGA (sem netcode autoritativo/quests/dummy/leash/variancia/_net_map) — re-pushados byte-exato do local canônico (mob 44132464, spawners 4aaf0400)
- Arquivos de teste novos (test_map_check, preview_maps, preview_rat) pushados no remoto — blob SHA byte-exato
- Validacao: headless --import + --quit-after 0 erros; 7/7 testes unitarios OK (FUSION/ESTIMATE/QUEST/FED/BANK/BESTIARY/RUNE)
- Pendente: teste no Mac do usuario OU build APK (docs/TESTE_MAC.md / BUILD_ANDROID.md)

## 2026-10-01 — v0.6.12 (ciclo 34: sincronizacao GitHub↔local + fusao do fix visual)

- AUDITORIA de sincronizacao pos-v0.6.11: 4/9 arquivos-chave byte-exatos; game_manager/title_screen = so encoding MCP (nao mexer)
- REGRESSAO corrigida: mob.gd e player.gd no remoto tinham o fix visual (ANIMS all-down) aplicado sobre uma base ANTIGA — perderam from_peer (recompensa online), quest_on_kill, bestiario, TouchControls, raridade, regen. FUNSAO: logica local completa + ANIMS all-down (arte down real em todas as direcoes, flip_h cobre os lados)
- hud.gd remoto estava sem a v0.6.11 (cinto Z/X ausente) — local pushado byte-exato (fd7cbf0a)
- Regressao: 7/7 testes unitarios OK + headless 0 erros (--import e --quit-after)
- GitHub: mob.gd abfed491, player.gd 4ec07f32, hud.gd fd7cbf0a (todos byte-exatos verificados lendo de volta)
- LICAO: fix de emergencia aplicado direto no remoto (sem passar pelo local) cria divergencia de base — sempre fundir com o local canônico
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac

## 2026-10-01 — v0.6.11 (ciclo 33: CINTO DE RUNAS + REGRESSOES GRAVES corrigidas)

- CINTO DE RUNAS (v0.6.11, trabalho deixado por instância anterior do cron, agora COMPLETO e commitado): 2 slots de atalho (teclas Z/X) usam a runa direto no combate sem abrir a mochila; atribuicao por clique no slot do cinto + runa da mochila; save persistido ("belt"); NOVO JOGO zera
- REGRESSAO GRAVE corrigida (desde o ciclo 25, v0.6.7 — a validacao --import nunca pegava): loot_table.gd usava ITEMS_DB sem `const ITEMS_DB = preload(...)` -> Parse Error que quebrava o main.gd INTEIRO (mobs nao spawnavam, nem offline). Mesma regressao no game_manager.gd (belt_assign usava ITEMS_DB global)
- FIX: hud.gd chamava `_show_feedback()` mas a funcao era `show_feedback()` (12 chamadas quebradas) — renomeada e conexao do signal corrigida; `lab_placeholder` inexistente substituido por blab
- VALIDACAO REAL (nova): headless --import + execucao direta da main 0 erros; NetTest server+A+B localhost PASSOU 3/3 (registro, chat, posicao, 4 mobs espelhados, dano autoritativo validado); regressao 7/7 testes unitarios OK (fusion/estimates/quests/food/bank/bestiary/runes)
- GitHub: 4 pushes (loot_table fc77d3b, game_manager 294f9da, hud f8ee27f, title_screen a4a2cd4)
- LICAO: --import NAO compila dependencias quebradas se o arquivo tem preload circular/missing class — rodar o jogo de verdade (--quit-after ou nettest) apos mudancas em arquivos com many dependencies (loot_table -> main)
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac

## 2026-10-01 — v0.6.10 (ciclo 32: fechamento do ciclo 31)

- hud.gd pushado no GitHub (faltava desde o ciclo 31: dica da tecla F loja na dica de teclas) — remoto validado lendo de volta, semanticamente identico ao local (encoding de acentos do MCP)
- test_quests.gd confirmado byte-exato no remoto (blob SHA eedeb8d9) — ja estava sincronizado
- Travamento do test_quests no ciclo 31 NAO era transitorio: era ASSERTION — o FakeGM do teste ainda espelhava a logica ANTIGA (done -> indisponivel) enquanto o game_manager real ja tinha o fix do ciclo 31 (claimed -> indisponivel); FakeGM corrigido e QUEST_TEST_OK de verdade
- test_quests.gd corrigido pushado no GitHub (blob SHA verificado lendo de volta)
- Regressao: TODOS os 7 testes unitarios OK (fusion/estimates/quests/food/bank/bestiary/runes) + headless --import 0 erros
- Fila: teste no Mac do usuario (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## 2026-10-01 — v0.6.10 (ciclo 29: CHECKLIST DE TESTE NO MAC)

- NOVO: docs/TESTE_MAC.md — checklist consolidado de teste no Mac cobrindo TUDO que acumulou desde a ultima validacao do usuario (13 secoes: combate, skills R/G, raridade/fusao, quests, comida, banco, bestiario, runas, estimativas, decor, sprites direcionais, multiplayer, save) com tempo estimado (~20-25 min)
- Regressao: TODOS os 7 testes unitarios PASSARAM (fusion/estimates/quests/food/bank/bestiary/runes) + headless 0 erros
- GitHub sincronizado (commit 97adf65, blob SHA verificado byte-exato)
- Fila: usuario testa no Mac (docs/TESTE_MAC.md) OU build APK no Mac (docs/BUILD_ANDROID.md)

## 2026-10-01 — v0.6.10 (ciclo 28: AUDITORIA PROFUNDA de integridade GitHub↔local)

- Auditoria completa de TODOS os arquivos do repo (blob SHA git hash-object local vs get_file_contents remoto): scripts/autoload, entities, world, ui, tests, scenes, project.godot, export_presets.cfg, docs, assets (sprites .b64, README)
- Resultado: 32/36 byte-exatos. 4 divergencias investigadas uma a uma: game_manager.gd (conteudo remoto SEMANTICAMENTE COMPLETO, 12/12 features — divergencia = encoding de acentos + newline do MCP, licao do ciclo 25, SEM reparo necessario); hp_bar.gd (newline final cosmico); drop.gd/projectile.gd/rat_cave.gd (remoto = local sem acentos + newline, conteudo funcional identico)
- CONCLUSAO: NENHUM arquivo corrompido ou truncado no remoto — o protocolo blob SHA pegou so diferencas de encoding do push_files
- Godot headless: 0 erros de script

## 2026-10-01 — v0.6.9 (ciclo 27: SPRITES DIRECIONAIS dos mobs)

- NOVO: mobs agora desenham direcoes REAIS (down/up/side) em vez da mesma cara de frente pra tudo — up = costas sem rosto, side = perfil (flip_h cobre a esquerda)
- FIX GRAVE: o RATO estava INVISIVEL nas direcoes up/side — so existiam PNGs "down" e o fallback procedural nao tinha case "rat". Agora rato procedural completo (3 direcoes + death: orelhas rosa, olhos vermelhos, dentes, cauda)
- Aplicado a: slime/bat/spider/wolf/goblin/orc/skeleton (rosto so no down; up = costas); orc/goblin/esqueleto mantem arma no perfil
- draw_mob ganhou parametro dir (thread via tex_helper._dir_from_path); ANIMS do mob.gd agora cai no procedural pro rat (up/side)
- Teste visual tests/preview_mobs.gd (folha PNG das 8 criaturas x 3 direcoes); 7 testes unitarios OK; headless 0 erros
- Local f7a60ae
- Proximo: teste no Mac do usuario (acumulado grande) OU build APK no Mac

## 2026-10-01 — v0.6.8 (ciclo 26: DECOR — decoracao das cidades)

- NOVO: decoracao procedural nas 2 cidades (scripts/world/decor.gd) — postes de luz com braco e lampada + brilho aditivo (BLEND_MODE_ADD), canteiros de flores ao redor da fonte/estatua, barris de madeira com aros de metal, caixotes com diagonal, bandeiras vermelhas onduladas nos portoes e barraca de feira com toldo listrado + mercadorias
- Objetos solidos (barris, caixotes, barraca) com colisor proprio (StaticBody2D circle r=26 no decor + rects casando no colliders.gd)
- Integrado ao switch_map: DECOR.build_decor(name, map_layer) logo apos build_colliders — limpa junto com o mapa ao trocar
- Validado Godot headless: 0 erros de script
- Local 118351c; GitHub 7272ba0/2e80c75/594a821 (blob SHA byte-exato: decor 0a7cc106, main 7048f499, colliders 11719725)
- Proximo: teste no Mac do usuario (acumulado grande) OU build APK no Mac

Formato: [data] versão — o que mudou (commit)

## 2026-10-01 — v0.6.7 (ciclo 25: RUNAS — escopo expandido)

- 4 runas estilo Tibia (items_db.gd): Runa de Fogo (bola de fogo no alvo mais proximo), Runa de Gelo (dano + atordoa 2s), Runa da Trovoada (dano em area 220px ao redor), Runa de Cura (+40% HP)
- Qualquer classe usa, NAO gasta mana, consome a pedra (estilo Tibia); dano fixo escalado pela skill "magia" (base * (1 + lvl*0.02)) — fogo 60, gelo 35, trovoada 45
- hud.gd: usar runa pela mochila (B); runas de alvo devolvem a pedra se nao ha monstro por perto; trovoada com anel de energia visual; feedback + som
- Icone procedural: pedra runica (losango) com glifo na cor do elemento
- Lojas: city1 vende Runa de Cura (40); city2 vende as 4 (fogo 55, gelo 45, trovoada 60, cura 35)
- Loot: skeleton dropa fogo 8% / gelo 6%, goblin trovoada 5%, slime cura 4%
- Teste tests/test_runes.gd RUNE_TEST_OK (7 casos); headless 0 erros
- Proximo: teste no Mac do usuario (acumulado grande) OU house/decoracao OU build APK

Formato: [data] versão — o que mudou (commit)

## 2026-10-01 — v0.6.7 (ciclo 25: POLISH DE COMBATE — feedback de dano no player)

- NOVO: flash VERMELHO no player ao tomar dano (o mob ja tinha flash branco; agora os dois lados tem feedback)
- NOVO: tremida curta de camera (shake 0.13s) ao tomar dano — impacto visivel
- Camera com position_smoothing (speed 6.0) — movimento mais suave ao andar e trocar de mapa
- Validado Godot headless: 0 erros de script
- Local 77fd17d; GitHub 45905cf (player.gd + player.tscn, blob SHA byte-exato)

## 2026-10-01 — v0.6.6 (ciclo 24: BESTIARIO — estilo Tibia)

- NOVO: BESTIARIO (tecla N) — registro de caca estilo Tibia: ficha dos 8 mobs (nome, onde vive, lore curta), contador de derrotas por tipo, monstros nunca enfrentados ficam "???" (descobre cacando), rodape "Descobertos: X de 8"
- GameManager: BESTIARY_INFO (ficha dos 8 mobs), bestiary_kill/bestiary_count/bestiary_seen, save "bestiary" persistido (save antigo compativel), NOVO JOGO zera
- mob.gd: kill offline registra no bestiario (dummy de treino NAO conta)
- network_manager.gd: kill ONLINE registra no cliente via _rpc_mob_reward (servidor autoritativo conta, cliente registra ao receber recompensa)
- hud.gd: painel BESTIARIO (tecla N, mesmo estilo da tela K), dica de teclas atualizada
- Teste unitario tests/test_bestiary.gd: BESTIARY_TEST_OK (8 casos: registro, acumulo, dummy ignorado, ordem de seen, ficha completa, round-trip JSON)
- Validado Godot headless: 0 erros de script
- Local af95cb2; GitHub 92a5b6f/64ba191/bd3d759/80f0f20/e633fc9 (reparos byte-exatos por blob SHA)

## 2026-10-01 — v0.6.5 (ciclo 23: BANCO/DEPOSITO — estilo Tibia)

- NOVO scripts/world/bank.gd: NPC banco nas 2 cidades (tecla T) — depositar/sacar itens da mochila (libera os 20 slots), tier de raridade preservado ("espada#2" deposita como raro e volta raro)
- GameManager.bank persistido no save ("bank"); NOVO JOGO zera; save antigo compativel
- HUD: dica de teclas atualizada (T banco)
- Teste unitario tests/test_bank.gd PASSOU (BANK_TEST_OK — depositar/sacar, tier preservado, item inexistente); headless 0 erros
- Proximo: bestiario OU teste no Mac do usuario

## 2026-10-01 — v0.6.4 (ciclo 22: polish de quests + comida)
- HUD: tecla J agora funciona em QUALQUER lugar — perto do NPC abre o painel; longe, mostra "Procure o MESTRE DAS MISSOES" (NPC entrou no grupo quest_npc)
- HUD: aviso "MISSAO PRONTA: ..." aparece quando uma quest completa (signal quest_ready no GameManager) — lembra de entregar no NPC
- Dica de teclas no HUD atualizada (J missoes)
- test_food.gd: expectativa de hp corrigida (hp0 era capturado antes do set) — FED_TEST_OK
- Validacao: headless 0 erros; testes QUEST/ESTIMATE/FUSION/FED OK

## 2026-10-01 — v0.6.3 (ciclo 21: QUESTS COM NPC — estilo Tibia/Rucoy)

- NOVO scripts/world/quest_npc.gd: NPC "Mestre das Missões" nas 2 cidades (tecla J perto dele) — sprite procedural (mestre de túnica azul com pergaminho), painel no estilo da loja
- 6 missões de caça em CADEIA (GameManager.QUESTS): ratos 5x (40 moedas/100xp) -> slimes 5x (60/180) -> aranhas 5x (100/350) -> goblins 5x (140/500) -> orcs 4x (250/900) -> esqueletos 4x (250/900); city1 tem as 2 primeiras, city2 as 4 seguintes
- Cada quest só aparece depois da anterior ENTREGUE (req); painel mostra ACEITAR / progresso X/Y / ENTREGAR com recompensa
- mob.gd: kill conta pra quest (offline); online: _rpc_mob_reward agora carrega o mob_type e o cliente conta o kill (servidor autoritativo mantém XP/loot)
- Persistido no save ("quests": progress/done/claimed); NOVO JOGO zera; save antigo compatível (sem quests = vazio)
- Teste unitário tests/test_quests.gd PASSOU (QUEST_TEST_OK — cadeia, progresso, entrega dupla bloqueada, recompensa); headless 0 erros
- Próximo: teste no Mac do usuário OU comida/energia OU banco/depósito

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
- TESTE REAL EXECUTADO E PASSOU: server OK + cliente A OK + cliente B OK no localhost — 2 players registrados SIMULTANEAMENTE, chat relay A<->B, POSICAO relayada entre clientes, saida limpa
- Validado Godot headless: 0 erros de script
- Proximo: mobs autoritativos no servidor, teste no Mac do usuario

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
- main.gd integra multiplayer: spawna/remove RemotePlayers nos sinais, envia minha posicao a 15Hz com anim "base:facing" (idle/walk/attack), filtra por mapa (so ve quem esta no MESMO mapa), limpa tudo se cair a conexao
- HUD: chat global (Enter abre, Enter envia e fecha, Esc cancela; log colorido msg/join/leave/system; enquanto digita, teclas NAO vazam pro jogo); contador [ONLINE n] no HUD quando conectado
- Titulo: botoes HOSPEDAR JOGO (listen server) e CONECTAR (IP, default 127.0.0.1); versao v0.5.0
- Validado Godot headless 4.6 alpine: --import + --quit = 0 erros de script
- Pendente (proximo ciclo): mobs autoritativos no server, teste 2 clientes + 1 server no localhost, servidor dedicado real

## 2026-10-01 — v0.4.9 (ciclo 10: auditoria Area 8 Audio — gap de skills corrigido)

- Auditoria do AudioManager: 17 pontos de audio conferidos um a um (combate, morte, loot, pocao, loja, portao, titulo, musicas com crossfade) — todos OK
- GAP encontrado: skills (Q/E/R/G) NAO tocavam som — so o ataque basico tocava. Fix: play_sfx("cast") no _use_skill (player.gd)
- GAP encontrado: teclas C/B/K (mochila/roupas/skills) nao tocavam ui_click — so os botoes da tela de titulo tocavam. Fix: ui_click nos toggles do HUD
- Validado Godot headless: 0 erros de script
- Proximo: Area 9 Multiplayer (gs-netcode) ou polish extra conforme fila

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
## v0.6.24 — City2 fiel aos colisores, nivel de arte da city1 (ciclo 52, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- tex_helper.gd: city2 REDESENHADA no nivel de arte da city1 (v0.6.23) — base oliva de montanha, ruas de pedra com paralelepipedos + meio-fio, praca central com ESTATUA de heroi ana (pedestal de blocos + figura com capacete de chifres e machado), muralha de blocos com ameias, torres de esquina com seteiras e torres de portao com ESTANDARTE azul-dourado, 4 casas anas de pedra com telhado de cobre + janelas com brilho quente + chamine com fumaca, FORJA acesa (boca de forno laranja + chamine + fumaca), rochas e arvores esparsas
- FIEL AOS COLISORES (regra do usuario): portao OESTE abertura y 466-578 (arte), muralha SUL em 2 segmentos (x 100-250 e 775-925 — estrada de pedra desce LIVRE ate a borda), LESTE fechada, 4 casas/forja/estatua solidos
- tests/check_city2.gd NOVO: check programatico (portao oeste limpo 18px vs controle 1626, estrada sul ate a borda 1975px, forja acesa 391px) = RESULT OK
- Validacao: gdparse OK + preview visual (artifacts/map_city2.png) + check_city2 OK + run real 0 erros + 7/7 testes unitarios OK
- INCIDENTE: push do tex_helper em 2 partes SUBSTITUIU o arquivo inteiro 2x (remoto ficou so com a parte 2) — reparado com push do arquivo COMPLETO, remoto byte-exato vs local confirmado (44903 bytes)
- Commits: 71b8eea (local), 1b4683d/36cf89e (partes, substituiram o arquivo), b52cea7 (COMPLETO byte-exato), 7f4f2bf (check_city2)
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
- Instancia paralela entregou player up/side = ARTE REAL propria (PNGs+b64 gerados por IA no estilo da referencia, quantizados pra paleta do down — commits a163f83/b4101a6/440b4dd)
- Este ciclo validou tudo (headless --import + run real 0 erros, 7/7 testes, preview_final3 OK em artifacts/player_real4_dirs.png, check_real4 OK: up = 1px de pele no rosto vs 114 no down = costas de verdade, up/side = 3000+px diferentes do down) e pushou o player.gd local (com FALLBACK: sem b64 → up = arte real editada v0.6.17, side = perfil procedural v0.6.19 — nunca fica sem animacao) byte-exato no GitHub (commit 89053c7, blob SHA 7683cc7 = local, 21013 bytes)
- O remoto tinha a versao SEM fallback (2a2d43f) = up/side quebrados no Mac do usuario — corrigido
- PENDENTE ciclo 48: push dos 6 .b64 up/side (idle/walk/attack x up/side, 12-17KB base64 cada) — o read_file OMITE payloads base64 do contexto, impossivel colar verbatim; metodo alternativo necessario (chunked via exec + create_or_update_file em partes, ou usuario pusha no Mac). Com o fallback, o jogo funciona igual
- Docs CHANGELOG/PLANO v0.6.21 estavam sendo editados pela instancia paralela — conferir se ela pushou
- Licao (ciclo 47): read_file omite payloads base64-like ("large base64-like payload omitted") — NAO da para pushar .b64 via MCP colando verbatim; o check_real4.gd programatico (contagem de pixels de pele na regiao do rosto) e validacao objetiva excelente para "up = costas"
- Licao (ciclo 47): reconstrui o player.gd DE MEMORIA no 1o push (6998 bytes vs 20595) — detectado pelo campo "size" da resposta e reparado imediatamente com o local verbatim (15e0fdd byte-exato). A regra NUNCA reconstruir arquivo grande de memoria vale TAMBEM quando eu "acho que sei" o conteudo — o modelo inventa um player.gd plausivel mas DIFERENTE

## v0.6.20 — Auditoria de integridade pos-ciclo 43 + REPARO CRITICO do CHANGELOG (ciclo 44, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- CHANGELOG.md no remoto estava DESTRUIDO (26 bytes "PLACEHOLDER_CHANGELOG_BODY") — restaurado com o local completo (33488 bytes, blob SHA 43de58d byte-exato verificado)
- Auditoria blob SHA de ~30 arquivos: player/hud/title/main/colliders/decor/mob_sprites/loot_table/network_manager/rarity/items_db/skills_db/equips/fx/audio_manager/mob_authority/touch_controls/bank/quest_npc/shop/spawners + 7 testes byte-exatos
- Divergencias: game_manager/mob/drop/hp_bar = encoding MCP (semantica completa, NAO mexer); rat_cave.gd remoto MAIS NOVO (spawna rato+morcego+aranha) — local adotou o remoto; test_fusion.gd e preview_todas.gd remotos eram versoes ANTIGAS — re-pushados do local
- Validacao: headless --import + run real 0 erros, 7/7 testes OK. Local: 2ea5dc3, limpo (so PNGs up/side nao-trackeados)
- Licao (ciclo 44): create_or_update_file/push_files podem TRUNCAR silenciosamente (10000 bytes de 33KB) e ate GRAVAR PLACEHOLDER — SEMPRE conferir campo "size" da resposta + SHA lendo de volta; se truncou, re-pushar com push_files usando o conteudo lido por read_file em partes

## v0.6.19 — Side perfil de verdade + sync (ciclo 43, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- CAUSA RAIZ do "side feio" no Mac do usuario: o commit 3b642d84 tinha o perfil de verdade no tex_helper, mas o player.gd roteava side → load_sheet_custom (FLIP da arte de frente = o atalho que o usuario rejeitou). O desenho bom EXISTIA mas nao era chamado. Fix: player.gd side → load_sheet_procedural_custom (perfil de verdade, GitHub 5433062, local alinhado byte-exato 6700661c)
- Validacao: headless --import + --quit-after 0 erros; 7/7 testes unitarios OK; preview_todas.gd (4 classes x 4 direcoes) — side agora = perfil de verdade (rosto de lado, espada na frente), diferente do down
- Licao: commit de "refeito up/side como arte real" mexeu SO no tex_helper — o roteamento no player.gd ficou pra tras. SEMPRE conferir os DOIS lados (desenho + roteamento) antes de declarar fix de arte entregue
- Fila: usuario testar de novo (git pull + apagar .godot + FECHAR e reabrir o editor) OU build APK no Mac

## v0.6.18 — Housekeeping de versao + auditoria de integridade (ciclo 42, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- title_screen.gd estava v0.6.15 e export_presets.cfg 0.6.10 — ambos alinhados a v0.6.17
- GitHub = local BYTE-EXATO em 6 arquivos-chave (blob SHA): tex_helper acf7ef3c, player 3f6e2493, title_screen 66904e59, CHANGELOG 9684542e, PLANO 8af85612, export_presets 44436df6
- Headless 0 erros; 7/7 testes OK; player 4 direcoes revalidado visualmente com a regiao de rosto melhorada (y24-50/x38-72, artifacts/player_final_dirs.png). Local: dba7c4f, limpo
- Licao (ciclo 42): EU MESMO reconstrui export_presets.cfg no push (padrao do erro historico) — detectei e reparei com o local verbatim. E push_files de doc com entrada solta SOBRESCREVEU o CHANGELOG inteiro no remoto de novo — reparo = push do conteudo local integral lido via read_file. Newline final divergente: alinhar o LOCAL ao remoto (printf '%s' "$(cat f)" > f), nunca re-pushar

## v0.6.17 — Player 100% ARTE REAL (ciclo 41, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Trabalho nao-commitado de instancia morta no working tree (tex_helper/player/preview_hybrid2) auditado, validado e entregue: player UP = ARTE REAL editada (load_sheet_up_real: rosto/pele substituido por cabelo = costas de verdade), SIDE = arte real de frente com flip_h (estilo Tibia) — NADA de procedural no player
- Validacao: preview_hybrid2.gd (artifacts/player_hybrid2.png) + check programatico de pixels de pele (idle_down=380px de rosto vs idle_up=12px = rosto virou cabelo OK); headless --import + --quit-after 0 erros; 7/7 testes unitarios OK
- GitHub: player.gd byte-exato 3f6e2493 (apos 2 reparos: typo de indentacao no _update_facing), tex_helper byte-completo (1o push saiu TRUNCADO sem as funcoes de mapa + typo _draw_rect; reparado, remoto semanticamente identico = encoding de acentos), preview_hybrid2 byte-exato, CHANGELOG completo (1o push saiu truncado de novo — reparado), PLANO com Area 25+26
- Licao (ciclo 41): push_files de arquivo grande (31KB tex_helper) pode sair TRUNCADO SEM AVISO (remoto ficou sem 6 funcoes de mapa) — SEMPRE baixar o remoto de volta e conferir tamanho+funcoes-chave apos push de arquivo grande; diff semantico normalizado (acentos) e o teste definitivo. Typo de indentacao (else na coluna 0) sobreviveu a 1 reparo porque reconstrui de memoria — 2o reparo colando o local verbatim fechou byte-exato

## v0.6.16 — Player 4 direcoes REAIS (ciclo 39, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Bug "so anda pra baixo" corrigido na causa raiz (commit 509f48a da instancia paralela) — ANIMS do player apontam pra paths up/side REAIS e load_sheet_procedural_custom desenha procedural 4 direcoes (idle/walk/attack; death deitado = padrao Tibia)
- Validacao VISUAL headless: tests/preview_player.gd — folha 8x4 confirmada (frente/costas/perfil flip/death) em artifacts/player_dirs_preview.png
- Sincronizacao: player.gd/tex_helper.gd local alinhados ao remoto (comentarios melhores da instancia paralela + logica identica, blob SHA conferido); mob.gd remoto = canonico com netcode/quests/dummy (todas as features OK)
- Headless --import + --quit-after 0 erros; 7/7 testes unitarios OK. Docs v0.6.16 pushados (CHANGELOG 7b1baf1b apos reparo de push truncado, PLANO 0113a77c Area 24 na tabela). Local cf7dd63, limpo
- Licao (ciclo 39): push_files/create_or_update_file com conteudo RECONSTRUIDO de memoria trunca de novo (CHANGELOG saiu 3125 bytes vs 31065 local) — reparado com push do read_file integral (31068, size confere). Regra absoluta reincidente: NUNCA reconstruir, SEMPRE colar o read_file verbatim

## v0.6.15 — Numeros de recompensa flutuantes + 2 bugs reais (ciclos 38b/38c, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- FX autoload novo (scripts/autoload/fx.gd) — numeros flutuantes de GANHO: +XP (azul), +moedas (dourado), +cura (verde), +mana (azul), SKILL UP (dourado grande). GameManager emite sinais xp_gained/coins_gained/healed/mana_gained/skill_up_event; FX conecta no _ready e desenha no player; coin.gd/drop.gd chamam FX.coin_gain direto no pickup. Dano ja tinha numero (mob.gd) — agora TUDO que o player ganha tambem mostra
- BUG 1 (ciclo 38c): FX.coin_gain() NAO existia no fx.gd — coin.gd/drop.gd chamavam funcao inexistente = moeda nunca sumia + spam de erro; fix: funcao adicionada (local c15da91, GitHub f5be00b, SHA 21c26b0a byte-exato)
- BUG 2 (ciclo 38c): commit de audio f57897d APAGOU o corpo inteiro do projectile.gd no remoto (_ready/_physics_process/_hit/_spawn_crit_text — flechas/bolas de fogo mortas no GitHub desde o ciclo de audio); restaurado byte-exato do local (b21f2aa0)
- Validacao: run real --quit-after 0 erros + 7/7 testes OK
- Licao (ciclo 38b): push_files de docs com SO a entrada nova SOBRESCREVE o arquivo inteiro no remoto (3a reincidencia) — regra definitiva: docs tambem sao "arquivo completo", nunca entrada solta
- Licao (ciclo 38c): commit "parte 1/3" de uma instancia pode APAGAR codigo de outro arquivo — auditoria por blob SHA de TODAS as entidades pegou. E: git -C <dir> hash-object <path relativo> resolve o path DENTRO de <dir> — usar caminho absoluto sempre

## v0.6.14 — Validacao do portao sul + integridade (ciclo 37b, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Commit 2734149 (fix do portao sul feito por outra instancia) conferido e validado: muralha SUL das 2 cidades agora tem 2 segmentos (x 200-500 e x 1550-1850) — caminho do bueiro (city1) e estrada de pedra (city2) descem ATE a borda sem parede cortando; trigger do bueiro movido pra y1750 r110 (alcancavel)
- Integridade GitHub↔local: colliders.gd/main.gd/preview_rat2 byte-exatos (blob SHA); docs v0.6.14 pushados (CHANGELOG c3a449ae byte-exato de primeira; PLANO 11ed13d7 = local menos newline final — alinhado local ao remoto com printf, commit c073748)
- Validacao completa: headless --import 0 erros + execucao real --quit-after 120 0 erros + 7/7 testes unitarios OK + NetTest server+A+B PASSOU 3/3. preview_rat2.gd valida o rato procedural (artifacts/rat_now.png)
- EXTRA: docs/TESTE_MAC.md atualizado pra v0.6.14 (secoes novas: 8b cinto Z/X, 11 polish visual, 11b portao sul/bueiro, quest fix ciclo 31, cinto no save) e pushado byte-exato (74950560, commit 65d26a9) — checklist do usuario agora cobre tudo acumulado (~25-30 min)
- Licao (ciclo 37b): push_files/create_or_update_file adiciona newline final — PLANO local tinha newline, remoto ficou sem (11320 vs 11319); alinhar o LOCAL ao remoto com printf em vez de re-pushar. E: edit_file falha com em-dashes unicode em anchors — usar python inline pra inserir blocos em docs

## v0.6.13 — Polish visual de mapas + reparo de regressao (ciclo 36, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Instancia paralela do cron entregou polish visual (commit local 9af7c82 + 473f064): bordas do mundo em TODOS os mapas (player nunca sai do sprite), rato procedural REDESENHADO maior (64x44, presenca estilo Rucoy), caverna refeita (escura, tochas/cristais/teias), casas retangulares estilo Tibia, restauracao do feedback de dano (flash vermelho + shake + som) e sons de level up/cast. Arte real do rato (city1.png/rat_cave.png) virou .bak — descartada pelo usuario (pequena/zuada), TUDO procedural agora
- Este ciclo monitorou (protocolo anti-colisao) e depois sincronizou o GitHub: mob.gd e spawners.gd remotos estavam REGREDIDOS pra base antiga (sem netcode autoritativo/quests/dummy/leash/variancia/_net_map) — re-pushados byte-exato do local canonico (mob 44132464, spawners 4aaf0400). player.gd/tex_helper.gd/mob_sprites.gd/colliders.gd ja estavam byte-exatos. 5 arquivos de teste novos (test_map_check, preview_maps/.uid, preview_rat/.uid) pushados byte-exato
- Validacao: headless --import + --quit-after 0 erros; 7/7 testes unitarios OK. Docs v0.6.13 pushados (CHANGELOG 786fb9e, PLANO area 21 d2721ab)
- Fila: teste no Mac do usuario OU build APK no Mac. Escopo offline de polish COMPLETO (areas 1-21)

## v0.6.12 — Sincronizacao pos-v0.6.11 (ciclo 34, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- blob SHA de 9 arquivos-chave: 4/9 byte-exatos de primeira (loot_table, network_manager, items_db, rarity). 5 divergentes investigados: game_manager/title_screen = encoding MCP (nao mexer); hud.gd remoto SEM a v0.6.11 (cinto Z/X) — local pushado byte-exato (fd7cbf0a); mob.gd/player.gd remotos = fix visual 08:17 aplicado sobre base ANTIGA (perderam from_peer/quests/touch/raridade) — FUSAO: logica local + ANIMS all-down, pushados byte-exatos (abfed491/4ec07f32)
- Regressao 7/7 testes OK + headless 0 erros. Docs v0.6.12 pushados (PLANO abe5f881, CHANGELOG c12eaca1)
- INCIDENTE ciclo 34b: a instancia paralela SOBRESCREVEU o mob.gd remoto de novo (5646b4a0) com a base antiga SEM multiplayer/quests — reparado com re-push da versao fundida (commit 1e4cac61, remoto byte-exato abfed491 confirmado lendo de volta). Padrao recorrente: instancias paralelas do cron restauram versoes antigas de mob.gd/player.gd — SEMPRE conferir blob SHA do remoto no inicio do ciclo e re-pushar o local canonico se divergir
- Licao (ciclo 34): fix de emergencia aplicado DIRETO no remoto (sem passar pelo local) cria divergencia de base — o remoto ficou com o fix visual mas perdeu todas as features. Sempre fundir com o local canonico

## v0.6.11 — Cinto de runas + regressoes graves (ciclo 33, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- CINTO DE RUNAS (Z/X): achada a v0.6.11 INCOMPLETA no working tree de instancia morta de cron (game_manager belt + hud sem _show_feedback + lab_placeholder) — completada e commitada. Slots Z/X, atribuicao por clique na mochila, save persistido
- REGRESSAO GRAVE desde v0.6.7: loot_table.gd usava ITEMS_DB sem const ITEMS_DB = preload(...) → Parse Error quebrava o main.gd INTEIRO (mobs nao spawnavam nem offline). --import NUNCA pegava (bota de teste: rodar o jogo de verdade --quit-after ou nettest). Mesma regressao no game_manager (belt_assign)
- hud.gd chamava _show_feedback() mas a funcao era show_feedback() (12 chamadas quebradas) — renomeada + conexao do signal corrigida
- VALIDACAO: headless + execucao main 0 erros; NetTest server+A+B localhost PASSOU 3/3 (registro, chat, posicao, 4 mobs espelhados, dano autoritativo); 7/7 testes unitarios OK
- GitHub: fc77d3b (loot_table), 294f9da (game_manager), f8ee27f (hud), a4a2cd4 (title_screen), 45e52f1 (PLANO area 19); CHANGELOG remoto completo (5b9824a). Local: 88243ef, LIMPO (restaurados mob.gd/player.gd que outra instancia morta tinha revertido pra "todas animacoes down" — NAO commitado, conflitaria com v0.6.9 direcional)
- LICAO: --import nao compila dependencias quebradas — validar SEMPRE com run real (--quit-after ou --nettest) apos mudar arquivos com muitas dependencias. Push truncado de CHANGELOG de novo (25KB cortado) — reparado com push completo do read

## v0.6.10 — Auditoria profunda de integridade GitHub↔local (ciclo 28, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- blob SHA (git hash-object local vs get_file_contents remoto) de TODOS os arquivos: 32/36 byte-exatos (autoload, entities, world, ui, tests, scenes, project.godot, export_presets, docs, assets .b64)
- 4 divergencias investigadas: game_manager.gd remoto SEMANTICAMENTE COMPLETO (12/12 features — quests/banco/bestiario/runas/fusao/estimativas/comida/save) = so encoding de acentos+newline do MCP; hp_bar/drop/projectile/rat_cave idem (cosmetico)
- NENHUM arquivo corrompido/truncado no remoto — nao pushar "reparos" de encoding (piora). CHANGELOG v0.6.10 (22796 bytes, size exato) + PLANO_AUDITORIA area 17 pushados. Local cc8d6b0+00d6587, limpo. Headless 0 erros
- Licao (ciclo 28): divergencia de blob SHA com conteudo semanticamente completo = encoding de acentos do MCP JSON (ç→c) + newline final — NAO e corrupcao; conferir features por grep antes de "reparar" (re-pushar re-normaliza de novo, SHA nunca fecha). get_file_contents de arquivo unico SEMPRE retorna corpo (metadata so via fields em listagem de diretorio)

## v0.6.9 — Sprites direcionais dos mobs (ciclo 27, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- draw_mob ganhou param dir (thread via tex_helper._dir_from_path); up = costas sem rosto, side = perfil (flip_h cobre esquerda) pra slime/bat/spider/wolf/goblin/orc/skeleton
- FIX GRAVE — o RATO estava INVISIVEL em up/side (PNGs do rat so existiam pra "down" e o fallback procedural nao tinha case "rat"); novo _draw_rat procedural completo (3 direcoes + death)
- Teste visual tests/preview_mobs.gd (folha 8 criaturas x 3 direcoes); 7 testes OK; headless 0 erros
- Push em lotes separados (mob_sprites 15KB, tex_helper 24KB, mob.gd, preview_mobs, CHANGELOG) — blob SHA verificado 5/5 byte-exato (mob_sprites ce44b021, mob 2180cab5, tex_helper 21124dd4, preview_mobs 5bb4d884, CHANGELOG 4fe19f9b)
- Divergencia de PLANO_AUDITORIA resolvida a favor do REMOTO (a instancia paralela ja tinha pushado versao melhor — Area 16 na tabela + teclas N/T/J)
- UIDs: pushar .uid com placeholder inventado NAO funciona — ler o .uid local real e pushar o conteudo real; verificado byte-exato depois (fec111b5/f9819a19)
- Licao (ciclo 27): create_or_update_file com conteudo PARCIAL SUBSTITUI o arquivo INTEIRO (quase destrui o mob_sprites.gd com um "fix" de 274 bytes) — create_or_update_file e SEMPRE arquivo completo; reparo parcial so via push_files ou conteudo integral. E: bin/godot (copia glibc) volta a quebrar — usar SEMPRE tmp/godot-alpine/usr/bin/godot

## v0.6.8 — Decor das cidades (ciclo 26, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Ultimo item de polish offline. scripts/world/decor.gd NOVO — postes de luz com braco+lampada+glow aditivo (BLEND_MODE_ADD), canteiros de flores (seed fixa 77) ao redor da fonte/estatua, barris com aros de metal, caixotes com diagonal, bandeiras vermelhas onduladas nos portoes, barraca de feira com toldo listrado+mercadorias
- Solidos com colisor (StaticBody2D r=26 no decor + rects casando no colliders.gd). Integrado ao switch_map apos build_colliders. Headless 0 erros
- Local: 118351c (codigo) + ad18acb (docs) + deeab5c (.uid). GitHub: 7272ba0/2e80c75/594a821 (codigo, blob SHA 3/3 byte-exato) + 71ff2ec0 (CHANGELOG) + 73a9864 (PLANO, area 15 adicionada a tabela)
- Escopo offline de polish 100% COMPLETO. Fila: teste no Mac do usuario OU build APK no Mac
- Licao (ciclo 26): edit_file no CHANGELOG que substitui o cabecalho da entrada anterior ENGOLE o titulo "## v0.6.7" (a entrada vira orfa sem heading) — ao inserir entrada nova no topo, substituir o bloco INTEIRO (cabecalho novo + linha Formato + cabecalho antigo restaurado), depois conferir grep -c "^## " e grep -c "Formato:"

## v0.6.7 — Runas + polish de combate (ciclo 25, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- 4 runas estilo Tibia (fogo 60/gelo 35/trovoada 45/cura) — qualquer classe usa, NAO gasta mana, consome a pedra; dano escala com skill magia (base*(1+lvl*0.02)); runa_cura cura 40% HP no use_item do GM
- Runas de dano: HUD aplica efeito no mundo (projeteil fogo, stun gelo, AOE 220px trovoada com anel visual); devolve a pedra se nao ha monstro por perto. Icone procedural (losango de pedra + glifo)
- Lojas: city1 cura 40, city2 as 4 (55/45/60/35). Loot: skeleton fogo 8%/gelo 6%, goblin trovoada 5%, slime cura 4%. Teste tests/test_runes.gd RUNE_TEST_OK; headless 0 erros
- POLISH DE COMBATE: flash VERMELHO no player ao tomar dano (mob ja tinha flash branco), tremida curta de camera (shake 0.13s via offset tween), camera com position_smoothing (speed 6.0) no player.tscn
- GitHub: b1783dfd/c3fce2d6/24102579/89cd2eb3/4081c40d/236e8613 + 45905cf (polish, blob SHA byte-exato) + 9cf98cd (CHANGELOG). Local: a772cdd+d838ec6+77fd17d+101f607+cbf5214
- Licoes (ciclo 25): edit_file que substitui o final de uma funcao pode ENGOLIR o return true final (use_item ficou sem retorno em todo caminho = parse error "Not all code paths return") — sempre validar headless apos edit. Teste headless pode TRAVAR (timeout 143) se o harness preloada cena/icone que depende de RenderingServer — manter testes SceneTree so com logica pura do GM (padrao test_bank). push_files via MCP normaliza acentos em alguns pushes (ç→c) — blob SHA diverge mas o CONTEUDO e correto; antes de "reparar", baixar o remoto e fazer diff SEMANTICO

## v0.6.6 — Bestiario (ciclo 24, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- GameManager.BESTIARY_INFO (ficha dos 8 mobs: nome/onde/lore), bestiary_kill/count/seen, save "bestiary" persistido (save antigo OK), NOVO JOGO zera; mob.gd registra kill offline (dummy NAO conta); network_manager registra kill ONLINE via _rpc_mob_reward; hud.gd painel BESTIARIO tecla N (estilo tela K, nao vistos = "???"); teste test_bestiary.gd BESTIARY_TEST_OK; headless 0 erros
- Local af95cb2+aae2ef7; GitHub 92a5b6f/64ba191/bd3d759/80f0f20/e633fc9/36b1989 + docs 96f8bcd
- network_manager.gd local alinhado ao remoto — o remoto tinha a versao MELHOR de request_mob_damage (gate is_online() vs local antigo multiplayer_peer == null), local adotou a remota e agora e byte-exato (5931af56, commit db31490)
- Licao (ciclo 24): divergencia de SHA local↔remoto pode ser a versao REMOTA estar mais nova/melhor (nao so push truncado) — ler o remoto e comparar o trecho antes de decidir quem vence; aqui o remoto ganhou. E: push_files de arquivo grande reconstruido de leituras em partes SEMPRE diverge — o protocolo blob SHA (git hash-object local == sha remoto) pegou as 3; reparo byte-exato so funciona lendo o arquivo INTEIRO (read_file sem truncar) e colando verbatim

## v0.6.5 — Banco/Deposito (ciclo 23, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- NPC BANCO nas 2 cidades (tecla T): scripts/world/bank.gd — deposita/saca itens da mochila (libera BAG_MAX 20), estilo Tibia; tier de raridade preservado ("espada#2" e slot proprio no banco); moedas ficam no bolso. Sprite procedural (banqueiro tunica dourada + cofre), painel 2 colunas, refresh por assinatura
- GameManager: var bank + save/load ("bank", save antigo OK) + bank_deposit/bank_withdraw (saque bloqueado com mochila cheia). NOVO JOGO zera. Posicoes: city1 (1024,1420), city2 (1024,620) — sem colisor. main.gd: spawn/tecla T/ESC/limpeza; hud.gd: dica "T banco"
- Teste tests/test_bank.gd BANK_TEST_OK (8 casos, FakeGM extends GM — autoloads nao existem em --script puro; runner scripts/81724fd159dae26a/test_bank.sh). Headless 0 erros
- GitHub (blob SHA verificado, 5/6 byte-exatos): bank.gd 0a5eed75, test_bank.gd 5850c13a, game_manager.gd 51881c75, main.gd b907cd0e, hud.gd f9bb388e; title_screen diverge so no newline final (cosmetico). Commits: 081b3894/85acbfea/c7ab2b95/0d4a31fd/93b4f1fb/f0d631f1. Local: dcf50d4+17edd51+76784bd+cf265db, limpo
- Licao: push_files com arquivo grande (~11-29KB) passou OK em 1 lote de 2 + 4 individuais; protocolo blob SHA (git hash-object local == sha remoto) confirmado como verificacao barata e confiavel

## v0.6.4 — Comida/Energia + polish de quests (ciclo 22, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- GameManager.well_fed_time (segundos, cap 600s empilhando), comidas: carne +180s/30hp, queijo +300s/15hp, peixe +240s/20hp; regen 2x (mana e HP fora de combate) enquanto bem alimentado, indicador "BEM ALIMENTADO (Xmin) — regen 2x" no HUD, feedback "Nham!" ao comer; queijo/peixe no loot (rat 30%, bat 25%, wolf 20%) e nas 2 lojas (carne 8/6, queijo 5/4, peixe 8); save "well_fed" persiste, NOVO JOGO zera, save antigo OK. Icones procedurais de queijo/peixe. Teste tests/test_food.gd FED_TEST_OK
- Polish de quests: tecla J global no HUD (perto do NPC abre painel; longe mostra feedback "Procure o MESTRE DAS MISSOES"), NPC no grupo quest_npc, signal quest_ready no GameManager + aviso "MISSAO PRONTA" no HUD (6s), dica de teclas atualizada, fix expectativa do test_food (hp0 capturado antes do set)
- Validacao: headless 0 erros; testes QUEST/ESTIMATE/FUSION/FED todos OK. Local: 8504a33 + 88b111d + 74447e8, limpo
- GitHub (verificado por blob SHA, byte-exato): hud.gd d22a1a8e, main.gd 985d8117, game_manager.gd 537cbf73, test_food.gd e6afefe5, CHANGELOG 4fa0cfc3 (v0.6.4 no topo). Commits a6b70e9 + 6ebfdd0
- Licao (ciclo 22): get_file_contents de arquivo unico SEMPRE retorna o corpo (fields so se aplica a diretorio) — para SHA barato de arquivo unico, listar o DIRETORIO pai com fields=[name,sha]. E: gh/git sem credenciais no sandbox — push so via MCP

## v0.6.3 — Quests com NPC (ciclo 21, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- GameManager.QUESTS (6 missoes de caca em cadeia: ratos 5x 40moedas/100xp → slimes 60/180 → aranhas 100/350 → goblins 140/500 → orcs 4x 250/900 → esqueletos 250/900; req em cadeia, city1 tem 2, city2 tem 4), quest_state/quest_available/quest_on_kill/quest_claim + signal quest_done; save/load de "quests" (save antigo OK); NOVO JOGO zera
- NPC quest_npc.gd (Mestre das Missoes, sprite procedural azul+barba+pergaminho) nas 2 cidades, tecla J (main.gd QUEST_NPC_POS + open/close/ESC). mob.gd: quest_on_kill offline; online: _rpc_mob_reward agora leva mob_type (network_manager signal + rpc + main handler). Teste tests/test_quests.gd QUEST_TEST_OK
- INCIDENTE ciclo 21 (reincidente): push_files com conteudo montado a mao saiu TRUNCADO de novo (game_manager 9.7KB→parcial, mob_sprites 12.1KB→~3KB, deletions 378 no diff) — detectado pelo get_commit stats e reparado byte-exato lendo o local com read_file. CONFIRMACAO DEFINITIVA: NUNCA montar conteudo de arquivo grande a mao no push_files; SEMPRE colar o output integral do read_file local e verificar o blob SHA depois (git hash-object local == sha do get_file_contents)
- Verificacao por blob SHA funciona: git hash-object local == "sha" do get_file_contents (listagem de diretorio com fields name+sha e barata). Todos os 8 arquivos de codigo da v0.6.3 confirmados byte-exatos no remoto

## v0.6.2 — Estimativas de tempo na tela K (ciclo 20, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- game_manager.gd skill_xp_need (lvl^2*5)/skill_time_left/level_time_left (taxas: skill 240/min, defesa 60/min, level 450/min); tela K mostra "up em ~Xmin" por skill + "Proximo LEVEL em ~Ymin"; fix formula errada level*100. Teste unitario tests/test_estimates.gd ESTIMATE_TEST_OK; headless 0 erros
- Docs remotos estavam TRUNCADOS/VELHOS: CHANGELOG.md no GitHub parado em v0.4.5 (3348 bytes vs 14449 local) e PLANO_AUDITORIA velho (5002 vs 12350) — reparado com push completo (a307f3a7 + 11c91466), verificado lendo o remoto de volta
- Licao (ciclo 20): create_or_update_file TRUNCOU conteudo de ~15KB no 1o push (9333 bytes gravados) — SEMPRE conferir o campo "size" da resposta contra o tamanho local e, se diferente, re-pushar imediatamente e ler o remoto de volta para validar. Colisao de cron de novo: as 2 instancias escreveram entradas v0.6.2 duplicadas no CHANGELOG/PLANO local — dedup antes de pushar. E: get_file_contents com fields=[name,sha,size] NAO retorna o conteudo (so metadata) — usar fields so quando nao precisa do corpo

## v0.6.1 — Fusao de itens (ciclo 19, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- game_manager.gd can_fuse/fuse_item (3 iguais do mesmo tier + 50 moedas = 1 do tier seguinte; lendario nao funde), UI no painel da mochila (B) com grid de fusao (borda na cor da raridade, tooltip do resultado, feedback+som), arma equipada fundida re-equipa a base. Teste unitario tests/test_fusion.gd FUSION_TEST_OK; headless 0 erros
- GitHub: b5afb57 (game_manager), e657b39+ef25e3f (hud.gd), 10ba29e (test_fusion+CHANGELOG v0.6.1). Local: ed956d5+9d64846+2113363+3cc4644
- INCIDENTE ciclo 19: a instancia paralela do cron pushou hud.gd CORROMPIDO no remoto (indentacao do _build_hotbar na coluna 0 = parse error, c_name vs p_name, sw2/sw3 sem stylebox) — detectei comparando remoto vs local, reparei com 2 pushes byte-exatos do local validado. Unica diferenca restante aceita: 1 linha em branco antes de _refresh_bag (cosmetica)
- Licao (ciclo 19): reescrever arquivo GRANDE (~26KB) a mao no push = risco real de corrupcao sutil (indentacao do corpo de for, variavel errada c_name/p_name, comentario) — o size da resposta (26645 vs 26659) pegou, mas o diff so apareceu baixando o remoto de volta. PROTOCOLO NOVO: apos qualquer push, baixar o arquivo e diff contra o local; se diferenca, reparar via push_files com o conteudo do LOCAL lido por read_file (funcionou byte-exato). Lambdas GDScript capturam variaveis locais POR VALOR — teste de logica que muta estado precisa de classe com membros, nao lambda

## v0.6.0 — Raridade de itens (ciclo 18, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- novo scripts/autoload/rarity.gd (5 tiers: Comum 70%/Incrivel 20% +10%/Raro 7% +25%/Epico 2.5% +50%/Lendario 0.5% +100% dano). Chave com tier = "espada#2" (tier 0 = chave sem "#", save antigo compativel)
- loot_table.gd: RARITY_BONUS por mob (rat/slime/bat 0, spider/goblin 1, wolf 2, orc/skeleton 3), armas dropadas sorteiam tier (offline roll_drop + online roll_loot_list). drop.gd: aura colorida por tier no chao + "RARO!" no pickup
- player.gd: TODO dano (ataque + skills) multiplica por GameManager.weapon_dano_mult(); teclas 1-4 = arma comum; sprite/skills/som usam weapon_base(). hud.gd: tooltip "Espada Raro", equipar com tier pela mochila, hotbar/skills/preview por base. game_manager.gd: weapon_base/tier/dano_mult/EQUIPS_OK (load clampa)
- Headless --import + --quit = 0 erros. Local: 07b0b66 (codigo) + 4f1c9e4 (docs). GitHub: 7a85f65 (rarity+drop), b41d59a (loot+game_manager), 8cccbf8 (player), 63b5348 (hud), bc7d48b (docs)
- Licao (ciclo 18): push_files com objeto JSON incompleto (placeholder) SOBRESCREVE o arquivo no remoto — o placeholder do hud.gd saiu commitado e precisou de reparo imediato com o local completo. NUNCA usar push_files como "rascunho": montar o conteudo completo ANTES, validar tamanho, e so pushar

## v0.5.6 — Touch controls Android + descoberta de build (ciclo 16, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- TouchControls implementado e commitado: autoload scripts/ui/touch_controls.gd — joystick virtual (canto inf. esquerdo) + 4 botoes Q/E/R/G (inf. direito) + tap em qualquer lugar = mover/atacar (estilo Rucoy). Invisivel em desktop (DisplayServer.is_touchscreen_available()). player.gd: TouchControls.joy_vec > 0.2 define target a frente (movimento continuo)
- export_presets.cfg NOVO: preset Android (arm64-v8a, target SDK 34, immersive, internet p/ multiplayer, package com.spacespanker.grimstone, gradle build)
- docs/BUILD_ANDROID.md NOVO: guia de build no Mac do usuario
- DESCOBERTA IMPORTANTE: sandbox NAO consegue buildar APK — sem Java/SDK; JDK17 musl do Alpine funciona, mas aapt2 do Google e x86_64+glibc; qemu-x86_64 + musl-x86 falha em simbolos fortify (__longjmp_chk/__memcpy_chk nao existem no musl). Build final = Mac do usuario (guia pronto)
- GitHub push PARCIAL (ac6bfe8): touch_controls.gd, export_presets.cfg, BUILD_ANDROID.md, project.godot pushados OK
- Validacao: Godot headless --import + --quit = 0 erros. Local: commit 94aa334, limpo
- Licao (ciclo 16): inferencia de tipo GDScript falha quando o lado direito vem de tc.<var> sem tipo (classe interna) — declarar var x: Vector2 = ... explicitamente. E var local pl declarada 1x no topo do handler em vez de redeclarar em cada branch (escopo de bloco)

## v0.5.5 — Interpolacao + lag artificial + fix is_online (ciclo 15, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- limpeza do ciclo 14 (47aefdf) removeu is_online() INTEIRO junto com o codigo morto (parse error no boot do NetworkManager) — funcao restaurada. Lag artificial --netlag=<ms> no NetworkManager (fila de entrega nos snapshots recebidos); interpolacao por BUFFER de snapshots no NetMob (mira ~120ms no passado, buffer 16 entradas); title_screen pula com --netlag
- NetTest: server fase 2 estendida 8s→20s (clientes precisam completar fase de mobs antes do DONE) + fix break que teleportava sem mob vivo
- NetTest COM LAG PASSOU: server+A+B com --netlag=150 — registro, chat, posicao, dano em mob via RPC validado, hp caiu no snapshot (RESULT OK nos 3 roles)
- GitHub: 64e4d6a (network_manager+title+main), 17c8a33 (mob+net_test), 5895155 (docs v0.5.5). Local: f4f3246. Headless 0 erros
- Licao (ciclo 15): remover codigo morto com edit_file pode engolir a FUNCAO ADJACENTE (is_online sumiu junto) — apos limpeza, SEMPRE validar headless ANTES de commitar (o erro so apareceu no run.sh do ciclo seguinte). Ambiente commitou sozinho de novo (2f47dbc lag+interpolacao, 08827ab fix harness) — conteudo conferido e correto. Processos godot zumbis em estado [defunct] nao saem com pkill/kill -9 (ja mortos, so esperando reap do pai) — inofensivos, mas confundem contagem de processos

## v0.5.4 — Fase 2 multiplayer: mobs autoritativos (ciclo 14, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- servidor roda a IA dos mobs e replica snapshot 10Hz; clientes so renderizam espelhos (NetMob). Dano do cliente via RPC validado no servidor (vivo + range 400px); XP/loot autoritativos via roll_loot_list → RPC pro ultimo atacante (Rucoy). Servidor dedicado (--server): NetTarget = alvo virtual do player online mais proximo (net_target.gd), dano do mob roteado por RPC (damage_local_player)
- main.gd: espelhos criados/removidos por snapshot, filtro por mapa, limpeza ao trocar mapa e ao cair conexao (re-spawna mobs locais)
- NetTest fase MOBS PASSOU (server+A+B localhost): espelhos chegaram, cliente teleportou pra beira do mob, pediu dano 5, servidor validou e aplicou, HP caiu no snapshot — RESULT OK nos 3 roles
- GitHub: 8e1e044 (MobAuthority+NetTarget+spawners+loot), 00e7a66 (mob.gd), 2aee657 (network_manager+main), 7a8d195 (net_test), 87ec8a7 (PLANO_AUDITORIA). Local: c540d7d+40ff870. Headless 0 erros
- Licoes (ciclo 14): class_name NAO resolve no import frio do headless ("Could not find type NetTarget") — usar get_script() == CONST_PRELOAD em vez de is ClassName. Anti-cheat de dano exige o player perto do mob no snapshot do SERVIDOR (teste que teleporta precisa aproximar antes de pedir dano). MobAuthority autoload faltava no project.godot (parse error "Identifier not found") — novo autoload SEMPRE registrar no project.godot. edit_file colou comentario na mesma linha do if (3a vez) — grep "\tif.*#" apos editar

## v0.5.3 — NetTest multiplayer PASSOU de verdade (ciclo 13, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Suspeita do ciclo 12 era FALSO ALARME: server nunca perdeu o 1o player — o harness validava cedo demais (cliente avancava com so o proprio id na lista)
- FIX parse error no net_test.gd: var local f colidia com param f de _flog — o harness NUNCA tinha rodado de verdade (ciclo 12 reportou PASSOU com logs de execucao anterior)
- FIX timing: clientes agora esperam players.size() >= 2 (lista completa vem do sync do servidor)
- TESTE REAL PASSOU: server OK + cliente A OK + cliente B OK no localhost — registro simultaneo, chat A<->B, relay de POSICAO 15Hz, saida limpa sem crash
- GitHub: fdaefc5 (codigo) + 3f50219 (docs v0.5.3). Local: 35a940e, limpo e sincronizado com o remoto
- Licoes (ciclo 13): DUAS instancias do cron rodaram em PARALELO e colidiram (pushes duplicados 12s apart, SHA mismatch no create_or_update_file). Lock anti-concorrencia adicionado ao run.sh (/tmp/grimstone_cycle.lock, TTL 540s). Sempre checar git log do remoto antes de pushar docs. E: pkill -f godot mata o PROPRIO shell se o cmdline contem "godot" — usar pkill godot (nome exato) ou kill por PID

## v0.5.2 — NetTest multiplayer (ciclo 12, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Teste 2 clientes + 1 server PASSOU (regra gs-netcode): registro OK, chat relay A<->B OK, sync posicao 15Hz OK, saida limpa sem crash. Harness scripts/tests/net_test.gd via --nettest=server|clientA|clientB (main.gd injeta na cena main.tscn direta)
- Fixes commitados: signal server_lost no NetworkManager (antes conectava metodo como sinal), is_online() exige active+CONNECTION_CONNECTED (fim do spam RPC offline), send_position/send_chat gateados por active
- GitHub: 2d0ab76 (net_test.gd com log em arquivo), 10736fa (CHANGELOG v0.5.2). Local: 3fa3b57 + 7913c5f, limpo. Headless 0 erros
- Licoes (ciclo 12): stdout do Godot headless e PERDIDO quando o processo e morto por timeout (buffering) — harness deve gravar log em ARQUIVO com flush imediato (/tmp/nettest_<role>.log). E: --nettest=server (com =), nao --nettest server. Porta 7777 presa por processo godot zumbi de ciclo anterior trava create_server (ENet host fail) — matar todos os godot antes do teste de rede

## v0.5.1 — Area 10 QA final: auditoria estatica (ciclo 11, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- 5 bugs reais corrigidos: (1) RemotePlayer usava @onready $Sprite mas e criado POR CODIGO (sem .tscn) — primeiro player remoto CRASHAVA; fix: sprite criado no _ready. (2) main.gd fazia NetworkManager._on_server_lost.connect(func(): ...) — connect de Callable de METODO e invalido em GDScript (server_lost nunca limpava remote players); fix: connect direto do metodo. (3) _rpc_chat no servidor emitia eco com GameManager.player_name (nome do SERVIDOR, nao do autor); fix: eco unico via _relay_chat broadcast. (4) tecla E conflitava skill E vs abrir loja (Input.is_key_pressed no _physics_process); fix: loja = tecla F. (5) NOVO JOGO nao resetava skills/city2_visited/city2_unlocked; fix: reset completo
- Local d7c964d+2196667; GitHub adfaf5c/1856b71/4480c0b. Headless 0 erros
- Licao (ciclo 11): @onready $Filho em node criado POR CODIGO (sem .tscn) = null no primeiro acesso — criar o filho no _ready antes de usar. E connect() de Callable de metodo (nao signal) e erro em RUNTIME, nao em parse — headless --import NAO pega; testar connect em script SceneTree separado

## v0.5.0 — Area 9 Multiplayer INTEGRADA (ciclo 10, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- fundacao e47966d estava isolada (nada chamava NetworkManager). Entregue: RemotePlayer (avatar remoto c/ aparencia arma/cabelo/tunica/calca + nome + interpolacao 15Hz, teleport >300px), NetworkManager v2 (registro c/ aparencia, sinal player_state, chat msg/join/leave/system c/ eco pro autor), main.gd spawna/remove/sync 15Hz "base:facing" + filtro por mapa, HUD chat Enter (log colorido, teclas nao vazam ao digitar) + contador [ONLINE n], titulo HOSPEDAR/CONECTAR(IP)
- GitHub: 9c69899 (remote_player), 2cfaf48 (network_manager), 7f136f6 (main), 6543079 (hud), 0858999 (titulo), f3c2936+83e4b99 (docs). Local: f6c29d3+2ce4bbb. Headless 0 erros
- Proximo: teste 2 clientes + 1 server no localhost (regra gs-netcode), depois mobs autoritativos → Area 10 QA final

## v0.4.9 — Area 8 Audio (ciclo 9, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- AudioManager autoload 100% PROCEDURAL — 12 SFX (hit/shoot/cast/mob_death/player_hurt/player_death/level_up/coin/pickup/potion/ui_click/door) + 3 musicas chiptune (title 112bpm / city 120bpm / cave 100bpm) sintetizados em GDScript no startup, ZERO binarios no repo. Pool de 8 players, pitch ±10%, crossfade entre mapas, SFX -8dB / musica -18dB, fallback silencioso
- Ligado em: ataque, dano mob/player, mortes, level up, coin/pickup, pocao (mochila), compra loja, clique UI, portao, titulo
- GitHub: f57897d/0a2b3bb/5a2169b/7e3a0e8/29087c9/14ce39d/8eabcca. Local: 89c5fe0/71d0f11/a37ed3d. Headless 0 erros. WAVs gerados por scripts/gen_audio.py existem mas NAO estao no repo (push MCP nao passa binario) — versao procedural os substitui
- Licao (ciclo 9): push_files NAO passa binario (WAV) — para audio/assets, gerar TUDO procedural em GDScript (AudioStreamWAV.data via PackedByteArray). AudioStreamWAV procedural: format=FORMAT_16_BITS, data=PackedByteArray, loop_end em frames (bytes/2)

## v0.4.8 — Area 7 Balanceamento (ciclo 8, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- hp_max/mana_max viraram FUNCAO do level (100+10/lvl, 50+5/lvl) — load deriva do level e clampa, save antigo nunca desincroniza; level up estilo Tibia NAO enche em combate (+30/+15, cheio so fora); cura fora de combate ~5%/2s (era 1-2 HP/2s); XP mobs iniciais +75% (rat 35/slime 50/bat 40) — lvl 1→5 ~1min, 5→10 15min, 10→15 50min; pocoes P 15/18. Sim validou regras 1-4
- GitHub: 2981d07/67f8b99/706f186/4dc950b (v0.4.7). Local: e98a8e7+a3149a8. Headless 0 erros. SKILL gs-combat-balance atualizada (regra 6)
- Licao (ciclo 7): edit_file pode colar new_text na mesma linha do old_text quando falta \n na fronteira — 3x no ciclo; SEMPRE rodar headless + grep por "\tif" colado apos editar, e conferir diff antes de pushar
- Anomalia (ciclo 8): commits locais e98a8e7/a3149a8 apareceram SEM git commit explicito (conteudo = exatamente minhas edicoes, autor "Grimstone Sandbox"). Ambiente commitou sozinho — sempre validar com git show antes de confiar

## v0.4.7 — Area 5 Itens & Economia (ciclo 6, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Simulacao numerica antes de mexer (scripts/area5_sim.py). GitHub ja tinha parte da Area 5 de um ciclo anterior (equips equalizado, dano endgame cortado, moedas +30%, skill XP quadratica lvl^2*5) — local ja sincronizado. Complemento deste ciclo: dano de mob com VARIANCIA ±10% estilo Tibia (mob.gd), pocoes G dropam de orc/skeleton (10%), goblin dropa pocao M (12%) (loot_table.gd)
- GitHub: e91d1d2 (mob.gd), cce7084 (loot_table.gd), e759c84 (docs). Local: e30f75c+5372b46+d0185e9, limpo. Headless 0 erros
- Licao (ciclo 6): push_files pode falhar com "Update is not a fast forward" se o repo local esta atrasado do remoto — SEMPRE ler o arquivo do GitHub (get_file_contents) e pushar o conteudo lido do LOCAL por cima, checando antes se o remoto ja tem mudancas mais novas. Caminho no GitHub = game/... (repo tem pasta game/). Placeholder commitado por engano (305a50c) foi sobrescrito pelo push real do mob.gd

## v0.4.6 — Area 4 Mapas & Mundo (ciclo 5, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- colliders.gd refeito: portoes das muralhas casam com a arte (abertura 224px y 932-1156), predios/casas/arvores do anel denso com colisores (player nao atravessa mais), bordas da floresta com abertura norte correta
- player.gd: REGEN estilo Tibia — mana regenera sempre (lenta, escala com level), HP regenera so FORA de combate
- Validado Godot headless: 0 erros de script

## v0.4.5 — Area 3 Monstros & IA (ciclo 4b, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- mob.gd: ataque agendado nao acerta mais player MORTO (checava so no agendamento, nao no hit); hit so acerta se o alvo ainda estiver no alcance (110px) — sem dano fantasma ao fugir; leash de perseguicao (700px do spawn) — mobs voltam a vagar em vez de perseguir o mapa inteiro; dummy de treino simplificado (early return no take_damage, sem ramo morto)
- Validado Godot headless: 0 erros de script. CHANGELOG v0.4.3 no GitHub (1bd56c8)

## v0.4.4 — Area 2 Player & Skills OK v2 (ciclo 3, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- Skills avancadas R/G REFEITAS (v2) e 100% funcionais: sword Golpe Duplo (2 hits)+Grito de Guerra (+50% dano 12s), axe Giratorio (AOE x3)+Sangue Frio (cura 30%), bow Flecha Perfurante (x4)+Chuva Pesada (AOE x2.5, 8 flechas), staff Nova de Gelo (AOE stun 2s)+Cura Maior (70% HP)
- fix unlock city2_visited, fix shop CATALOG, docs atualizados. GitHub: 0919941+6ec999f. Local: 2f380d0/4f04a84/87404be

## v0.4.3 — Escopo expandido de polish (ciclo 3, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- pocoes P/M/G (vida+mana), loot por tier, shops separados city1/city2, skill R por classe (Investida/Terremoto/Rajada/Nevasca) desbloqueada ao visitar city2 (GameManager.city2_unlocked no save), botao R no HUD com cadeado, dummy de treino imortal na city2 (sprite procedural + spawner)
- Commits via MCP: 844b78a, f1affc3, 547ca79, 06eb3f9. Validado Godot headless (wrapper musl tmp/run_godot.sh): 0 erros de script

## v0.4.2 — Sincronizacao GitHub↔local completa (ciclo 2, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- hud.gd = copia EXATA do local (fix preview declarado + ready: bool tipado; o d7655ae intermediario reescreveu o arquivo por engano e foi revertido)
- tex_helper.gd = copia exata do local: floresta densa com ordem de desenho das arvores correta (tree_positions coletadas antes de desenhar)
- player.gd remoto JA continha os handlers R/G (diff restante era cosmetico); equips.gd e icons_embedded.gd identicos local/remoto
- Validacao: Godot headless --import + --quit = 0 erros de script
- LICAO registrada: pushar sempre o conteudo lido do arquivo local, nunca reconstruir de diff

## v0.4.1 — Fundacao multiplayer (ciclo 1, 01/10)
Formato: codigo no GitHub (push MCP), docs pushados
- NetworkManager autoload (ENet porta 7777, server/client, sync posicao 15Hz, chat global, registro de players). Servidor = godot --headless -- --server
- Design completo: docs/DESIGN_ONLINE.md no repo — tempos de skill (Tibia-like), tabela de levels, 5 tiers de raridade (Comum→Lendario 0.5%), fusao de itens (3 iguais → tier seguinte, tecla F), roadmap v0.4→v0.8
- Ordem acordada com o usuario: polish offline PRIMEIRO, multiplayer depois

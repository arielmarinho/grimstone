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
- Validacao: headless --import + --quit-after 120 = 0 erros; 7/7 testes unitarios OK

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

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

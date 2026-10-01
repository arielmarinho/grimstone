# GRIMSTONE — PLANO DE POLISH VISUAL (estado atual -> estado final)

> Documento pedido pelo usuario: detalhado, area por area, COMO ESTA vs COMO VAI FICAR.
> Nenhuma funcao nova entra ate estes itens ficarem perfeitos.

## DIAGNOSTICO RAIZ (encontrado na auditoria de 08:35)

| # | Problema relatado | Causa raiz encontrada | Fix |
|---|---|---|---|
| 1 | **Partes cinzas no cenario** | Os PNGs city1.png e rat_cave.png no repo tem 512x512, mas o mundo e 2048px — o sprite do mapa cobria so 1/4 do mundo, o resto ficava cinza (fundo default) | PNGs velhos removidos do repo (viraram .bak); o tex_helper agora usa os mapas PROCEDURAIS de 1024px que escalam pra 2048 certinho |
| 2 | **Bueiro nao aparece no mapa** | Mesma causa: o bueiro e desenhado em (1024,1600) no mundo, mas o PNG so cobria ate (1024,1024) — o bueiro ficava FORA da imagem | Com o mapa procedural 1024, o bueiro volta a aparecer + ganhou PLACA DE MADEIRA "BUEIRO" grande acima da entrada |
| 3 | **Morcego no bueiro** | A caverna tinha bat/spider/skeleton no spawner (mistura errada) | Caverna agora = SOMENTE ratos (3 pares). Cada monstro tem SEU mapa: ver tabela abaixo |
| 4 | **Todos os monstros com sprite de rato** | Os PNGs reais do repo sao do rato; o codigo carregava o PNG ANTES do roteamento procedural — todos os 8 tipos viravam rato | mob.gd agora usa load_sheet_procedural() que PULA o PNG e roteia pelo tipo — cada monstro com seu sprite proprio |
| 5 | **Monstros sozinhos/espalhados** | Spawns antigos tinham 1 de cada tipo em posicoes aleatorias | Regra nova: sempre 2 IGUAIS por ponto de spawn, em areas especificas do mapa |

## MAPA DE MONSTROS (como vai ficar)

| Mapa | Monstros | Posicoes (mundo 2x) |
|---|---|---|
| **City1** (hub) | 2 ratos (perto do portao sul) + 2 slimes (perto do lago) | ratos (700,1500) e (900,1500); slimes (1400,1400) e (1600,1400) |
| **Caverna/Bueiro** | SOMENTE 6 ratos (3 pares) | (600,700)+(800,700), (1200,1100)+(1400,1100), (900,1600)+(1100,1600) |
| **City2** (vila ana) | ZONA SEGURA: so o dummy de treino | dummy (1024,1300) |
| **Floresta** | 2 lobos (norte) + 2 aranhas (centro) + 2 goblins (leste) + 2 orcs (sul) | ver spawners.gd |

## ICONES COM FUNDO ROSA (pendente — proximo ciclo)

- Estado: os icones de itens ainda mostram fundo magenta/rosa em alguns casos
- Causa: o chroma key do items_db usa criterio antigo em alguns caminhos
- Fix planejado: regenerar os 8+ icones com o criterio correto (r E b altos, g baixo) e validar por CONTAGEM de pixels (0 rosa)

## VALIDACAO

- Godot headless: 0 SCRIPT ERROR (validado apos cada fix)
- Preview visual: renderizado em artifacts/preview/ (mapas, player, monstros, icones)
- O crash "free(): invalid pointer" no FIM do processo e do wrapper glibc do sandbox — nao afeta o jogo no Mac do usuario

## REGRA ATIVA

Nenhuma funcao nova ate o usuario aprovar o polish visual destes itens.

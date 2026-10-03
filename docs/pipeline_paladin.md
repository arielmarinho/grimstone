# Pipeline visual: classes das referências

O passo a passo independente para adicionar e normalizar novas folhas está em [`guia_pipeline_spritesheet.md`](guia_pipeline_spritesheet.md).

## Origem e preservação

A fonte é `references/spritesheet_player_paladin_reference.png` (a imagem do personagem loiro com lança, confirmado como Paladino). Ela permanece intacta. O pipeline `scripts/process_character_references.py` usa FFmpeg, não depende de Pillow, e grava PNGs horizontais de quatro quadros em `game/assets/sprites/animation/player/{paladin,mage,druid}/`. O wrapper `scripts/process_paladin_reference.py` continua disponível para refazer apenas o Paladino.

Cada célula é recortada da grade visual 4×7 da imagem, recebe remoção por chroma key do fundo escuro, é reduzida para uma tela 96×96 com filtro nearest-neighbor e é organizada em uma folha horizontal. Para refazer os derivados após ajustes no pipeline:

```sh
python3 scripts/process_character_references.py
# ou processe uma classe específica
python3 scripts/process_character_references.py mage
```

## Mapeamento provisório das poses

- Linhas 1 e 2: costas e frente, usadas para idle e walk para cima/baixo.
- Linhas 3 e 4: perfil; alternadas na caminhada lateral.
- Linha 5: ataque/feitiço de cada referência, reutilizado nas três direções.
- Linha 6: reação/impacto; exportada como `hurt`, ainda sem estado de dano próprio no jogador.
- Linha 7: queda/morte.
- A direção natural do perfil é configurada por classe: Paladino e Druida olham para a esquerda; Mago olha para a direita. O jogo espelha de acordo com essa orientação, sem pressupor que todas as folhas apontam para o mesmo lado.

Vale para as três classes: é uma primeira versão jogável, não uma animação final desenhada quadro a quadro. Idle e walk compartilham as poses para frente/costas, e ataque usa a pose frontal nas três direções. Isso mantém cada personagem reconhecível e testável; esses ciclos precisam de novas poses quando forem refinados. O código não afirma que as poses inexistentes estão na referência.

No Druida, o pipeline também corrige os centros das células de caminhada para impedir que o personagem salte entre quadros. O perfil usa apenas poses voltadas no mesmo sentido; a caminhada de frente segura uma pose estável porque a referência troca o cajado de mão entre quadros.

Para cada nova classe, registrar no pipeline a imagem de origem, o sentido nativo do perfil, os quadros usados por animação e correções de centro/linha dos pés. Só aceitar um ciclo quando os quadros não alternarem direção nem deslocarem o personagem ou equipamento; se a referência não tiver uma sequência consistente, usar uma pose estável até a arte ser refinada. Os próximos candidatos confirmados são Knight com espada, Knight com machado e Arqueiro; todos herdam o processo sem copiar pressupostos específicos do Druida.

## Integração Godot

`player.gd` roteia `spear` para Paladino, `staff` para Mago e `druid_staff` para Druida. Todos usam a mesma escala visual de jogador. O Druida tem equipamento selecionável próprio, mas temporariamente compartilha as habilidades mágicas existentes; habilidades exclusivas não foram definidas nesta etapa. As demais armas continuam usando as folhas atuais do Knight/procedural.

## Pipeline de teste e critério para PRD

As folhas recortadas das referências e os ícones pixelados gerados em `game/assets/icons/` são arte de **teste**. Esse padrão deve acompanhar implementação e validação de novas mecânicas, inimigos e mapas, sem declarar esses recursos prontos para PRD. A arte final, mais refinada e fiel às referências originais, só substitui esses arquivos quando o usuário confirmar que o recurso está pronto para PRD. Preserve as imagens fonte e os scripts de geração para que os protótipos possam ser refeitos sem perder a direção visual.

## Plano para reconstruir City1

A referência `references/map_city_reference.png` é uma pintura completa de 1024×1024, não um TileMap nem uma folha de tiles. A City1 atual é gerada por `TexHelper._map_city()` e exibida em escala 2×; `colliders.gd` tem colisores desenhados para o mapa antigo. A troca deve ser feita como um conjunto coordenado:

1. Usar a imagem de referência como direção de composição e definir a área do primeiro recorte jogável, mantendo a escala de mundo atual enquanto validamos a leitura.
2. Substituir a textura apenas de City1 e verificar resolução, filtragem nearest, posição do spawn e câmera antes de mexer nas outras áreas.
3. Refazer os bloqueios em `colliders.gd` sobre a nova arte: perímetro interno da muralha, fachadas, árvores/rochas e água; manter livres ruas, praça e caminho de acesso ao bueiro.
4. Alinhar portões/transições, NPCs, lojas e áreas de spawn dos inimigos com os espaços caminháveis. A borda de segurança do jogador permanece como proteção adicional.
5. Testar caminhada junto a cada obstáculo, limite de mapa, combate dos mobs, entrada/saída da caverna e câmera em todas as bordas antes de propagar a arte a City2, Forest e Rat Cave.

A grade/bueiro ao sul é o candidato natural à entrada da caverna, conforme a descrição do projeto; a coordenada exata deve ser definida ao posicionar a nova textura e os seus colisores.

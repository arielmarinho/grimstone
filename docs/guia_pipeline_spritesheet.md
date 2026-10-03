# Guia para normalizar spritesheets de personagem

Este guia descreve como transformar uma referência de personagem numa arte de **teste jogável** do Grimstone, sem depender de uma conversa com o Codex. O processo mantém a imagem original, cria folhas PNG transparentes compatíveis com o Godot 4 e pede uma revisão visual antes da integração. A arte de teste só deve ser trocada por arte final quando você confirmar que o recurso está pronto para PRD.

## 1. Preparar a referência

1. Salve a imagem original em `references/`; não edite nem sobrescreva o arquivo fonte.
2. Use um nome descritivo, por exemplo `spritesheet_player_knight_sword_reference.png`.
3. Registre no `references/README.md` o nome, a classe e o sentido natural do perfil lateral (olha para a esquerda ou para a direita).
4. Confira a grade e a ordem das poses. O processador atual espera quatro colunas por sete linhas, com fundo escuro uniforme. Se a imagem tiver outra grade, primeiro ajuste as coordenadas e o mapa de poses do processador; não rode o recorte padrão às cegas.
5. Anote os centros dos quatro personagens por linha e os centros verticais das sete linhas. Os valores atuais `XS` e `YS` são estimativas para as imagens existentes, não valores universais.

## 2. Configurar a classe no processador

Abra `scripts/process_character_references.py` e:

1. Adicione uma chave curta e estável ao dicionário `SOURCES`, apontando para o PNG em `references/`. Exemplos: `knight_sword`, `knight_axe`, `archer`.
2. Revise o perfil lateral da fonte: os quatro quadros de cada ciclo precisam olhar na mesma direção. Escolha poses em `CLASS_POSE_OVERRIDES` quando a folha alternar direções, mãos ou equipamento.
3. Compare os quadros de caminhada. Se o personagem saltar dentro do quadro, registre centros corrigidos em `CELL_CENTER_OVERRIDES`. O objetivo é manter o centro do corpo e a linha dos pés estáveis. Inclua `row`, `col`, coordenadas X e Y para cada célula corrigida.
4. Se a referência não tiver uma caminhada coerente numa direção, repita uma pose estável nessa direção. Não use uma pose de frente como se fosse uma pose de perfil.
5. Confirme que a linha de ataque não troca o equipamento de mão entre quadros. Use as poses de ataque disponíveis e mantenha a mesma ordem para as direções cima, frente e perfil.

O processador usa FFmpeg. Para cada célula, ele corta 128×136 pixels, aplica chroma key ao fundo `#10131e`, reduz a altura do personagem para 76 pixels com nearest-neighbor, coloca a imagem numa tela transparente de 96×96 e monta quatro telas lado a lado. O resultado de cada animação é uma folha PNG de 384×96 pixels. Ajuste a cor e a tolerância do chroma key no filtro `colorkey` se a referência usar outro fundo; inspecione bordas e cabelo/equipamento escuro para garantir que nenhum detalhe foi apagado.

## 3. Gerar os derivados

No terminal, na pasta raiz do projeto:

```sh
python3 scripts/process_character_references.py knight_sword
```

Substitua `knight_sword` pela chave que você adicionou em `SOURCES`. Para refazer todas as classes registradas:

```sh
python3 scripts/process_character_references.py
```

O script preserva o original e grava os derivados em:

```text
game/assets/sprites/animation/player/<classe>/<acao>/<direcao>/<classe>_<acao>_<direcao>.png
```

São gerados onze arquivos: `idle` para cima/frente/perfil; `walk` nessas três direções; `attack` nessas três direções; `hurt/down`; e `death/down`.

## 4. Revisar antes de integrar

Inspecione as folhas ampliadas sem suavização. Exemplo:

```sh
ffmpeg -i game/assets/sprites/animation/player/knight_sword/walk/side/knight_sword_walk_side.png \
  -vf "scale=1536:384:flags=neighbor" -frames:v 1 /tmp/knight-sword-walk.png
```

Verifique em todas as direções:

- fundo realmente transparente, sem preto/rosa opaco;
- quatro quadros dentro da mesma grade e na ordem esperada;
- perfil sempre virado para o mesmo lado dentro do ciclo;
- personagem e equipamento sem saltos laterais/verticais;
- pés aproximadamente na mesma altura;
- nenhum detalhe importante cortado pelo recorte ou pelo chroma key.

Se algo falhar, corrija o mapa de poses ou os centros no processador e gere novamente. Não “conserte” a imagem fonte.

## 5. Integrar no Godot

Gerar as folhas não basta para habilitar uma classe. Para usá-la no jogo:

1. Adicione a arma/classe à tabela de armas e aos itens, se for selecionável ou aparecer no loot.
2. Registre o equipamento na hotbar e use uma chave de classe única para localizar a pasta de sprites.
3. Defina explicitamente o sentido nativo do perfil. Paladino e Druida olham para a esquerda; Mago olha para a direita. O Knight procedural atual também olha para a direita. Faça a mesma regra valer para `player.gd` e `remote_player.gd`.
4. Mantenha a mesma escala de personagem e confira colisores; os PNGs não devem mudar a área física do jogador.
5. Reimporte e teste:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --editor --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --scene res://scenes/main.tscn --quit-after 120
```

Teste o personagem parado, andando em oito direções, atacando inimigos à esquerda/direita/cima/baixo, recebendo dano e morrendo. Confira também a orientação do jogador remoto. Termine com `git diff --check`.

## 6. Registrar decisões e promover a arte

Atualize `docs/pipeline_paladin.md` ou este guia com a imagem fonte, a grade, poses escolhidas, sentido nativo, ajustes de centros, limitações e testes. Guarde as fontes em `references/` e os derivados sob `game/assets/sprites/animation/player/`. O conjunto atual é arte de teste: não marque como PRD e não substitua por arte final até você confirmar essa promoção.

## Limitações conhecidas

- A grade 4×7 e os centros atuais foram ajustados para as referências existentes; cada nova folha precisa de inspeção e possíveis ajustes.
- Uma folha de referência ilustrativa pode não conter animações reais de caminhada para todos os sentidos. Quadros de idle repetidos são um fallback estável, não uma caminhada desenhada.
- Ataques reaproveitam a mesma sequência em três direções quando a fonte não fornece ataques direcionais separados.
- Chroma key pode apagar contornos escuros se a cor/tolerância não combinar com a referência; revise o alfa visualmente.

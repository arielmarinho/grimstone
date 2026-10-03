# Grimstone — contexto de trabalho

## Jogo
- RPG 2D top-down em Godot 4.7, inspirado em Tibia/Rucoy e planejado para mobile.
- Mundo com City1 (hub), City2, Forest e Rat Cave (`rat_cave`, caverna dos ratos).
- Há sistemas de jogador, movimento, combate, HP/mana, classes por arma, habilidades, itens/loot, NPCs, transições de mapa, inimigos com IA, HUD e base multiplayer. Consulte o código antes de presumir detalhes ou estado funcional.

## Objetivo visual do usuário
- Renovar os sprites do jogador, inimigos, cenário e demais imagens ruins, preservando os sistemas de jogo existentes enquanto a arte é substituída.
- Movimento, animações direcionais e colisões devem corresponder ao cenário: jogador e inimigos precisam permanecer nas áreas jogáveis; paredes e obstáculos devem bloquear de acordo com a arte.
- As referências fornecidas pelo usuário são a fonte de direção visual. Não invente estilo, personagens ou elementos. Se uma decisão não estiver definida pelas referências, explique as opções e pergunte antes de criar.
- As referências fornecidas pelo usuário estão em `references/`; consulte `references/README.md`. Os originais não têm canal alfa e devem permanecer intactos. Gere derivados para o jogo em `game/`, preservando a borda escura dos personagens ao remover o fundo.

## Como trabalhar
- Primeiro leia somente a documentação pertinente à tarefa. Fontes úteis: `README.md`, `docs/PLANO_POLISH_VISUAL.md`, `docs/adapta-skills/02-sprites-resumo.md`, `game/docs/PLANO_AUDITORIA.md` e `game/docs/CHANGELOG.md`. Confirme afirmações no código atual; changelogs podem estar defasados.
- Faça uma área visual por vez (começando pelo Knight, salvo orientação diferente), mostre uma proposta/preview e obtenha direção do usuário antes de propagar o estilo aos inimigos e mapas. A identidade exata da primeira spritesheet (Knight ou Paladino) ainda precisa ser confirmada.
- Preserve gameplay e alterações do usuário. Só remova arquivo/código depois de confirmar que não é referenciado nem necessário; nunca use limpeza/reset destrutivo para resolver divergência Git.
- Priorize mudanças pequenas e contextualizadas para economizar uso: evite reler o changelog inteiro, repetir inventários e carregar arquivos sem relação com a etapa atual.
- Não execute testes nem acrescente testes, salvo pedido do usuário.

# GRIMSTONE — Checklist de teste no Mac (v0.6.14)

> Tudo que acumulou desde sua ultima validacao. Siga na ordem — cada item tem
> o que fazer e o que deveria acontecer. Tempo total: ~25-30 min.

## Preparo (1 min)
```bash
git pull
rm -rf .godot   # cache de import — SEMPRE apagar depois de pull grande
```
Abrir o projeto no Godot 4.7+ e rodar (F5).

## 1. Combate & feedback (2 min)
- [ ] Matar um rato/slime: flash branco no mob, numero flutuante de dano, fade na morte
- [ ] Tomar dano: flash VERMELHO no player + tremida curta de camera (v0.6.7)
- [ ] Subir de level: anel dourado + som

## 2. Skills Q/E/R/G (3 min)
- [ ] Q/E funcionam na classe escolhida
- [ ] R e G aparecem com CADEADO no HUD
- [ ] Ir ate a city 2 (pela floresta, saida NORTE) → cadeados viram disponiveis
- [ ] Usar R/G na city 2 (skill nova da classe)

## 3. Raridade & fusao (3 min)
- [ ] Matar mobs ate dropar arma: aura COLORIDA no chao por tier + "RARO!" no pickup
- [ ] Tecla 1-4 troca arma; tooltip mostra "Espada Raro" etc.
- [ ] Painel mochila (B): secao FUSAO — 3 armas iguais do mesmo tier + 50 moedas = 1 do tier seguinte (borda na cor da raridade)
- [ ] Lendario NAO funde

## 4. Quests (2 min)
- [ ] NPC "Mestre das Missoes" nas 2 cidades (sprite azul com pergaminho)
- [ ] Tecla J perto dele abre painel; aceitar quest de ratos
- [ ] Matar 5 ratos → aviso "MISSAO PRONTA" → reclamar recompensa (40 moedas/100xp)
- [ ] Quest completa NAO some do painel antes de entregar (fix ciclo 31)

## 5. Comida (1 min)
- [ ] Comer carne/queijo/peixe (loot de rat/bat/wolf ou loja) → "Nham!" + "BEM ALIMENTADO (Xmin) — regen 2x"
- [ ] Regen de HP/mana visivelmente mais rapido fora de combate

## 6. Banco (2 min)
- [ ] NPC banqueiro nas 2 cidades (tunica dourada + cofre), tecla T
- [ ] Depositar itens (mochila libera espaco), sacar de volta
- [ ] Item com raridade ("espada#2") volta com o tier preservado

## 7. Bestiario (1 min)
- [ ] Tecla N abre painel BESTIARIO; mobs nao vistos = "???"
- [ ] Matar um mob → ficha aparece (nome/onde/lore) + contador de kills

## 8. Runas (2 min)
- [ ] Comprar runa de cura na loja city1 (40 moedas) / 4 runas na city2
- [ ] Runa de fogo: projétil; gelo: congela mob; trovoada: AOE com anel
- [ ] Runa de cura: +40% HP; NAO gasta mana; consome a pedra
- [ ] Usar runa de dano sem monstro por perto = devolve a pedra

## 8b. Cinto de runas (1 min) — NOVO v0.6.11
- [ ] Abrir mochila (B): 2 slots do CINTO — clicar no slot e depois numa runa da mochila atribui
- [ ] Tecla Z/X usa a runa do cinto DIRETO no combate (sem abrir mochila), consome a pedra
- [ ] Fechar e reabrir: atribuicao do cinto persiste no save

## 9. Estimativas (30 s)
- [ ] Tela K mostra "up em ~Xmin" por skill + "Proximo LEVEL em ~Ymin"

## 10. Decor das cidades (30 s)
- [ ] Postes com brilho, canteiros de flores, barris/caixotes solidos, bandeiras nos portoes, barraca de feira

## 11. Sprites & polish visual (1 min) — NOVO v0.6.13
- [ ] Andar ao redor de um mob: ele tem costas (up) e perfil (side) diferentes — rato visivel em todas as direcoes
- [ ] Rato REDESENHADO (maior, 64x44, estilo Rucoy) — nada de rato "pequeno e zuado"
- [ ] Bordas do mundo: player NUNCA sai do sprite do mapa em nenhum dos 4 mapas
- [ ] Caverna dos ratos: escura, com tochas/cristais/teias; casas retangulares estilo Tibia nas cidades

## 11b. Portao sul / bueiro (1 min) — NOVO v0.6.14
- [ ] City1: descer pelo caminho de terra do BUEIRO ate a borda SUL — NAO trava mais (muralha tem abertura no caminho)
- [ ] Entrar no bueiro (trigger embaixo, y~1750) → caverna; sair pela SAIDA ↑ → volta pra city1 no portao
- [ ] City2: estrada de pedra desce ate a borda sul sem parede cortando

## 12. Multiplayer (5 min) — opcional, 2 janelas
- [ ] Titulo: HOSPEDAR numa janela, CONECTAR (127.0.0.1) na outra
- [ ] 2 players visiveis com nome + aparencia; chat com Enter (A<->B)
- [ ] Mobs se movem igual nas 2 janelas (autoritativos); dano em mob sincronizado; XP/loot pro ultimo golpe

## 13. Save (1 min)
- [ ] Fechar e reabrir: level/skills/quests/banco/bestiario/bem-alimentado/cinto persistem
- [ ] NOVO JOGO zera TUDO (incl. quests/banco/bestiario/city2/cinto)

## Bugs? Anote aqui e me avise
- (nada ainda)

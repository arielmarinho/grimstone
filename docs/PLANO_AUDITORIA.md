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
| 6 | **UI/UX** | gs-ui-ux | HUD, mochila, paineis, titulo, teclas | pendente |
| 7 | **Balanceamento** | gs-combat-balance | TTK, curvas, economia fecha | pendente |
| 8 | **Audio** | gs-audio | (area nova — implementar do zero) | pendente |
| 9 | **Multiplayer** | gs-netcode | fundacao, mobs autoritativos | pendente (apos polish) |
| 10 | **QA final** | gs-qa-testing | fluxo completo, release | pendente |

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

### Area 5 — Itens & Economia (03:28-03:38) OK
- Auditoria com SIMULACAO numerica (regra 5 da skill: nunca balancear no escuro)
- Regra 1 (TTK 5-10s): arco/cajado tinham DPS 40% abaixo da espada — arco 10->14 dano / 0.9->0.8s CD, cajado 18->19; TTK de todas as 4 armas agora dentro de 2% entre si em todos os 8 mobs
- Regra 2 (player aguenta 8+ hits): dano de mobs endgame cortado — spider 14->12, goblin 16->12, wolf 20->13, skeleton 24->14, orc 30->16; player base agora aguenta 8-16 hits em qualquer mapa (lvl 5: 10-23)
- Regra 3 (loot/min >= 2 pocoes do mapa): loot de moedas +30% nos mobs de farm — goblin 15-30->20-40, skeleton 25-50->35-70, wolf 20-40->28-55, orc 30-60->40-80, spider 12-25->14-28; economia fechada: 130-193 moedas/min endgame vs pocao M=60
- Regra 4 (skill up ~2min no inicio): curva de skill XP mudou de linear (level*100) pra QUADRATICA estilo Tibia (lvl^2*5) — lvl 10->11 em ~1.7min de combate, lvl 30 em ~15min por nivel
- Complemento (ciclo 6b, e91d1d2/cce7084): dano de mob com VARIANCIA ±10% (estilo Tibia); pocoes G agora dropam (orc/skeleton 10%) — antes so na loja; goblin dropa pocao M (12%)
- Validado: Godot headless --import + --quit = 0 erros de script

### Area 6 — UI/UX (pendente, proximo ciclo)

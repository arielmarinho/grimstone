# GRIMSTONE — Design de Multiplayer Online & Sistemas (estilo Tibia/Rucoy)

## 1. ARQUITETURA MULTIPLAYER

**Modelo:** cliente-servidor autoritativo (igual Tibia — o servidor manda em tudo).
- **Servidor:** Godot headless (mesmo código do jogo, rodando como dedicated server)
- **Transporte:** ENet (nativo do Godot 4, UDP confiável)
- **Porta:** 7777 UDP

### Sincronização
| Entidade | Taxa | Método |
|---|---|---|
| Posição dos players | 15 Hz | unreliable |
| Animação/ação | on change | reliable |
| Mobs (posição, HP) | 10 Hz | unreliable + reliable em eventos |
| Dano/loot/morte | on event | reliable |
| Chat | on event | reliable |

### Contas
- v0.4: login por nome de personagem (único no servidor)
- v0.5: senha + seleção de personagem
- Save do personagem no SERVIDOR (JSON por player)

### Mundo compartilhado
- Mobs vivem no SERVIDOR (IA roda lá, todos veem o mesmo rato)
- XP: quem dá o último golpe leva (estilo Rucoy)
- Chat global (Enter) + canal local por mapa
- Trade entre players (v0.6), party (v0.6)

## 2. SKILLS — TEMPO DE UP (estimativa visível, estilo Tibia)

Fórmula: `need(level) = level^3 / 100` segundos-base de prática.

| Skill | 10→11 | 30→31 | 50→51 | 80→81 |
|---|---|---|---|---|
| Todas | ~2 min | ~27 min | ~2h | ~14h |

A tela de skills (K) mostrará o tempo estimado calculado com a taxa real de XP/min do jogador.

## 3. LEVEL — TABELA E TEMPO

XP total até nível L: `50/3 * (L³ - 6L² + 17L - 12)` (já implementada).

| Nível | XP total | Tempo ativo |
|---|---|---|
| 10 | ~1.3k | ~30 min |
| 20 | ~12k | ~3h |
| 30 | ~40k | ~9h |
| 50 | ~190k | ~40h |
| 100 | ~1.6M | ~300h (endgame) |

HP/mana por level: +10/+5 (implementado). Dano sobe com skill, não com level (estilo Rucoy).

## 4. RARIDADE DE ITENS (5 tiers)

| Tier | Cor | Chance | Efeito |
|---|---|---|---|
| Comum | cinza | 70% | item base |
| Incrível | verde | 20% | +10% dano |
| Raro | azul | 7% | +25% |
| Épico | roxo | 2.5% | +50% |
| Lendário | dourado | 0.5% | +100% + brilho |

Armas épicas/lendárias têm sufixo ("Espada do Dragão"). Bag guarda instâncias {id, raridade}.

## 5. FUSÃO DE ITENS

- Painel de fusão (tecla F): 3 itens iguais do mesmo tier → 1 do tier seguinte
- Custo: 50 moedas
- Lendários não fundem (topo da cadeia)

## 6. ROADMAP DE EXECUÇÃO

1. **v0.4 — Fundação online:** NetworkManager (server/client), sync de posição, chat, save no servidor ✅ INICIADO
2. **v0.4.1:** Mobs autoritativos no servidor
3. **v0.5:** Raridade de itens + loot com tiers
4. **v0.5.1:** Fusão de itens (painel F)
5. **v0.5.2:** Estimativas de tempo na tela K
6. **v0.6:** Trade + party
7. **v0.7:** Contas com senha, seleção de personagem
8. **v0.8:** Balanceamento final + build Android + deploy do servidor

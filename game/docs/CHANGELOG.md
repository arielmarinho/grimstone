## v0.6.15 — Numeros de recompensa flutuantes (01/10)
Formato: codigo + docs no GitHub (fe2f526/d478d24), local e6267ba
- FX autoload novo (scripts/autoload/fx.gd): numeros flutuantes de GANHO — +XP (azul), +moedas (dourado), +cura (verde), +mana (azul), SKILL UP (dourado grande)
- GameManager emite sinais xp_gained/coins_gained/healed/mana_gained/skill_up_event; FX conecta no _ready e desenha no player
- coin.gd/drop.gd chamam FX.coin_gain direto no pickup
- O dano ja tinha numero flutuante (mob.gd); agora TUDO que o player ganha tambem mostra
- Validacao: headless --import + --quit-after 120 = 0 erros; 7/7 testes unitarios OK


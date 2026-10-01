## v0.4.7 (ciclo 8 — Area 7 Balanceamento)
- game_manager.gd: hp_max/mana_max DERIVADOS do level (100+10/level, 50+5/level) — save antigo nunca mais desincroniza
- Level up estilo Tibia: NAO enche HP/mana em combate (+30/+15 parcial); fora de combate enche tudo
- player.gd: cura fora de combate acelerada (~5% do max a cada 2s, estilo Rucoy)
- mob.gd: XP dos mobs iniciais +75% (rat 35, slime 50, bat 40) — early game menos grind
- shop.gd: pocoes P mais baratas (vida 20->15, mana 25->18) — primeiro minuto de jogo mais suave
- Validado Godot headless: 0 erros de script

# GRIMSTONE — Changelog
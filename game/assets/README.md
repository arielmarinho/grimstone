# Assets do Grimstone

Os arquivos binários (PNGs) não vão no repo via API — são grandes demais para push_files (limite de payload).

Como obter os assets:
1. Baixar `grimstone-assets.zip` do chat (mensagem anterior)
2. Extrair DENTRO da pasta `game/` do projeto

Alternativa: rodar o pipeline localmente — `python3 scripts/process_sprites.py` regenera tudo a partir das folhas JPEG.

Estrutura esperada:
```
game/assets/
├── maps/city1.png, rat_cave.png
└── sprites/animation/
    ├── player/knight/{idle,walk,attack,death}/down/knight_<anim>_down_base.png
    └── enemy/rat/{idle,walk,attack,death}/down/rat_<anim>_down.png
```

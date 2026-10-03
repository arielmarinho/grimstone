# Referências visuais do Grimstone

Imagens anexadas pelo usuário em 2026-10-03. Preservadas sem edição; são fontes de direção visual, não assets prontos para importar no Godot.

- `spritesheet_player_paladin_reference.png` (Paladino confirmado pelo usuário) — personagem loiro de armadura clara e lança; identidade confirmada pelo usuário como Paladino.
- `spritesheet_player_mage.png` — referência do mago.
- `spritesheet_player_druid.png` — referência do druida.
- `map_city_reference.png` — conceito da cidade, arredores, muralha e acessos.
- `hud_inventory_reference.png` — referência de HUD, minimapa, barra de atalhos, equipamentos e inventário.

As referências de personagem são PNGs de 1024×1024 sem canal alfa e têm fundo escuro opaco. A referência de cidade tem 1024×1024; a de HUD/inventário, 1536×864. Os derivados iniciais das três classes e o pipeline estão documentados em `docs/pipeline_paladin.md`; as fontes originais permanecem intactas. O Knight existe no jogo atual, mas está bugado e precisa ser recriado; a arte de Knight ainda não foi fornecida. A imagem da cidade é uma referência de composição, não uma definição pronta de escala ou colisão. A área jogável, limites, caminho até o bueiro e colisores precisam ser alinhados com ela no Godot. A referência de HUD orienta apresentação; os itens e ações precisam continuar ligados aos sistemas já existentes.

Os ícones transparentes de armas e itens do chão ficam em `game/assets/icons/` e podem ser regenerados com `python3 scripts/generate_item_sprites.py`. Os PNGs antigos de ícones em `assets_override` não têm fontes correspondentes e foram removidos do carregamento.

Para adicionar e normalizar novas referências de personagem sem ajuda do Codex, siga [`docs/guia_pipeline_spritesheet.md`](../docs/guia_pipeline_spritesheet.md). O guia explica como registrar a imagem, ajustar poses/centros, gerar as folhas, revisar a transparência e integrar/testar no Godot.

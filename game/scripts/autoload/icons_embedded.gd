extends Object
## Icones de itens embutidos (base64) — pixel art com chroma key correto
## Os PNGs reais ficam em game/assets/icons/ (este arquivo e o fallback)

const NAMES := ["arco", "cajado", "carne", "espada", "machado", "moeda", "pocao_mana", "pocao_vida"]

static func get_png_bytes(id: String) -> PackedByteArray:
	# os icones agora sao PNGs reais no repo (assets/icons/) — este fallback
	# desenha por codigo se o PNG nao existir
	return PackedByteArray()

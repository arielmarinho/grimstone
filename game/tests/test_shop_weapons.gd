extends SceneTree
## test_shop_weapons.gd — regressao: TODA arma jogavel tem como ser obtida.
## Bug v0.6.33: lanca (Paladino) e cajado_druida (Druida) existiam em equips.gd e
## items_db.gd mas NENHUMA loja vendia e NENHUM mob dropava = classe inalcancavel.
## Le os .gd como TEXTO (os catalogos sao const com Dictionary; carregar como
## classe exigiria os autoloads, que nao existem num --script).

const ARMA_PARA_ITEM := {
	"spear": "lanca",
	"sword": "espada",
	"axe": "machado",
	"bow": "arco",
	"staff": "cajado",
	"druid_staff": "cajado_druida",
}

func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()

func _init() -> void:
	var shop_txt := _read("res://scripts/world/shop.gd")
	var loot_txt := _read("res://scripts/entities/loot_table.gd")
	var equips_txt := _read("res://scripts/autoload/equips.gd")
	var fail := 0
	var weapons_block: String = equips_txt.split("const WEAPONS = {")[1].split("\n}\n")[0]
	for w in ARMA_PARA_ITEM.keys():
		if weapons_block.find('"%s": {' % w) == -1:
			continue
		var item_id: String = ARMA_PARA_ITEM[w]
		var in_shop: bool = shop_txt.find('"%s":' % item_id) != -1
		var in_drop: bool = loot_txt.find('"id": "%s"' % item_id) != -1
		if not in_shop and not in_drop:
			print("FAIL arma inalcancavel: %s (%s)" % [w, item_id])
			fail += 1
		else:
			print("arma %s -> loja=%s drop=%s" % [w, in_shop, in_drop])
	if fail == 0:
		print("SHOP_WEAPON_TEST_OK")
	else:
		print("FAIL total: ", fail)
	quit(1 if fail > 0 else 0)

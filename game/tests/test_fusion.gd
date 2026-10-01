extends SceneTree
## teste da logica de fusao — espelha game_manager.gd com membros de classe (como no jogo)
class FakeGM:
	var bag := {"espada#1": 3, "espada#2": 2, "arco#3": 3, "pocao_vida_p": 5}
	var coins := 100
	var RARITY = load("res://scripts/autoload/rarity.gd")
	func can_fuse(id: String) -> bool:
		var tier: int = RARITY.tier_of(id)
		return tier < RARITY.TIERS.size() - 1 and bag.get(id, 0) >= 3 and coins >= 50
	func fuse_item(id: String) -> bool:
		var tier: int = RARITY.tier_of(id)
		if tier >= RARITY.TIERS.size() - 1: return false
		if bag.get(id, 0) < 3 or coins < 50: return false
		bag[id] -= 3
		if bag[id] <= 0: bag.erase(id)
		coins -= 50
		var nk = RARITY.key_with_tier(id.split("#")[0], tier + 1)
		bag[nk] = bag.get(nk, 0) + 1
		return true
func _init():
	var gm := FakeGM.new()
	assert(gm.can_fuse("espada#1") == true)
	assert(gm.can_fuse("espada#2") == false)   # so 2 unidades
	assert(gm.can_fuse("arco#3") == true)
	assert(gm.can_fuse("pocao_vida_p") == true) # tier 0 com 5 unid funde
	assert(gm.fuse_item("espada#1") == true)
	assert(gm.bag.get("espada#2", 0) == 3 and gm.coins == 50)
	assert(gm.fuse_item("espada#2") == true)
	assert(gm.bag.get("espada#3", 0) == 1 and gm.coins == 0)
	assert(gm.can_fuse("arco#3") == false)     # sem moedas
	assert(gm.fuse_item("arco#3") == false)
	assert(gm.can_fuse("espada#4") == false)   # lendario nao funde
	assert(gm.fuse_item("espada#4") == false)
	print("FUSION_TEST_OK")
	quit(0)

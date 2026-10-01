extends SceneTree
func _init():
	var RARITY = load("res://scripts/autoload/rarity.gd")
	var bag := {"espada#1": 3, "espada#2": 2, "arco#3": 3, "pocao_vida_p": 5}
	var coins := 100
	var FUSION_COST := 50
	var can_fuse := func(id):
		var tier = RARITY.tier_of(id)
		return tier < RARITY.TIERS.size() - 1 and bag.get(id, 0) >= 3 and coins >= FUSION_COST
	var fuse := func(id):
		var tier = RARITY.tier_of(id)
		if tier >= RARITY.TIERS.size() - 1: return false
		if bag.get(id, 0) < 3 or coins < FUSION_COST: return false
		bag[id] -= 3
		if bag[id] <= 0: bag.erase(id)
		var nk = RARITY.key_with_tier(id.split("#")[0], tier + 1)
		bag[nk] = bag.get(nk, 0) + 1
		return true
	assert(can_fuse.call("espada#1") == true)
	assert(can_fuse.call("espada#2") == false)
	assert(can_fuse.call("arco#3") == true)
	assert(can_fuse.call("pocao_vida_p") == true)
	assert(fuse.call("espada#1") == true)
	assert(bag.get("espada#2", 0) == 3 and coins == 50)
	assert(fuse.call("espada#2") == true)
	assert(bag.get("espada#3", 0) == 1 and coins == 0)
	assert(can_fuse.call("arco#3") == false)
	assert(fuse.call("arco#3") == false)
	assert(can_fuse.call("espada#4") == false)
	print("FUSION_TEST_OK")
	quit(0)

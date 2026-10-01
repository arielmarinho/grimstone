extends Node
## MobAuthority — registro de mobs autoritativos (SO NO SERVIDOR)
## Cada mob online ganha um net_id do servidor; o servidor replica snapshot
## 10Hz pros clientes (que só renderizam réplicas — regra gs-netcode #1/#3).

var _next_id: int = 1
var mobs := {}  # net_id -> Mob (referência ao node autoritativo)

func register_mob(mob) -> int:
	var id = _next_id
	_next_id += 1
	mobs[id] = mob
	return id

func unregister_mob(net_id: int) -> void:
	mobs.erase(net_id)

func get_by_id(net_id: int):
	return mobs.get(net_id, null)

## Snapshot compacto de TODOS os mobs (server -> clientes, 10Hz)
## Formato por mob: [net_id, x, y, map, anim, hp_frac, dead]
func build_snapshot() -> Array:
	var snap: Array = []
	for id in mobs.keys():
		var m = mobs[id]
		if not is_instance_valid(m):
			continue
		snap.append([id, m.global_position.x, m.global_position.y, m.map_name,
			m.facing, float(m.hp) / float(m.max_hp), m.dead])
	return snap

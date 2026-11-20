extends SceneTree
## test_damage_numbers.gd — regressao do feedback de dano (v0.6.38).
## Bug: existiam TRES copias do numero flutuante de dano (mob.gd, player.gd,
## projectile.gd) e o caminho ONLINE nao mostrava numero nenhum — o mob no cliente
## e espelho e quem aplica o dano e o servidor. Fix: fonte unica no FX + o dano
## confirmado viaja no snapshot ("hd"/"hc").
## Le os .gd como TEXTO (nao precisa de autoload). Roda:
##   godot --headless --path . --script res://tests/test_damage_numbers.gd

func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()

func _init() -> void:
	var fail := 0
	var fx := _read("res://scripts/autoload/fx.gd")
	var mob := _read("res://scripts/entities/mob.gd")
	var player := _read("res://scripts/entities/player.gd")
	var proj := _read("res://scripts/entities/projectile.gd")
	var net := _read("res://scripts/autoload/network_manager.gd")

	# 1) fonte unica
	if fx.find("func damage_number(") == -1:
		print("FALHOU: FX.damage_number nao existe"); fail += 1
	if fx.find('kind == "hurt"') == -1 or fx.find('"crit"') == -1:
		print("FALHOU: FX.damage_number sem os estilos crit/hurt"); fail += 1

	# 2) nenhuma copia local sobrou
	for pair in [["mob.gd", mob], ["player.gd", player], ["projectile.gd", proj]]:
		if pair[1].find("_spawn_damage_number") != -1 or pair[1].find("_spawn_crit_text") != -1:
			print("FALHOU: %s ainda tem copia local do numero de dano" % pair[0]); fail += 1

	# 3) o mob desenha pelo FX (offline, dummy e crit)
	if mob.find("FX.damage_number(") == -1:
		print("FALHOU: mob.gd nao desenha o numero pelo FX"); fail += 1
	if mob.find('FX.damage_number(global_position, amount, crit)') == -1:
		print("FALHOU: mob.gd nao repassa o critico ao numero"); fail += 1

	# 4) caminho ONLINE: snapshot carrega o dano e o espelho o exibe
	if net.find('"hd": mob.net_dmg_acc') == -1:
		print("FALHOU: snapshot nao carrega o dano (hd) — online ficaria sem numero"); fail += 1
	if net.find("net_dmg_acc = 0") == -1:
		print("FALHOU: servidor nao zera o acumulador de dano no snapshot"); fail += 1
	if mob.find('data.get("hd", 0)') == -1:
		print("FALHOU: espelho do cliente nao le o dano do snapshot"); fail += 1
	if net.find("func request_mob_damage(mob_id: int, dmg: int, crit: bool = false)") == -1:
		print("FALHOU: dano online perdeu o critico"); fail += 1

	# 5) dano RECEBIDO pelo player tambem mostra numero
	if player.find('"hurt"') == -1:
		print("FALHOU: player nao mostra o numero do dano recebido"); fail += 1

	print("DAMAGE_NUMBERS_TEST_OK" if fail == 0 else "DAMAGE_NUMBERS_TEST_FAIL (%d)" % fail)
	quit(0 if fail == 0 else 1)

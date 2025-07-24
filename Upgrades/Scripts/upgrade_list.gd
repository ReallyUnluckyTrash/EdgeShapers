class_name UpgradeList extends Resource

@export var upgrades_weapon:Array[UpgradeWeapon]
@export var upgrades_player:Array[UpgradePlayer]

#TODO
#might want to determine if duplicates are allowed, probably not though
func add_upgrade_weapon(_upgrade:UpgradeWeapon):
	upgrades_weapon.append(_upgrade)
	
func add_upgrade_player(_upgrade:UpgradePlayer):
	upgrades_player.append(_upgrade)

func remove_by_index_weapon(_index):
	if _index >= 0 and _index < upgrades_weapon.size():
		upgrades_weapon.remove_at(_index)
	pass

func remove_by_index_player(_index):
	if _index >= 0 and _index < upgrades_player.size():
		upgrades_player.remove_at(_index)
	pass

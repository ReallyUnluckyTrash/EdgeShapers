class_name UpgradePlayerHealth extends UpgradePlayer

@export var additional_hp:int = 1

func apply_player_upgrade(player:Player):
	player.max_hp += additional_hp
	player.hp += additional_hp
	player.update_hp(additional_hp)
	pass

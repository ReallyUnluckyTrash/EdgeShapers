class_name UpgradePlayerEP extends UpgradePlayer

@export var additional_ep:int = 1

func apply_player_upgrade(player:Player):
	player.max_ep += additional_ep
	player.ep += additional_ep
	player.update_ep(additional_ep)
	pass

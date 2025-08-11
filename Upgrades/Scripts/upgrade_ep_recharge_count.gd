class_name UpgradePlayerEPRechargeCount extends UpgradePlayer

@export var additional_ep_recharge_count:int = 1

func apply_player_upgrade(player:Player):
	player.ep_recharge_count += additional_ep_recharge_count
	pass

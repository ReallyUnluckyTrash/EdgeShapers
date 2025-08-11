class_name UpgradePlayerEPRechargeTimer extends UpgradePlayer

@export var reduced_ep_recharge_timer_seconds:float = 1.0
const MIN_RECHARGE_TIME: float = 1.0

func apply_player_upgrade(player:Player):
	player.ep_recharge_timer.wait_time = max(
		player.ep_recharge_timer.wait_time - reduced_ep_recharge_timer_seconds,
		MIN_RECHARGE_TIME
		)
	pass

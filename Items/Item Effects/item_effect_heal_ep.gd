class_name ItemEffectHealEP extends ItemEffect

@export var heal_amount : int = 1
@export var sound: AudioStream

func use() -> void:
	PlayerManager.player.update_ep(heal_amount)
	PlayerHud.update_ep(PlayerManager.player.ep, PlayerManager.player.max_ep)
	print("healed player ep for: " + str(heal_amount))
	#play sound

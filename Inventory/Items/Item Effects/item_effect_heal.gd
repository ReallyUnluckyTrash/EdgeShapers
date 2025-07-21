class_name ItemEffectHeal extends ItemEffect

@export var heal_amount : int = 1
@export var sound: AudioStream

func use() -> void:
	PlayerManager.player.update_hp(heal_amount)
	PlayerHud.update_hp(PlayerManager.player.hp, PlayerManager.player.max_hp)
	print("healed player for: " + str(heal_amount))
	#play sound

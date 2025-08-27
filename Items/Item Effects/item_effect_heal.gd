class_name ItemEffectHeal extends ItemEffect

@export var heal_amount : int = 1
@export var sound: AudioStream

const HP_UP = preload("res://General/Sound Effects/hp-up.wav")

func use() -> void:
	PlayerManager.player.update_hp(heal_amount)
	PlayerHud.update_hp(PlayerManager.player.hp, PlayerManager.player.max_hp)
	print("healed player for: " + str(heal_amount))
	#play sound
	PlayerManager.play_audio(HP_UP)
	

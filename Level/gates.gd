extends TileMapLayer

@export var enemies_array:Array[Enemy]

var enemy_count:int
const LEVEL_WIN = preload("res://General/Sound Effects/level-win-6416.mp3")

func _ready() -> void:
	hide()
	collision_enabled = false
	enemy_count = enemies_array.size()
	for enemy in enemies_array:
		enemy.enemy_destroyed.connect(_on_enemy_destroyed)
	
func _on_enemy_destroyed(_attack:Attack)->void:
	enemy_count -= 1
	if enemy_count < 1:
		hide()
		PauseMenu.play_audio(LEVEL_WIN)
		PlayerHud.play_boss_defeat_message()
		collision_enabled = false
		AudioManager.fade_out_and_stop(AudioManager.music_players[AudioManager.current_music_player])
	pass

class_name State_Death extends State

@export var death_audio:AudioStream
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@export var anim_name:String = "stun"

func initialize()->void:
	pass

func enter() -> void:
	player.update_animation(anim_name)
	#audio_stream_player_2d.stream = death_audio
	#audio_stream_player_2d.play() 
	
	#trigger game over UI
	PlayerHud.show_game_over_screen()
	PlayerManager.pause_menu_disabled = true
	pass
	
func exit() -> void:
	pass
	
func process(_delta : float) -> State:
	player.velocity = Vector2.ZERO
	return null
	
func physics(_delta : float) -> State:
	return null
	
func handle_input(_event: InputEvent) -> State:
	return null

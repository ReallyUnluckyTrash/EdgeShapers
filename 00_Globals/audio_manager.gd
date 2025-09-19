#autoload script
#Audio Manager
extends Node

#music player variables
var music_audio_player_count:int = 2
var current_music_player:int = 0
var music_players:Array[AudioStreamPlayer] = []
var music_bus:String = "Music"
var music_fade_duration: float = 0.5

#sfx player variables
#since there is potentially a lot of sfx playing at the same time,
#set max sfx players to 20
var sfx_players:Array[AudioStreamPlayer] = []
var sfx_bus:String = "SFX"
var max_sfx_players:int = 20

#volume settings to be adjusted with the volume bar in the settings menu
var volume_settings:Dictionary = {
	"Master": 1.0,
	"Music" : 1.0,
	"SFX" : 1.0
}

func _ready()->void:
	#set process mode to always
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	#set up music audio players
	for music in music_audio_player_count:
		var audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
		audio_player.bus = music_bus
		music_players.append(audio_player)
	
	#set up sfx audio players
	for sfx in max_sfx_players:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = sfx_bus
		add_child(sfx_player)
		sfx_players.append(sfx_player)
		

func play_music(_audio:AudioStream)->void:
	#if audio to be played is the same, return
	if _audio == music_players[current_music_player].stream:
		return 
	
	#update current music player tracker
	current_music_player += 1
	if current_music_player > 1:
		current_music_player = 0
	
	#play the inputted audio file
	var current_audio_player:AudioStreamPlayer = music_players[current_music_player]
	current_audio_player.stream = _audio
	current_audio_player.play()
	
	#stop the old music 
	var old_player = music_players[1]
	if current_music_player == 1:
		old_player = music_players[0]
	old_player.stop()

func play_sfx(_audio:AudioStream)->AudioStreamPlayer:
	#loop through the players and check if its playing, if it is not play the audio
	for player in sfx_players:
		if not player.playing:
			player.stream = _audio
			player.play()
			return player
	
	#if all players are occupied override the first player
	sfx_players[0].stream = _audio
	sfx_players[0].play()
	return sfx_players[0]

#function to stop playing sfx
func stop_sfx(player:AudioStreamPlayer)->void:
	if player and player.playing:
		player.stop()

#stops player entirely
func fade_out_and_stop(player:AudioStreamPlayer)->void:
	player.stop()
	pass

#function to apply volume bar settings
func apply_volume_settings()->void:
	for bus_name in volume_settings:
		var bus_index = AudioServer.get_bus_index(bus_name)
		if bus_index != -1:
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume_settings[bus_name]))

#function to set specific audio bus volume
func set_bus_volume(bus_name: String, linear_value: float) -> void:
	volume_settings[bus_name] = linear_value
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_value))

#function to retrieve specific bus volume
func get_bus_volume(bus_name: String) -> float:
		return volume_settings.get(bus_name, 1.0)

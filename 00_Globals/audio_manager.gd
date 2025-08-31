extends Node

var music_audio_player_count:int = 2
var current_music_player:int = 0
var music_players:Array[AudioStreamPlayer] = []
var music_bus:String = "Music"
var music_fade_duration: float = 0.5

var sfx_players:Array[AudioStreamPlayer] = []
var sfx_bus:String = "SFX"
var max_sfx_players:int = 20

func _ready()->void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for music in music_audio_player_count:
		var audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
		audio_player.bus = music_bus
		music_players.append(audio_player)
		#audio_player.volume_db = -40
	
	for sfx in max_sfx_players:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = sfx_bus
		add_child(sfx_player)
		sfx_players.append(sfx_player)
		

func play_music(_audio:AudioStream)->void:
	if _audio == music_players[current_music_player].stream:
		return 
	
	current_music_player += 1
	if current_music_player > 1:
		current_music_player = 0
	
	var current_audio_player:AudioStreamPlayer = music_players[current_music_player]
	current_audio_player.stream = _audio
	current_audio_player.play()
	
	var old_player = music_players[1]
	if current_music_player == 1:
		old_player = music_players[0]
	#fade_out_and_stop(old_player)
	old_player.stop()

func play_sfx(_audio:AudioStream)->void:
	#loop through the players and check if its playing, if it is not play the audio
	for player in sfx_players:
		if not player.playing:
			player.stream = _audio
			player.play()
			return
	
	#if all players are occupied override the first player
	sfx_players[0].stream = _audio
	sfx_players[0].play()

func play_and_fade_in(player:AudioStreamPlayer)->void:
	player.play(0)
	var tween:Tween = create_tween()
	tween.tween_property(player, 'volume_db', 0, music_fade_duration)
	pass

func fade_out_and_stop(player:AudioStreamPlayer)->void:
	var tween:Tween = create_tween()
	tween.tween_property(player, 'volume_db', -40, music_fade_duration)
	await tween.finished
	player.stop()
	pass

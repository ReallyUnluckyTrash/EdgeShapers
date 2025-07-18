extends CanvasLayer

@onready var button_save: Button = $Control/TabContainer/System/VBoxContainer/Button_Save
@onready var button_load: Button = $Control/TabContainer/System/VBoxContainer/Button_Load
@onready var item_description: Label = $Control/TabContainer/Inventory/Description/ItemDescription
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_paused:bool = false

signal shown
signal hidden

func _ready() -> void:
	hide_pause_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if PlayerManager.pause_menu_disabled == true:
			return
		if is_paused == false:
			show_pause_menu()
		else:
			hide_pause_menu()
		get_viewport().set_input_as_handled()

func show_pause_menu() ->void:
	get_tree().paused = true
	visible = true
	is_paused = true
	shown.emit()

func hide_pause_menu() ->void:
	get_tree().paused = false
	visible = false
	is_paused = false
	hidden.emit()


func _on_button_save_pressed() -> void:
	if is_paused == false:
		return
	SaveManager.save_game()
	hide_pause_menu()
	pass # Replace with function body.



func _on_button_load_pressed() -> void:
	if is_paused == false:
		return
	SaveManager.load_game()
	await LevelManager.level_load_started
	hide_pause_menu()
	pass # Replace with function body.
	
	
func update_item_description(new_text:String)-> void:
	item_description.text = new_text
	
func play_audio(audio:AudioStream)->void:
	audio_stream_player_2d.stream = audio
	audio_stream_player_2d.play()	

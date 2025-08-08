extends CanvasLayer

@onready var button_save: Button = %Button_Save
@onready var button_load: Button = %Button_Load

@onready var item_description: Label = %ItemDescription
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var menu_tabs: TabContainer = %MenuTabs

@onready var weapon_inv_grid: InventoryUI = %WeaponInvGrid
@onready var upgrade_details_panel: UpgradeDetailsPanel = %UpgradeDetailsPanel

var is_paused:bool = false
@onready var inventory_blocker: ColorRect = %InventoryBlocker

signal shown
signal hidden

func _ready() -> void:
	inventory_blocker.visible = false
	inventory_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide_pause_menu()


func default_grab_focus():
	await get_tree().process_frame
	await get_tree().process_frame
	weapon_inv_grid.get_child(0).grab_focus()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if PlayerManager.pause_menu_disabled == true:
			return
		if is_paused == false:
			show_pause_menu()
			default_grab_focus()
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
	if item_description:
		item_description.text = new_text
	else:
		print("item description not updating!")

func update_upgrade_details(upgrade:Upgrade)->void:
	upgrade_details_panel.update_details(upgrade)
	pass

func clear_update_details()->void:
	upgrade_details_panel.clear_details()
	
	
func play_audio(audio:AudioStream)->void:
	audio_stream_player_2d.stream = audio
	audio_stream_player_2d.play()	

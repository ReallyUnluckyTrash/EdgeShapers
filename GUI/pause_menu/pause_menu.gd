#autoload script
#PauseMenu
extends CanvasLayer

const ERROR = preload("res://Interactables/Shop Statue/error.wav")

@onready var item_description: Label = %ItemDescription
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var menu_tabs: TabContainer = %MenuTabs
@onready var weapon_inv_grid: InventoryUI = %WeaponInvGrid
@onready var upgrade_details_panel: UpgradeDetailsPanel = %UpgradeDetailsPanel

@onready var hp_label: Label = %"HP Label"
@onready var ep_label: Label = %"EP Label"
@onready var ep_regen_label: Label = %"EP Regen Label"
@onready var damage_label: Label = %"Damage Label"
@onready var attack_speed_label: Label = %"Attack Speed Label"

var is_paused:bool = false
@onready var inventory_blocker: ColorRect = %InventoryBlocker

signal shown
signal hidden

func _ready() -> void:
	inventory_blocker.visible = false
	inventory_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide_pause_menu()
	update_status_upgrade_table()

func default_grab_focus():
	await get_tree().process_frame
	await get_tree().process_frame
	weapon_inv_grid.get_child(0).grab_focus()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if PlayerManager.pause_menu_disabled == true:
			play_audio(ERROR)
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
	menu_tabs.current_tab = 0
	update_status_upgrade_table()
	

func hide_pause_menu() ->void:
	get_tree().paused = false
	visible = false
	is_paused = false
	hidden.emit()
	
func update_item_description(new_text:String)-> void:
	if item_description:
		item_description.text = new_text
	else:
		print("item description not updating!")

func update_upgrade_details(upgrade:Upgrade)->void:
	upgrade_details_panel.update_details(upgrade)
	pass

func update_status_upgrade_table()->void:
	hp_label.text = "MAX HP: " + str(PlayerManager.player.max_hp)
	ep_label.text = "MAX EP: " + str(PlayerManager.player.max_ep)
	ep_regen_label.text = "EP REGEN: " + str(PlayerManager.player.ep_recharge_count)
	damage_label.text = "DMG BOOST: " + str(PlayerManager.player.damage_boost)
	attack_speed_label.text = "ATK SPD: " + str(PlayerManager.player.attack_speed)

func clear_update_details()->void:
	upgrade_details_panel.clear_details()
	
	
func play_audio(audio:AudioStream)->void:
	audio_stream_player_2d.stream = audio
	audio_stream_player_2d.play()	

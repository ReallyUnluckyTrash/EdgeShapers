extends CanvasLayer

@onready var upgrade_choice_button: UpgradeChoiceButton = %UpgradeChoiceButton
@onready var upgrade_choice_button_2: UpgradeChoiceButton = %UpgradeChoiceButton2
@onready var upgrade_choice_button_3: UpgradeChoiceButton = %UpgradeChoiceButton3

@export var common_upgrade_list:Array[Upgrade] = []
@export var rare_upgrade_list:Array[Upgrade] = []
@export var epic_upgrade_list:Array[Upgrade] = []

func _ready() -> void:
	hide_menu()
	pass

func show_menu()->void:
	visible = true
	get_tree().paused = true
	PlayerManager.pause_menu_disabled = true
	
	set_upgrade_choice(upgrade_choice_button)
	set_upgrade_choice(upgrade_choice_button_2)
	set_upgrade_choice(upgrade_choice_button_3)
	
	
	await get_tree().process_frame
	await get_tree().process_frame
	upgrade_choice_button.get_child(0).grab_focus()
	pass

func hide_menu()->void:
	visible = false
	get_tree().paused = false
	PlayerManager.pause_menu_disabled = false
	pass
	
	
func set_upgrade_choice(choice_button: UpgradeChoiceButton) -> void:
	# Early return if any list is empty
	if common_upgrade_list.is_empty() or rare_upgrade_list.is_empty() or epic_upgrade_list.is_empty():
		print("Warning: One or more upgrade lists are empty")
		return
	
	var roll = randi_range(1, 10)
	var selected_upgrade: Upgrade
	
	if roll <= 6:  # 60% chance for common (1-6)
		selected_upgrade = common_upgrade_list[randi() % common_upgrade_list.size()]
	elif roll <= 9:  # 30% chance for rare (7-9)  
		selected_upgrade = rare_upgrade_list[randi() % rare_upgrade_list.size()]
	else:  # 10% chance for epic (10)
		selected_upgrade = epic_upgrade_list[randi() % epic_upgrade_list.size()]
	
	choice_button.update_details(selected_upgrade)
	#connect signal
	if choice_button.button_pressed.is_connected(acquire_upgrade):
		choice_button.button_pressed.disconnect(acquire_upgrade)
	choice_button.button_pressed.connect(acquire_upgrade.bind(selected_upgrade))
	
func acquire_upgrade(_upgrade:Upgrade)->void:
	if _upgrade is UpgradeWeapon:
		PlayerManager.PLAYER_UPGRADE_LIST.add_upgrade_weapon(_upgrade)
		_upgrade.apply_upgrade(PlayerManager.player.current_weapon)
		
	elif _upgrade is UpgradePlayer:
		PlayerManager.PLAYER_UPGRADE_LIST.add_upgrade_player(_upgrade)
		_upgrade.apply_player_upgrade(PlayerManager.player)
	else:
		print("UpgradeChoiceMenu.gd:: " + _upgrade.upgrade_name + "does not apply to the known upgrade types!")
	
	hide_menu()
	
	pass

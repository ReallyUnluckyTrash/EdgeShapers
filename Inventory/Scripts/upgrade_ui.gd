class_name UpgradeUI extends Control

const UPGRADE_HELD_ENTRY = preload("res://Inventory/Scenes/upgrade_held_entry.tscn")

enum UpgradeType{
	PLAYER,
	WEAPON
}

@export var upgrade_type:UpgradeType

var upgrade_list

func _ready() -> void:
	PauseMenu.shown.connect(update_upgrade_ui)
	PauseMenu.hidden.connect(clear_upgrade_ui)
	clear_upgrade_ui()
	
	match upgrade_type:
		UpgradeType.PLAYER:
			upgrade_list = PlayerManager.PLAYER_UPGRADE_LIST.upgrades_player
		UpgradeType.WEAPON:
			upgrade_list = PlayerManager.PLAYER_UPGRADE_LIST.upgrades_weapon
	

func update_upgrade_ui():
	if upgrade_list == null:
		return
		
	for upgrade in upgrade_list:
		var new_entry = UPGRADE_HELD_ENTRY.instantiate()
		add_child(new_entry)
		new_entry.setup_entry(upgrade)
	pass
	
func clear_upgrade_ui():
	for child in get_children():
		child.queue_free()
	pass

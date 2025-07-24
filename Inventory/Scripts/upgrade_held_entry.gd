class_name UpgradeHeldEntry extends Button

var upgrade:Upgrade
var upgrade_description:String
@onready var rarity_label: Label = %RarityLabel
@onready var name_label: Label = %NameLabel

func _ready() -> void:
	rarity_label.text = ""
	name_label.text = ""
	focus_entered.connect(entry_focused)
	focus_exited.connect(entry_unfocused)

func setup_entry(_upgrade:Upgrade):
	upgrade = _upgrade
	upgrade_description = _upgrade.upgrade_description
	rarity_label.text = "Rarity: " + Upgrade.Rarity.keys()[upgrade.rarity]
	name_label.text = _upgrade.upgrade_name

func entry_focused():
	if upgrade != null:
		PauseMenu.update_upgrade_details(upgrade)
	pass

func entry_unfocused():
	PauseMenu.clear_update_details()
	pass

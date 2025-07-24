class_name UpgradeDetailsPanel extends Control

@onready var upgrade_image: TextureRect = %UpgradeImage
@onready var upgrade_name: Label = %UpgradeName
@onready var upgrade_description: Label = %UpgradeDescription
@onready var upgrade_value: Label = %UpgradeValue
@onready var upgrade_rarity: Label = %UpgradeRarity

func _ready():
	clear_details()
	
func update_details(upgrade:Upgrade):
	#upgrade_image.texture = upgrade.texture
	upgrade_name.text = upgrade.upgrade_name
	upgrade_description.text = upgrade.upgrade_description
	upgrade_value.text = "Value = " + str(upgrade.value)
	upgrade_rarity.text = "Rarity: " + Upgrade.Rarity.keys()[upgrade.rarity]

func clear_details():
	upgrade_image.texture = null
	upgrade_name.text = ""
	upgrade_description.text = ""
	upgrade_value.text = ""
	upgrade_rarity.text = ""

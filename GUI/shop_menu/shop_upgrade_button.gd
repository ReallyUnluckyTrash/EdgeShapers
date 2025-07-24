class_name ShopUpgradeButton extends Control

var upgrade:Upgrade

#@onready var texture_rect: TextureRect = $TextureRect
@onready var price_label: Label = %PriceLabel
@onready var name_label: Label = %NameLabel
@onready var rarity_label: Label = %RarityLabel

func setup_upgrade(_upgrade:Upgrade):
	upgrade = _upgrade
	name_label.text = upgrade.upgrade_name
	price_label.text = str(upgrade.value)
	rarity_label.text = "Rarity: " + Upgrade.Rarity.keys()[upgrade.rarity]
	pass

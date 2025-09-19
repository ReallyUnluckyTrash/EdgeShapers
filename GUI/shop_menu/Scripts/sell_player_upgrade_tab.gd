#unused
class_name SellPlayerUpgradeTab extends Control

@onready var sell_plyr_up_container: GridContainer = %SellPlyrUpContainer
const SHOP_UPGRADE_BUTTON = preload("res://GUI/shop_menu/Scenes/shop_upgrade_button.tscn")

var upgrade_list

func _ready() -> void:
	upgrade_list = PlayerManager.PLAYER_UPGRADE_LIST.upgrades_player

func populate_sell_list()->void:
	for child in sell_plyr_up_container.get_children():
		child.queue_free()

	for i in range(upgrade_list.size()):
		var shop_upgrade_entry:ShopUpgradeButton = SHOP_UPGRADE_BUTTON.instantiate()
		sell_plyr_up_container.add_child(shop_upgrade_entry)
		shop_upgrade_entry.setup_upgrade(upgrade_list[i])
		
		shop_upgrade_entry.pressed.connect(sell_upgrade.bind(i))
	pass

func sell_upgrade(_index:int):
	if _index >= 0 and _index < upgrade_list.size():
		var sold_upgrade:Upgrade = upgrade_list[_index]
		
		#sell price about half the value
		var sell_value:int = floor(sold_upgrade.value/2)
		PlayerManager.vertex_points += sell_value
		
		PlayerManager.PLAYER_UPGRADE_LIST.remove_by_index_player(_index)
		ShopMenu.update_currency()
		
		#just realized that im gonna have to pull off the buffs somehow uhhhhhhh yeah nvm bro 
		PlayerManager.player.clear_upgrades_player()
		PlayerManager.player.activate_upgrades_player()
		
		
		populate_sell_list()
		ShopMenu.play_audio(ShopMenu.PURCHASE)
		pass
	else:
		print("sell upgrade failed!")
		

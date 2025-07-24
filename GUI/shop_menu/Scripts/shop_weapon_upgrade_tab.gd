class_name ShopWeaponUpgradeTab extends Control

const SHOP_UPGRADE_BUTTON = preload("res://GUI/shop_menu/shop_upgrade_button.tscn")

@onready var wpn_up_container: VBoxContainer = %WpnUpContainer
@onready var wpn_up_details: UpgradeDetailsPanel = %WpnUpDetails

func populate_list(_weapon_upgrade_list:Array[UpgradeWeapon]):
	for child in wpn_up_container.get_children():
		child.queue_free()
	
	for upgrade in _weapon_upgrade_list:
		var shop_upgrade_entry:ShopUpgradeButton = SHOP_UPGRADE_BUTTON.instantiate()
		wpn_up_container.add_child(shop_upgrade_entry)
		shop_upgrade_entry.setup_upgrade(upgrade)
		shop_upgrade_entry.focus_entered.connect(update_upgrade_details.bind(upgrade))
		shop_upgrade_entry.pressed.connect(purchase_upgrade.bind(upgrade))
	pass

func update_upgrade_details(_upgrade:Upgrade):
	wpn_up_details.update_details(_upgrade)
	pass

func purchase_upgrade(_upgrade:UpgradeWeapon):

	var can_purchase:bool = PlayerManager.vertex_points >= _upgrade.value
	
	if can_purchase:
		#play purchase audio
		ShopMenu.play_audio(ShopMenu.PURCHASE)
		
		#TODO
		#add upgrade to the player upgrade list!
		PlayerManager.PLAYER_UPGRADE_LIST.add_upgrade_weapon(_upgrade)
		
		PlayerManager.vertex_points -= _upgrade.value
		ShopMenu.update_currency()
		
		#TODO
		#repopulate sell list for upgrades
		
		#this is kind of a problem, since activate upgrades is called already when equipping a weapon
		#im gonna need to clear the upgrades then activate it
		#PlayerManager.player.activate_upgrades_weapon()
		#then rather than using the method in the player, just straight apply the upgrade instead
		#since the player method reactivates all the upgrades possessed
		#should also do this for the upgrade addition after clearing a floor
		_upgrade.apply_upgrade(PlayerManager.player.current_weapon)
	else:
		ShopMenu.play_audio(ShopMenu.ERROR)
		ShopMenu.error_animation_player.play("not_enough_money")
		ShopMenu.error_animation_player.seek(0)
	
	

	pass

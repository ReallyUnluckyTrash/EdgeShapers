class_name ShopPlayerUpgradeTab extends Control

const SHOP_UPGRADE_BUTTON = preload("res://GUI/shop_menu/Scenes/shop_upgrade_button.tscn")

@onready var player_up_detail: UpgradeDetailsPanel = $PlayerUpDetail
@onready var player_up_container: VBoxContainer = %PlayerUpContainer

func populate_list(_player_upgrade_list:Array[UpgradePlayer]):
	for child in player_up_container.get_children():
		child.queue_free()
	
	for upgrade in _player_upgrade_list:
		var shop_upgrade_entry:ShopUpgradeButton = SHOP_UPGRADE_BUTTON.instantiate()
		player_up_container.add_child(shop_upgrade_entry)
		shop_upgrade_entry.setup_upgrade(upgrade)
		shop_upgrade_entry.focus_entered.connect(update_upgrade_details.bind(upgrade))
		shop_upgrade_entry.pressed.connect(purchase_upgrade.bind(upgrade))
	pass

func update_upgrade_details(_upgrade:Upgrade):
	player_up_detail.update_details(_upgrade)
	pass

func purchase_upgrade(_upgrade:UpgradePlayer):

	var can_purchase:bool = PlayerManager.vertex_points >= _upgrade.value
	
	if can_purchase:
		#play purchase audio
		ShopMenu.play_audio(ShopMenu.PURCHASE)
		
		#add upgrade to the player upgrade list
		PlayerManager.PLAYER_UPGRADE_LIST.add_upgrade_player(_upgrade)
		
		PlayerManager.vertex_points -= _upgrade.value
		ShopMenu.update_currency()
		
		#TODO
		#repopulate sell list for upgrades
		
		_upgrade.apply_player_upgrade(PlayerManager.player)
	else:
		ShopMenu.play_audio(ShopMenu.ERROR)
		ShopMenu.error_animation_player.play("not_enough_money")
		ShopMenu.error_animation_player.seek(0)
	
	

	pass

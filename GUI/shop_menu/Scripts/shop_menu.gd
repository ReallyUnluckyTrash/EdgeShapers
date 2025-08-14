extends CanvasLayer

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

const ERROR = preload("res://Interactables/Shop Statue/error.wav")
const OPEN_SHOP = preload("res://Interactables/Shop Statue/open_shop.wav")
const PURCHASE = preload("res://Interactables/Shop Statue/purchase.wav")
const SHOP_ITEM_BUTTON = preload("res://GUI/shop_menu/Scenes/shop_item_button.tscn")
const SELL_ITEM_BUTTON = preload("res://GUI/shop_menu/Scenes/shop_item_button.tscn")

const SHOP_UPGRADES = preload("res://GUI/shop_menu/Resources/shop_upgrades.tres")

@export var items:ShopListItem
@onready var shop_items_container: VBoxContainer = %ShopItemsContainer
@onready var sell_items_container: GridContainer = %SellItemsContainer
@onready var sell_weapons_container: GridContainer = %SellWeaponsContainer

@onready var weapon_upgrades_tab: ShopWeaponUpgradeTab = %WeaponUpgrades
@onready var player_upgrades_tab: ShopPlayerUpgradeTab = %PlayerUpgrade
#@onready var sell_player_upgrades_tab: SellPlayerUpgradeTab = $"Control/TabContainer/Sell/TabContainer/Player Upgrades"

@onready var currency_label: Label = %CurrencyLabel

@onready var item_image: TextureRect = %ItemImage
@onready var item_name: Label = %ItemName
@onready var item_description: Label = %ItemDescription
@onready var item_price: Label = %ItemPrice
@onready var close_button: Button = %CloseButton

@onready var error_animation_player: AnimationPlayer = %ErrorAnimationPlayer

var buttons_created: bool = false
var upgrades_weapon_list
var upgrades_player_list

func _ready() -> void:
	hide_menu()
	upgrades_weapon_list = SHOP_UPGRADES.upgrades_weapon
	upgrades_player_list = SHOP_UPGRADES.upgrades_player
	pass

func show_menu()->void:
	get_tree().paused = true
	visible = true
	PlayerManager.pause_menu_disabled = true
	play_audio(OPEN_SHOP)
	
	if not buttons_created:
		populate_item_list(items)
		weapon_upgrades_tab.populate_list(upgrades_weapon_list)
		player_upgrades_tab.populate_list(upgrades_player_list)
		buttons_created = true
	update_currency()
	#
	
	#update sell menu
	populate_sell_list(sell_items_container, PlayerManager.INVENTORY_ITEM_DATA)
	populate_sell_list(sell_weapons_container, PlayerManager.INVENTORY_WEAPON_DATA)
	#sell_player_upgrades_tab.populate_sell_list()
	
	await get_tree().process_frame
	await get_tree().process_frame
	#shop_items_container.get_child(0).grab_focus()
	close_button.grab_focus()

func hide_menu()->void:
	visible = false
	pass

func _on_close_button_pressed() -> void:
	PlayerManager.pause_menu_disabled = false
	hide_menu()
	get_tree().paused = false
	pass # Replace with function body.

func play_audio(_audio:AudioStream)->void:
	audio_stream_player_2d.stream = _audio
	audio_stream_player_2d.play()
	pass

func populate_item_list(_items:ShopListItem)->void:
	#remove children from shop items container
	for child in shop_items_container.get_children():
		child.queue_free()
	
	#then add items in the container according to the items list
	for item in _items.items:
		var shop_item:ShopItemButton = SHOP_ITEM_BUTTON.instantiate()
		shop_items_container.add_child(shop_item)
		shop_item.setup_item(item)
		#connect to signals
		shop_item.focus_entered.connect(update_item_details.bind(item))
		shop_item.pressed.connect(purchase_item.bind(item))
		pass
	pass

func populate_sell_list(sell_container:GridContainer, player_inventory:InventoryData)->void:
	for child in sell_container.get_children():
		child.queue_free()
		
	for i in range(player_inventory.slots.size()):
		var slot = player_inventory.slots[i]
		var sell_item_button:SellItemButton = SELL_ITEM_BUTTON.instantiate()
		sell_container.add_child(sell_item_button)
		var item = slot.item_data
		var quantity = slot.quantity
		sell_item_button.setup_item(item, quantity)
		
		#connect to signals
		sell_item_button.pressed.connect(sell_item.bind(i, player_inventory))
		#sell_item_button.call_deferred("grab_focus")
		pass
	
	
	pass


func update_currency()->void:
	currency_label.text = str(PlayerManager.vertex_points)
	PlayerHud.update_currency_label(PlayerManager.vertex_points)
	pass

func on_focused_item_changed(_item:ItemData)->void:
	if _item:
		update_item_details(_item)
	pass

func update_item_details(_item:ItemData)->void:
	item_image.texture = _item.texture
	item_name.text = _item.name
	item_description.text = _item.description
	item_price.text = "Price = " + str(_item.price)
	
	pass

func purchase_item(_item:ItemData)->void:
	var can_purchase:bool = PlayerManager.vertex_points >= _item.price
	
	#check if item is purchasable 
	if can_purchase:
		play_audio(PURCHASE)
		
		if _item.type == "Weapon":
			#first check if weapon is already in the inventory,
			#if it is then purchase fails
			if PlayerManager.INVENTORY_WEAPON_DATA.has_item_(_item):
				print("Weapon already owned!")
				play_audio(ERROR)
				return
			#if it is not then add to inventory
			PlayerManager.INVENTORY_WEAPON_DATA.add_item(_item, 1)
			
		elif _item.type == "Item":
			PlayerManager.INVENTORY_ITEM_DATA.add_item(_item, 1)
			pass
			
		#reduce currency and update the currency counter
		PlayerManager.vertex_points -= _item.price
		update_currency()
		
		populate_sell_list(sell_items_container, PlayerManager.INVENTORY_ITEM_DATA)
		populate_sell_list(sell_weapons_container, PlayerManager.INVENTORY_WEAPON_DATA)
		
		pass
	
	#if not purchasable, give error
	else:
		play_audio(ERROR)
		error_animation_player.play("not_enough_money")
		error_animation_player.seek(0)
	pass

func sell_item(index:int, player_inventory:InventoryData)->void:
	if index >= 0 and index < player_inventory.slots.size():
		var slot = player_inventory.slots[index]
		var item = slot.item_data
		
		if item.type == "Weapon" and PlayerManager.equipped_weapon == item:
			print("Cannot sell equipped weapon!")
			play_audio(ERROR)
			#add animation for error here as well
			return
		
		#determine sell price then reduce the player's currency
		var sell_value:int = item.price
		PlayerManager.vertex_points += sell_value
		
		#reduce slot quantity, if less than 1 than remove
		if slot.quantity > 1:
			slot.quantity -= 1
		else:
			player_inventory.remove_item_index(index)
		
		
		#update currency counter
		update_currency()
		close_button.grab_focus()
		
		#then update sell list to match the inventory
		populate_sell_list(sell_items_container, PlayerManager.INVENTORY_ITEM_DATA)
		populate_sell_list(sell_weapons_container, PlayerManager.INVENTORY_WEAPON_DATA)
		play_audio(PURCHASE)
	else:
		print("sell item failed!")
	
	pass

extends CanvasLayer

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

const ERROR = preload("res://Interactables/Shop Statue/error.wav")
const OPEN_SHOP = preload("res://Interactables/Shop Statue/open_shop.wav")
const PURCHASE = preload("res://Interactables/Shop Statue/purchase.wav")
const SHOP_ITEM_BUTTON = preload("res://GUI/shop_menu/shop_item_button.tscn")


@export var items:ShopListItem
@onready var shop_items_container: VBoxContainer = %ShopItemsContainer
@onready var currency_label: Label = %CurrencyLabel

@onready var item_image: TextureRect = %ItemImage
@onready var item_name: Label = %ItemName
@onready var item_description: Label = %ItemDescription
@onready var item_price: Label = %ItemPrice
@onready var error_animation_player: AnimationPlayer = %ErrorAnimationPlayer

@onready var sell_items_container: VBoxContainer = %SellItemsContainer
@onready var sell_weapons_container: VBoxContainer = %SellWeaponsContainer


var buttons_created: bool = false


func _ready() -> void:
	hide_menu()
	pass

func show_menu()->void:
	get_tree().paused = true
	visible = true
	play_audio(OPEN_SHOP)
	
	if not buttons_created:
		populate_item_list(items)
		buttons_created = true
	update_currency()
	#
	
	populate_sell_list(sell_items_container, PlayerManager.INVENTORY_ITEM_DATA)
	populate_sell_list(sell_weapons_container, PlayerManager.INVENTORY_WEAPON_DATA)
	
	await get_tree().process_frame
	await get_tree().process_frame
	shop_items_container.get_child(0).grab_focus()

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

func populate_sell_list(sell_container:VBoxContainer, player_inventory:InventoryData)->void:
	for child in sell_container.get_children():
		child.queue_free()
		
	for i in range(player_inventory.slots.size()):
		var slot = player_inventory.slots[i]
		var shop_item:ShopItemButton = SHOP_ITEM_BUTTON.instantiate()
		sell_container.add_child(shop_item)
		var item = slot.item_data
		shop_item.setup_item(item)
		#connect to signals
		shop_item.pressed.connect(sell_item.bind(i, player_inventory))
		pass
	
	
	pass


func update_currency()->void:
	currency_label.text = str(PlayerManager.vertex_points)
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
	if can_purchase:
		play_audio(PURCHASE)
		
		if _item.type == "Weapon":
			PlayerManager.INVENTORY_WEAPON_DATA.add_item(_item, 1)
			
		elif _item.type == "Item":
			PlayerManager.INVENTORY_ITEM_DATA.add_item(_item, 1)
			pass
		PlayerManager.vertex_points -= _item.price
		update_currency()
		
		populate_sell_list(sell_items_container, PlayerManager.INVENTORY_ITEM_DATA)
		populate_sell_list(sell_weapons_container, PlayerManager.INVENTORY_WEAPON_DATA)
		
		pass
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
		
		var sell_value:int = item.price
		PlayerManager.vertex_points += sell_value
		
		player_inventory.remove_item_index(index)
		
		update_currency()
		
		populate_sell_list(sell_items_container, PlayerManager.INVENTORY_ITEM_DATA)
		populate_sell_list(sell_weapons_container, PlayerManager.INVENTORY_WEAPON_DATA)
		play_audio(PURCHASE)
	else:
		print("sell item failed!")
	
	pass

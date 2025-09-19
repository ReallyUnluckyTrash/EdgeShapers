extends Node

#player reference
const PLAYER = preload("res://Player/Scenes/player.tscn")

#player inventory resource references, item and weapons are separate
var INVENTORY_WEAPON_DATA:InventoryData = preload("res://Inventory/Resources/player_weapon_inv.tres")
var INVENTORY_ITEM_DATA:InventoryData = preload("res://Inventory/Resources/player_item_inv.tres")

#player upgrade list resource reference
var PLAYER_UPGRADE_LIST:UpgradeList = preload("res://Inventory/Resources/player_upgrade_list.tres")
#player equipped items resource reference
var PLAYER_EQUIPPED_DATA = preload("res://Inventory/Resources/player_equipped.tres")

#default weapon reference
const BASIC_WEAPON = preload("res://Weapons/Resources/basic_weapon.tres")

#player variables
var player : Player
var player_spawned:bool = false

#current floor tracker and currency tracker
var vertex_points:int = 100
var current_floor:int = 1 :set = set_floor

#bool to prevent pause menu appearing
var pause_menu_disabled:bool = false

#player's current equipped weapon and equipped item tracker
static var equipped_weapon:ItemData = null
static var equipped_item:SlotData = SlotData.new()

signal weapon_equipped(item_data: ItemData)
signal item_equipped(item_data:ItemData, quantity:int)

@warning_ignore("unused_signal")
signal interact_pressed

func _ready() -> void:
	#on ready add player instance and set equipped item quantity to 0
	add_player_instance()
	equipped_item.quantity = 0

#adds a player instance
func add_player_instance()->void:
	player = PLAYER.instantiate()
	add_child(player)
	pass

#sets player's position
func set_player_position(_new_pos: Vector2) -> void:
	player.global_position = _new_pos
	pass

#changes player's health and max health
func set_health(hp:int, max_hp:int) -> void:
	player.max_hp = max_hp
	player.hp = hp
	player.update_hp(0)
	pass

#changes player's currently equipped weapon
func set_equipped_weapon(new_weapon: PackedScene, item_data: ItemData )->void:
	player.equip_weapon(new_weapon)	
	weapon_equipped.emit(item_data)
	equipped_weapon = item_data
	pass

#when pressing the correct input, use equipped item
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_equipped_item"):
		use_equipped_item()

func set_equipped_item(item_data: ItemData, quantity:int)->void:
	#when equipped item is used up the item data becomes null, 
	#check if there is still an equipped item when trying to equip a new item
	#then, add the previously equipped item back to inventory, then update
	if equipped_item.item_data != null:
		INVENTORY_ITEM_DATA.add_item(equipped_item.item_data, equipped_item.quantity)
		INVENTORY_ITEM_DATA.update_ui.emit()
		pass
	
	#sets player's equipped item and updates the necessary textures and quantities
	item_equipped.emit(item_data, quantity)
	equipped_item = SlotData.new()
	equipped_item.item_data = item_data
	equipped_item.quantity = quantity
	PlayerHud.update_equipped_texture(item_data.texture)
	PlayerHud.update_equipped_quantity(quantity)
	pass

func use_equipped_item()->void:
	if equipped_item.item_data:
		#checks if item has effects upon use, if it does not return
		var was_used = equipped_item.item_data.use()
		if was_used == false:
			return 
		
		#reduce equipped item quantity on use
		equipped_item.quantity -= 1
		
		#if equipped item quantity is above zero, update the quantity value in the hud
		if equipped_item.quantity >= 1:
			PlayerHud.update_equipped_quantity(equipped_item.quantity)
		
		#if the equipped item is below zero, clear all information and empty the equipped slot
		elif equipped_item.quantity < 1:
			PLAYER_EQUIPPED_DATA.clear_slot_info_index(1)
			PlayerHud.equipped_item_texture.texture = null
			PlayerHud.equipped_item_quantity.text = ""
			equipped_item.item_data = null
			equipped_item.quantity = 0
			pass
	else:
		print("PlayerManager::no equipped item!")

#sets the player's parent
func set_as_parent(_parent: Node2D)->void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	_parent.add_child(player)

#unparents the player's current parent
func unparent_player(_parent: Node2D)->void:
	if not player or not is_instance_valid(player):
		return
	
	var actual_parent = player.get_parent()
	if actual_parent == _parent:
		_parent.remove_child(player)

#reset player's inventory, upgrades and stats
func reset_player()->void:
	player.clear_upgrades_player()
	INVENTORY_ITEM_DATA.reset_inventory()
	INVENTORY_WEAPON_DATA.reset_inventory()
	PLAYER_UPGRADE_LIST.clear_upgrades()
	PLAYER_EQUIPPED_DATA.empty_slots()
	
	INVENTORY_WEAPON_DATA.add_item(BASIC_WEAPON, 1)
	set_equipped_weapon(BASIC_WEAPON.scene, BASIC_WEAPON)
	player.state_machine.change_state(player.state_machine.states[0])
	vertex_points = 30
	current_floor = 1
	PlayerHud.update_currency_label(vertex_points)
	
#play audio
func play_audio(_audio: AudioStream)->void:
	player.audio_stream_player_2d.stream = _audio
	player.audio_stream_player_2d.play()

#sets current floor
func set_floor(_new_floor:int)->void:
	current_floor = _new_floor
	PlayerHud.update_floor_label(current_floor)

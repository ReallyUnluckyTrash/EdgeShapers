extends Node

const PLAYER = preload("res://Player/Scenes/player.tscn")
const INVENTORY_WEAPON_DATA:InventoryData = preload("res://Inventory/Resources/player_weapon_inv.tres")
const INVENTORY_ITEM_DATA:InventoryData = preload("res://Inventory/Resources/player_item_inv.tres")
const PLAYER_UPGRADE_LIST = preload("res://Inventory/Resources/player_upgrade_list.tres")
const BASIC_WEAPON = preload("res://Weapons/Resources/basic_weapon.tres")
const PLAYER_EQUIPPED_DATA = preload("res://Inventory/Resources/player_equipped.tres")

var player : Player
var player_spawned:bool = false
var vertex_points:int = 100
var current_floor:int = 1 :set = set_floor
var pause_menu_disabled:bool = false

static var equipped_weapon:ItemData = null
static var equipped_item:SlotData = SlotData.new()


signal weapon_equipped(item_data: ItemData)
signal item_equipped(item_data:ItemData, quantity:int)

@warning_ignore("unused_signal")
signal interact_pressed

func _ready() -> void:
	add_player_instance()
	equipped_item.quantity = 0
	#await get_tree().create_timer(0.2).timeout
	#player_spawned = true

func add_player_instance()->void:
	player = PLAYER.instantiate()
	add_child(player)
	pass
	
func set_player_position(_new_pos: Vector2) -> void:
	player.global_position = _new_pos
	pass

func set_health(hp:int, max_hp:int) -> void:
	player.max_hp = max_hp
	player.hp = hp
	player.update_hp(0)
	pass

func set_equipped_weapon(new_weapon: PackedScene, item_data: ItemData )->void:
	player.equip_weapon(new_weapon)	
	weapon_equipped.emit(item_data)
	equipped_weapon = item_data
	pass

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
	
	print("time to equip the item!")
	item_equipped.emit(item_data, quantity)
	equipped_item = SlotData.new()
	equipped_item.item_data = item_data
	equipped_item.quantity = quantity
	PlayerHud.update_equipped_texture(item_data.texture)
	PlayerHud.update_equipped_quantity(quantity)
	pass

func use_equipped_item()->void:
	if equipped_item.item_data:
		var was_used = equipped_item.item_data.use()
		
		if was_used == false:
			return 
			
		equipped_item.quantity -= 1
		
		if equipped_item.quantity >= 1:
			PlayerHud.update_equipped_quantity(equipped_item.quantity)
			
		elif equipped_item.quantity < 1:
			PLAYER_EQUIPPED_DATA.clear_slot_info_index(1)
			PlayerHud.equipped_item_texture.texture = null
			PlayerHud.equipped_item_quantity.text = ""
			equipped_item.item_data = null
			equipped_item.quantity = 0
			pass
	else:
		print("no equipped item!")

func set_as_parent(_parent: Node2D)->void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	_parent.add_child(player)

func unparent_player(_parent: Node2D)->void:
	if not player or not is_instance_valid(player):
		return
	
	var actual_parent = player.get_parent()
	
	if actual_parent == _parent:
		_parent.remove_child(player)

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
	
	
func play_audio(_audio: AudioStream)->void:
	player.audio_stream_player_2d.stream = _audio
	player.audio_stream_player_2d.play()

func set_floor(_new_floor:int)->void:
	current_floor = _new_floor
	PlayerHud.update_floor_label(current_floor)

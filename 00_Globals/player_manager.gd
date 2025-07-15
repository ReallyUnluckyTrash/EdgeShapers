extends Node

const PLAYER = preload("res://Player/player.tscn")
const INVENTORY_WEAPON_DATA = preload("res://Inventory/Resources/player_weapon_inv.tres")
const INVENTORY_ITEM_DATA = preload("res://Inventory/Resources/player_item_inv.tres")

var player : Player
var player_spawned:bool = false
var vertex_points:int = 100

var pause_menu_disabled:bool = false

signal weapon_equipped(item_data: ItemData)
signal interact_pressed

func _ready() -> void:
	add_player_instance()
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
	pass

func set_as_parent(_parent: Node2D)->void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	_parent.add_child(player)

func unparent_player(_parent: Node2D)->void:
	_parent.remove_child(player)

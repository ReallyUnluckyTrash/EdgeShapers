class_name DungeonConfig extends Node

@export_group("Tile Settings")
@export var tile_size: int = 64
@export var floor_tile: Vector2i = Vector2i(2, 9)
@export var wall_tile: Vector2i = Vector2i(2, 0)
@export var entrance_tile: Vector2i = Vector2i(4, 4)
@export var exit_tile: Vector2i = Vector2i(4, 6)

@export var top_left_edge_tile: Vector2i = Vector2i(0, 1)
@export var bottom_left_edge_tile: Vector2i = Vector2i(3, 1)
@export var bottom_right_edge_tile:Vector2i = Vector2i(1, 1)
@export var top_right_edge_tile:Vector2i = Vector2i(2, 1)

@export var left_wall_tile:Vector2i = Vector2i(0, 0)
@export var right_wall_tile:Vector2i = Vector2i(1, 0)
@export var bottom_wall_tile:Vector2i = Vector2i(2, 0)
@export var top_wall_tile:Vector2i = Vector2i(3, 0) 

#@export_group("Room Generation")
#@export var min_room_size_factor: float = 0.25 # fraction of total map size
#@export var max_room_size_factor: float = 0.4

@export_group("Loot Configuration")
@export var chest_items: Array[ItemData] = []

@export_group("Enemy Configuration")
@export var enemy_level_1_scenes: Array[PackedScene]
@export var enemy_level_2_scenes: Array[PackedScene]
@export var enemy_level_3_scenes: Array[PackedScene]
@export var enemy_level_4_scenes: Array[PackedScene]

var min_cell_size: Vector2i
@export var enemy_scenes: Dictionary = {}

func _ready():
	# Build enemy scenes dictionary from exported scenes
	if enemy_level_1_scenes:
		enemy_scenes[1] = enemy_level_1_scenes
	if enemy_level_2_scenes:
		enemy_scenes[2] = enemy_level_2_scenes
	if enemy_level_3_scenes:
		enemy_scenes[3] = enemy_level_3_scenes
	if enemy_level_4_scenes:
		enemy_scenes[4] = enemy_level_4_scenes

func setup(map_width: int, map_height: int):
	min_cell_size = Vector2i(
		max(5, map_width/4), 
		max(5, map_height/4)
	)

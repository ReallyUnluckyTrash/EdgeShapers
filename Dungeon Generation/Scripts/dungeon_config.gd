class_name DungeonConfig extends Node

@export_group("Tile Settings")
@export var tile_size: int = 64
@export var floor_tile: Vector2i = Vector2i(2, 9)
@export var wall_tile: Vector2i = Vector2i(1, 1)
@export var entrance_tile: Vector2i = Vector2i(4, 4)
@export var exit_tile: Vector2i = Vector2i(4, 6)

#@export_group("Room Generation")
#@export var min_room_size_factor: float = 0.25 # fraction of total map size
#@export var max_room_size_factor: float = 0.4

@export_group("Loot Configuration")
@export var chest_items: Array[ItemData] = []
@export var enhanced_chest_items: Array[ItemData] = []

@export_group("Enemy Configuration")
@export var enemy_level_1_scenes: Array[PackedScene]
@export var enemy_level_2_scenes: Array[PackedScene]
@export var enemy_level_3_scenes: Array[PackedScene]

@export_group("Enchanced Enemy Configuration")
@export var ench_enemy_level_1_scenes: Array[PackedScene]
@export var ench_enemy_level_2_scenes: Array[PackedScene]
@export var ench_enemy_level_3_scenes: Array[PackedScene]
@export var enemy_level_4_scenes: Array[PackedScene]

var min_partition_size: Vector2i
@export var enemy_scenes: Dictionary = {}
@export var ench_enemy_scenes: Dictionary = {}

func _ready():
	# Build enemy scenes dictionary from exported scenes
	if enemy_level_1_scenes:
		enemy_scenes[1] = enemy_level_1_scenes
	if enemy_level_2_scenes:
		enemy_scenes[2] = enemy_level_2_scenes
	if enemy_level_3_scenes:
		enemy_scenes[3] = enemy_level_3_scenes
	if ench_enemy_level_1_scenes:
		ench_enemy_scenes[1] = ench_enemy_level_1_scenes
	if ench_enemy_level_2_scenes:
		ench_enemy_scenes[2] = ench_enemy_level_2_scenes
	if ench_enemy_level_3_scenes:
		ench_enemy_scenes[3] = ench_enemy_level_3_scenes
	if enemy_level_4_scenes:
		ench_enemy_scenes[4] = enemy_level_4_scenes

func setup(map_width: int, map_height: int):
	min_partition_size = Vector2i(
		max(5, floor(map_width/4)), 
		max(5, floor(map_height/4))
	)

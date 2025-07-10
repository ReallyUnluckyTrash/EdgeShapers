class_name DungeonConfig extends Node

@export_group("Tile Settings")
@export var tile_size: int = 64
@export var floor_tile: Vector2i = Vector2i(17, 8)
@export var wall_tile: Vector2i = Vector2i(16, 5)
@export var entrance_tile: Vector2i = Vector2i(0, 1)
@export var exit_tile: Vector2i = Vector2i(0, 2)

#@export_group("Room Generation")
#@export var min_room_size_factor: float = 0.25 # fraction of total map size
#@export var max_room_size_factor: float = 0.4

@export_group("Loot Configuration")
@export var chest_items: Array[ItemData] = []

@export_group("Enemy Configuration")
@export var enemy_level_1_scene: PackedScene
@export var enemy_level_2_scene: PackedScene
@export var enemy_level_3_scene: PackedScene

var min_cell_size: Vector2i
var enemy_scenes: Dictionary = {}

func _ready():
	# Build enemy scenes dictionary from exported scenes
	if enemy_level_1_scene:
		enemy_scenes[1] = enemy_level_1_scene
	if enemy_level_2_scene:
		enemy_scenes[2] = enemy_level_2_scene
	if enemy_level_3_scene:
		enemy_scenes[3] = enemy_level_3_scene

func setup(map_width: int, map_height: int):
	min_cell_size = Vector2i(
		max(5, map_width/4), 
		max(5, map_height/4)
	)

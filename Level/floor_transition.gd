class_name FloorTransition extends Area2D

enum SIDE {LEFT, RIGHT, TOP, BOTTOM}

@export_file("*.tscn") var level

@export var grid_size:int = 64

@export var snap_to_grid: bool = false 

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

signal regenerate_dungeon

func _ready() -> void:

	monitoring = false
	
	await LevelManager.level_loaded
	
	monitoring = true
	body_entered.connect(_player_entered)
	pass

func _player_entered(_player:Node2D)->void:
	#regenerate_dungeon.emit()
	
	LevelManager.load_new_level(level, "", Vector2(0,0))
	PlayerManager.current_floor += 1
	PlayerManager.player.update_hp(99)
	PlayerManager.player.update_ep(99)
	pass

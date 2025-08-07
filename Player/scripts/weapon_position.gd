class_name WeaponPosition extends Node2D

@export var weapon_position_x = 0
@onready var node = $"."


func update_position(direction: String):
	if direction == "down":
		position.x = -weapon_position_x
		position.y = 0
		rotation_degrees = 180
	if direction == "up" || direction == "idle":
		position.x = weapon_position_x
		position.y = 0
		rotation_degrees = 0
	if direction == "right":
		position.x = 0
		position.y = weapon_position_x
		rotation_degrees = 90
	if direction == "left":
		position.x = 0
		position.y = -weapon_position_x
		rotation_degrees = -90
	pass
	

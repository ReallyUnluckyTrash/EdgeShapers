class_name FrontWeaponPosition extends Node2D

@onready var node = $"."

func update_position(direction: String):
	if direction == "down":
		position.x = 0
		position.y = 60
		rotation_degrees = 90
	if direction == "up" || direction == "idle":
		position.x = 0
		position.y = -60
		rotation_degrees = -90
	if direction == "right":
		position.x = 60
		position.y = 0
		rotation_degrees = 0
	if direction == "left":
		position.x = -60
		position.y = 0
		rotation_degrees = 180
	pass
	

class_name FrontWeaponPosition extends WeaponPosition

@export var weapon_position_y:int = 0

func update_position(direction: String):
	if direction == "down":
		position.x = 0
		position.y = weapon_position_y
		rotation_degrees = 90
	if direction == "up" || direction == "idle":
		position.x = 0
		position.y = -weapon_position_y
		rotation_degrees = -90
	if direction == "right":
		position.x = weapon_position_y
		position.y = 0
		rotation_degrees = 0
	if direction == "left":
		position.x = -weapon_position_y
		position.y = 0
		rotation_degrees = 180
	pass
	

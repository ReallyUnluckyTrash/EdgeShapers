class_name KnightWeaponPosition extends WeaponPosition

@onready var shield_position: WeaponPosition = %ShieldPosition

func update_position(direction: String):
	if direction == "down":
		position.x = -weapon_position_x
		position.y = 0
		rotation_degrees = 180
		
		shield_position.position.x = weapon_position_x
		shield_position.position.y = 0
		shield_position.rotation_degrees = 180
		
	if direction == "up" || direction == "idle":
		position.x = weapon_position_x
		position.y = 0
		rotation_degrees = 0
		
		shield_position.position.x = -weapon_position_x
		shield_position.position.y = 0
		shield_position.rotation_degrees = 0 
	if direction == "right":
		position.x = 0
		position.y = weapon_position_x
		rotation_degrees = 90
		
		shield_position.position.x = 0
		shield_position.position.y = -weapon_position_x
		shield_position.rotation_degrees = 90
		
	if direction == "left":
		position.x = 0
		position.y = -weapon_position_x
		rotation_degrees = -90
		
		shield_position.position.x = 0
		shield_position.position.y = weapon_position_x
		shield_position.rotation_degrees = -90
	pass
	

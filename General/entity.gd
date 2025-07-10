class_name Entity extends CharacterBody2D

const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
var cardinal_direction : Vector2 = Vector2.DOWN
var direction: Vector2 = Vector2.ZERO

signal direction_change(new_direction : Vector2)

func set_direction(_new_direction:Vector2) -> bool:
	direction = _new_direction
	if direction == Vector2.ZERO:
		return false
	
	var direction_id : int = int( 
		round( (direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size() )
			)
	var new_dir = DIR_4[direction_id]
	
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	direction_change.emit(new_dir)
	
	return true
	
func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	elif cardinal_direction == Vector2.RIGHT:
		return "right"
	elif cardinal_direction == Vector2.LEFT:
		return "left"
	else:
		return "idle"


	

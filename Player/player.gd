class_name Player extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
var direction: Vector2 = Vector2.ZERO

@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


#signal hit

signal DirectionChange(new_direction : Vector2)

func _ready():
	state_machine.Initialize(self)
	pass

func _process(delta):
	
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	
	pass
	
func _physics_process(delta: float):
	move_and_slide()
	
func SetDirection():
	var new_dir : Vector2 = cardinal_direction
	if direction == Vector2.ZERO:
		return 
		
	if direction.y == 0:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif direction.x == 0:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
		
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	DirectionChange.emit(new_dir)
	
	#sprite code goes here
	
	return true

func AnimDirection() -> String:
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


func UpdateAnimation(anim_name : String):
	animated_sprite_2d.play()
	animated_sprite_2d.animation = anim_name

	
	

	

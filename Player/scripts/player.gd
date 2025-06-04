class_name Player extends Entity


@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#signal hit


#var cardinal_direction : Vector2 = Vector2.DOWN
#var direction: Vector2 = Vector2.ZERO
#const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
#signal direction_change(new_direction : Vector2)

func _ready():
	PlayerManager.player = self
	state_machine.initialize(self)
	pass

func _process(_delta):
	
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	
	pass
	
func _physics_process(_delta: float):
	move_and_slide()

func update_animation(anim_name : String):
	animated_sprite_2d.play()
	animated_sprite_2d.animation = anim_name

	
	

	

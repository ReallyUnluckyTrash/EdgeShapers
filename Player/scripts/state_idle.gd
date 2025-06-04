class_name State_Idle extends State

@onready var walk: State_Walk = $"../Walk"
@onready var attack: State_Attack = $"../Attack"

func Enter() -> void:
	#print("Entered idle state.")
	#player.animated_sprite_2d.stop()
	player.animated_sprite_2d.stop()
	player.UpdateAnimation("idle")
	print(player.cardinal_direction)
	pass
	
func Exit() -> void:
	pass
	
func Process(_delta : float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	return null
	
func Physics(_delta : float) -> State:
	return null
	
func HandleInput(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	return null

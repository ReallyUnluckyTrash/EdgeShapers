class_name State_Idle extends State

@onready var walk: State_Walk = $"../Walk"
@onready var attack: State_Attack = $"../Attack"

func enter() -> void:
	#print("Entered idle state.")
	#player.animated_sprite_2d.stop()
	player.animated_sprite_2d.stop()
	player.update_animation("idle")
	#print(player.cardinal_direction)
	pass
	
func exit() -> void:
	pass
	
func process(_delta : float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	return null
	
func physics(_delta : float) -> State:
	return null
	
func handle_input(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		if player.current_weapon != null:
			return attack
	if _event.is_action_pressed("interact"):
		PlayerManager.interact_pressed.emit()
	
	return null

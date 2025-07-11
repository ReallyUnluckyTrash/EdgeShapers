class_name State_Walk extends State

@export var move_speed:float = 200.0

@onready var idle : State_Idle = $"../Idle"
@onready var attack: State_Attack = $"../Attack"
@onready var weapon = $"../../WeaponPosition"

#@onready var spear_hurt_box: HurtBox = $"../../Interactions/Spear/SpearHurtBox"

func enter() -> void:
	#print("Entered Walk State")
	#spear_hurt_box.monitoring = true
	player.animated_sprite_2d.stop()
	#print("hurt box on")
	#print(player.cardinal_direction)
	pass
	
func exit() -> void:
	#spear_hurt_box.monitoring = false
	#print("hurt box off")
	pass
	
func process(_delta : float) -> State:
	if player.direction == Vector2.ZERO:	
		return idle
	
	player.velocity = player.direction * move_speed
	

	player.set_direction(player.direction)
	weapon.UpdatePosition(player.anim_direction())	
	player.update_animation(player.anim_direction())
		
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

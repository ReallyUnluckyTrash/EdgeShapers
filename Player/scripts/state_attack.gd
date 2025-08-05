class_name State_Attack extends State

@onready var idle : State_Idle = $"../Idle"
@onready var walk: State_Walk = $"../Walk"

@export_range(1, 20, 0.5) var decelerate_speed: float = 5.0

var attacking: bool = false

func enter() -> void:
	attacking = true

	if player.current_weapon:
		player.current_weapon.attack()
		player.current_weapon.attack_finished.connect(end_attack)
	#await get_tree().create_timer( 0.15).timeout
	pass
	
func exit() -> void:
	attacking = false
	
	if player.current_weapon and player.current_weapon.has_signal("attack_finished"):
		if player.current_weapon.attack_finished.is_connected(end_attack):
			player.current_weapon.attack_finished.disconnect(end_attack)
	
	if player.current_weapon and player.current_weapon.has_method("return_to_idle"):
		player.current_weapon.return_to_idle()
	pass
	
func process(_delta : float) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	
	if attacking == false:
		#player.current_weapon.return_to_idle()
		if player.direction == Vector2.ZERO:
			return idle
		else: 
			return walk
	return null
	
func physics(_delta : float) -> State:
	return null
	
func handle_input(_event: InputEvent) -> State:
	return null

func end_attack() -> void:
	print("state_attack.gd::end_attack() Ending attack!")
	attacking = false

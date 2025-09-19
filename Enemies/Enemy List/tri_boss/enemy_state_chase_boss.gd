class_name EnemyStateChaseBoss extends EnemyStateChase

@export var attack1: EnemyStateAttack
@export var attack2: EnemyStateAttack


#ranges for different attacks
@export var attack_range: float = 50.0        
@export var attack1_range: float = 80.0       
@export var attack2_range: float = 120.0      

#attack2 only is used in 50% thresholds
@export var attack2_rush_speed_multiplier: float = 2.0
@export var attack2_hp_threshold: float = 0.5  

var distance_to_player: float
var selected_attack: EnemyState = null
var original_chase_speed: float

func initialize() -> void:
	if vision_area:
		vision_area.player_entered.connect(_on_player_entered)
		vision_area.player_exited.connect(_on_player_exited)
	
	#store original chase speed for attack2 rush
	original_chase_speed = chase_speed
	pass

func enter() -> void:
	_can_see_player = true
	_timer = state_aggro_duration
	_attack_cooldown_timer = attack_cooldown_duration
	var new_anim_name: String = anim_name + "_" + enemy.anim_direction()
	enemy.update_animation(new_anim_name)
	
	#reset attack selection and chase speed when entering chase
	selected_attack = null
	chase_speed = original_chase_speed
	
	if attack_area:
		attack_area.monitoring = true
	pass
	
func exit() -> void:
	if attack_area:
		attack_area.monitoring = false
	_can_see_player = false
	_has_line_of_sight = false
	
	#reset attack selection and chase speed when exiting
	selected_attack = null
	chase_speed = original_chase_speed
	pass
	
func process(_delta: float) -> EnemyState:
	if PlayerManager.player.hp <= 0:
		return next_state
	
	if _attack_cooldown_timer > 0:
		_attack_cooldown_timer -= _delta
	
	if not PlayerManager.player:
		return next_state
	
	distance_to_player = enemy.global_position.distance_to(PlayerManager.player.global_position)	
	var new_direction: Vector2 = enemy.global_position.direction_to(PlayerManager.player.global_position)

	var can_actively_chase: bool = _can_see_player 
	
	if can_actively_chase:
		# Step 1: Choose attack state if we haven't already
		if selected_attack == null:
			selected_attack = _select_available_attack()
			
			# If attack2 is selected, immediately rush the player
			if selected_attack == attack2:
				chase_speed = original_chase_speed * attack2_rush_speed_multiplier
		
		# Step 2: Check if we're in range for the selected attack
		var required_range = _get_attack_range(selected_attack)
		
		if distance_to_player <= required_range:
			#in range for selected attack, face player and enter the selected attack state
			_direction = lerp(_direction, new_direction, turn_rate)
			if enemy.set_direction(_direction):
				enemy.update_animation(anim_name + "_" + enemy.anim_direction())
				enemy.weapon_position.update_position(enemy.anim_direction())
				
			if _attack_cooldown_timer <= 0:
				return selected_attack
		else:
			#not in range, move closer to get in range for selected attack
			_direction = lerp(_direction, new_direction, turn_rate)
			if enemy.set_direction(_direction):
				enemy.update_animation(anim_name + "_" + enemy.anim_direction())
				enemy.weapon_position.update_position(enemy.anim_direction())
			
			enemy.velocity = _direction * chase_speed
			 #reset timer when actively chasing
			_timer = state_aggro_duration 
	else:
		# cannot actively chase (either out of vision cone OR blocked by obstacle)
		_timer -= _delta
		if _timer <= 0:
			return next_state
	
	return null

func _select_available_attack() -> EnemyState:
	var current_hp_percentage = float(enemy.hp) / float(enemy.max_hp) if enemy.max_hp > 0 else 1.0
	var random_chance = randi_range(1, 100)
	
	if current_hp_percentage > attack2_hp_threshold:
		#above 50% HP: 70% attack state, 30% attack1 state
		if random_chance <= 60:
			return attack
		else:
			return attack1
	else:
		#below 50% HP: 50% attack, 30% attack1, 20% attack2
		if random_chance <= 40:
			return attack
		elif random_chance <= 70: 
			return attack1
		else:
			return attack2

#function to get attack range, the first attack state has a chance of varying its range 
func _get_attack_range(attack_state: EnemyState) -> float:
	if attack_state == attack:
		return attack_range * randf_range(1.0, 1.5)
	elif attack_state == attack1:
		return attack1_range
	elif attack_state == attack2:
		return attack2_range
	else:
		return attack_range 

func physics(_delta: float) -> EnemyState:
	return null

func check_line_of_sight(_direction_to_player: Vector2) -> void:
	if not enemy.ray_cast_2d:
		_has_line_of_sight = false
		return
	
	distance_to_player = enemy.global_position.distance_to(PlayerManager.player.global_position)
	enemy.ray_cast_2d.target_position = _direction_to_player * clamp(distance_to_player, 0.0, enemy.raycast_length)
	enemy.ray_cast_2d.force_raycast_update()
	
	_has_line_of_sight = !enemy.ray_cast_2d.is_colliding()

func _on_player_entered():
	_can_see_player = true
	if state_machine.current_state is EnemyStateStun || state_machine.current_state is EnemyStateDestroy:
		return
	state_machine.change_state(self)
	pass

func _on_player_exited():
	_can_see_player = false
	pass

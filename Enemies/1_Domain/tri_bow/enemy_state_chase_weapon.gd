class_name EnemyStateChaseWeapon extends EnemyStateChase


var distance_to_player:float

func initialize() -> void:
	if vision_area:
		vision_area.player_entered.connect(_on_player_entered)
		vision_area.player_exited.connect(_on_player_exited)
	pass

func enter() -> void:
	_can_see_player = true
	_timer = state_aggro_duration
	_attack_cooldown_timer = attack_cooldown_duration
	var new_anim_name: String = anim_name + "_" + enemy.anim_direction()
	enemy.update_animation(new_anim_name)
	
	if attack_area:
		attack_area.monitoring = true
	pass
	
func exit() -> void:
	if attack_area:
		attack_area.monitoring = false
	_can_see_player = false
	_has_line_of_sight = false
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
	
	check_line_of_sight(new_direction)
	var can_actively_chase: bool = _can_see_player && _has_line_of_sight
	
	if can_actively_chase:
		# Can see player - check if in attack range first
		if distance_to_player <= enemy.range:
			# In range - set enemy to face player then attack
			_direction = lerp(_direction, new_direction, turn_rate)
			if enemy.set_direction(_direction):
				enemy.update_animation(anim_name + "_" + enemy.anim_direction())
				enemy.weapon_position.update_position(enemy.anim_direction())
				
			if _attack_cooldown_timer <= 0:
				return attack
		else:
			# Not in range - move closer
			_direction = lerp(_direction, new_direction, turn_rate)
			if enemy.set_direction(_direction):
				enemy.update_animation(anim_name + "_" + enemy.anim_direction())
				enemy.weapon_position.update_position(enemy.anim_direction())
			enemy.velocity = _direction * chase_speed
			_timer = state_aggro_duration  # Reset timer when actively chasing
	else:
		# Cannot actively chase (either out of vision cone OR blocked by obstacle)
		_timer -= _delta
		if _timer <= 0:
			return next_state
	
	return null
	
func physics(_delta: float) -> EnemyState:
	return null

func check_line_of_sight(_direction_to_player: Vector2) -> void:
	if not enemy.ray_cast_2d:
		_has_line_of_sight = false
		return
	
	var distance_to_player = enemy.global_position.distance_to(PlayerManager.player.global_position)
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

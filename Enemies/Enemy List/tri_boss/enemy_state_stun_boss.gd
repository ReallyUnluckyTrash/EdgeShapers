class_name EnemyStateStunBoss extends EnemyStateStun

@export var next_state1 : EnemyState
@export var hp_threshold:float = 0.5

func process(_delta : float) -> EnemyState:
	if _animation_finished == true:
		var current_hp_percentage = float(enemy.hp) / float(enemy.max_hp) if enemy.max_hp > 0 else 1.0
		if current_hp_percentage <= hp_threshold:
			if randi_range(1, 10) > 5:
				return next_state1
			else:
				return next_state
			pass
		else: 
			return next_state
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta
	return null

#enemy boss does not get stunned while attacking, and also takes half damage 
func _on_enemy_damaged(attack:Attack) -> void:
	_attack = attack
	if state_machine.current_state is EnemyStateAttack:
		enemy.hp += floor(attack.damage/2)
		return
	else:
		state_machine.change_state(self)
	pass

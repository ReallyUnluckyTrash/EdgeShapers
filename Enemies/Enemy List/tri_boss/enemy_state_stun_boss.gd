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

class_name EnemyStateStun extends EnemyState

@export var anim_name: String = "stun"
@export var knockback_speed: float = 200.0
@export var decelerate_speed: float = 10.0

@export var next_state : EnemyState

var _direction: Vector2
var _animation_finished: bool = false

func initialize() -> void:
	enemy.enemy_damaged.connect( _on_enemy_damaged)
	pass

func enter() -> void:
	enemy.invulnerable = true
	_animation_finished = false
	
	_direction = enemy.global_position.direction_to(enemy.player.global_position)
	
	enemy.set_direction(_direction)
	enemy.velocity = _direction * -knockback_speed
	
	enemy.update_animation(anim_name)
	enemy.animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	pass
	
func exit() -> void:
	enemy.invulnerable = false
	enemy.animated_sprite_2d.animation_finished.disconnect(_on_animation_finished)
	pass
	
func process(_delta : float) -> EnemyState:
	if _animation_finished == true:
		return next_state
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta
	return null
	
func physics(_delta : float) -> EnemyState:
	return null

func _on_enemy_damaged() -> void:
	state_machine.change_state(self)
	pass

func _on_animation_finished():
	_animation_finished = true
	


#func _on_tri_slime_enemy_damaged() -> void:
	#state_machine.change_state(self)
	#pass # Replace with function body.

class_name EnemyStateStun extends EnemyState

@export var anim_name: String = "stun"
@export var decelerate_speed: float = 10.0

@export var next_state : EnemyState

var _direction: Vector2
var _animation_finished: bool = false

var _attack:Attack

func initialize() -> void:
	enemy.enemy_damaged.connect( _on_enemy_damaged)
	pass

func enter() -> void:
	enemy.invulnerable = true
	_animation_finished = false
	
	if _attack:
		_direction = _attack.attack_position.direction_to(enemy.global_position)
		enemy.set_direction(_direction)
		enemy.velocity = _direction * _attack.knockback_force
	
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

func _on_enemy_damaged(attack:Attack) -> void:
	_attack = attack
	state_machine.change_state(self)
	pass

func _on_animation_finished():
	_animation_finished = true
	

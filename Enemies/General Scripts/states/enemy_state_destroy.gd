class_name EnemyStateDestroy extends EnemyState

@export var anim_name: String = "stun"

@export var decelerate_speed: float = 10.0

var _direction: Vector2
var _attack: Attack

func initialize() -> void:
	enemy.enemy_destroyed.connect( _on_enemy_destroyed)
	pass

func enter() -> void:
	enemy.invulnerable = true
	
	if _attack:
		_direction = _attack.attack_position.direction_to(enemy.global_position)
		enemy.set_direction(_direction)
		enemy.velocity = _direction * _attack.knockback_force
	
	enemy.update_animation(anim_name)
	
	enemy.destroy_animation()
	
	enemy.destroy_animation_player.animation_finished.connect(_on_animation_finished)
	pass
	
func exit() -> void:
	pass
	
func process(_delta : float) -> EnemyState:
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta
	return null
	
func physics(_delta : float) -> EnemyState:
	return null

func _on_enemy_destroyed(attack:Attack) -> void:
	_attack = attack
	state_machine.change_state(self)
	pass

func _on_animation_finished(_a : String)->void:
	PlayerManager.vertex_points += enemy.enemy_vp_drop
	PlayerHud.update_currency_label(PlayerManager.vertex_points)
	enemy.queue_free()
	pass

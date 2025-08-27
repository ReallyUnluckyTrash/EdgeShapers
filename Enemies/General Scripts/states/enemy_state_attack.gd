class_name EnemyStateAttack extends EnemyState

@onready var idle : EnemyStateIdle = $"../Idle"
@onready var chase: EnemyStateChase = $"../Chase"

@export_range(1, 20, 0.5) var decelerate_speed: float = 5.0

var attacking: bool = false

func enter() -> void:
	attacking = true
	
	if enemy.weapon:
		if enemy.weapon is SlashWeapon:
			enemy.weapon_position.position = Vector2.ZERO
		
		enemy.weapon.attack()
		enemy.weapon.attack_finished.connect(end_attack)
	pass
	
func exit() -> void:
	attacking = false
	
	if enemy.weapon and enemy.weapon.has_signal("attack_finished"):
		if enemy.weapon.attack_finished.is_connected(end_attack):
			enemy.weapon.attack_finished.disconnect(end_attack)
	
	if enemy.weapon and enemy.weapon.has_method("return_to_idle"):
		enemy.weapon.return_to_idle()
	
	if enemy.weapon is SlashWeapon:
		enemy.weapon_position.update_position(enemy.anim_direction())
		pass
	pass
	
func process(_delta : float) -> EnemyState:
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta
	
	if attacking == false:
		return chase
	return null
	
func physics(_delta : float) -> EnemyState:
	return null
	
func handle_input(_event: InputEvent) -> EnemyState:
	return null

func end_attack() -> void:
	attacking = false

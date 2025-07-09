class_name Attack 

var damage: int
var knockback_force: float
var attack_position: Vector2

func _init(attack_damage: int, force: float, position: Vector2):
	damage = attack_damage
	knockback_force = force
	attack_position = position

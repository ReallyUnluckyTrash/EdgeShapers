class_name HurtBox extends Area2D

@export var damage : int = 1
@export var knockback_force: float = 200.0

func _ready():
	area_entered.connect(hurtbox_entered)
	pass
	
func hurtbox_entered(area : Area2D):
	if area is HitBox:
		var attack = Attack.new(damage, knockback_force, global_position)
		area.take_damage(attack)
	pass

class_name HurtBox extends Area2D

@export var damage : int = 1

func _ready():
	area_entered.connect(hurtbox_entered)
	pass
	
func hurtbox_entered(area : Area2D):
	if area is HitBox:
		area.take_damage(damage)
	pass

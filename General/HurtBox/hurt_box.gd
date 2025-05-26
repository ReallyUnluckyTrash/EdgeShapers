class_name HurtBox extends Area2D

@export var damage : int = 1

func _ready():
	area_entered.connect(AreaEntered)
	pass
	
func AreaEntered(area : Area2D):
	if area is HitBox:
		area.TakeDamage(damage)
	pass

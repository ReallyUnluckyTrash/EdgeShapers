class_name HitBox extends Area2D

signal damaged( damage: int)

func take_damage( damage:int ) -> void:
	print("take_damage : ", damage)
	damaged.emit(damage)
	
	
	

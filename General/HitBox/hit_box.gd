class_name HitBox extends Area2D

signal damaged(attack:Attack )

func take_damage( attack:Attack) -> void:
	damaged.emit(attack)
	
	
	

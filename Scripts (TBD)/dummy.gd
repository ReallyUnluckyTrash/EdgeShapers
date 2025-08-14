extends Node2D

func _ready():
	$HitBox.damaged.connect(take_damage)
	pass

func take_damage(_damage:int) -> void:
	pass

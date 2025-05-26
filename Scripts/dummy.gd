extends Node2D

func _ready():
	$HitBox.Damaged.connect(takeDamage)
	pass

func takeDamage(_damage:int) -> void:
	pass

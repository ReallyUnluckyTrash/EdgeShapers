class_name Trap extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	area_2d.area_entered.connect(_on_area_entered)
	pass
	
func _on_area_entered(area : Area2D)->void:
	animation_player.play("activate")
	pass

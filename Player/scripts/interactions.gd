class_name PlayerInteractionHost extends Node2D

@onready var player: Player = $".."

@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	player.direction_change.connect(update_direction)
	interaction_area.area_entered.connect(_on_area_entered)
	interaction_area.area_exited.connect(_on_area_exited)
	pass
	
func _on_area_entered(area:Area2D):
	if area.collision_layer == 3:
		PlayerHud.show_interact_hint()
	pass

func _on_area_exited(area:Area2D):
	if area.collision_layer == 3:
		PlayerHud.hide_interact_hint()
	pass

func update_direction(new_direction : Vector2) -> void:
	match new_direction:
		Vector2.DOWN:
			rotation_degrees = 180
		Vector2.UP:
			rotation_degrees = 0
		Vector2.RIGHT:
			rotation_degrees = 90
		Vector2.LEFT:
			rotation_degrees = -90
		_:
			rotation_degrees = 0
		
	pass

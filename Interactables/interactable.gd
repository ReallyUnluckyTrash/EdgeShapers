class_name Interactable extends Node2D

func _on_player_interact()->void:
	pass

func _on_area_entered(_area:Area2D):
	PlayerManager.interact_pressed.connect(_on_player_interact)
	PlayerHud.show_interact_hint()
	pass

func _on_area_exited(_area:Area2D):
	PlayerManager.interact_pressed.disconnect(_on_player_interact)
	PlayerHud.hide_interact_hint()
	pass
	

extends Node2D

@export_file("*.tscn") var hub_area_path

func _on_new_game_pressed() -> void:
	LevelManager.load_new_level(hub_area_path, "none", Vector2.ZERO)
	pass # Replace with function body.

extends Node2D

@export_file("*.tscn") var hub_area_path
@onready var new_game: Button = $"CanvasLayer/VBoxContainer/New Game"

func _ready() -> void:
	PlayerHud.visible = false
	new_game.grab_focus()
	PlayerManager.pause_menu_disabled = true
	

func _on_new_game_pressed() -> void:
	PlayerHud.visible = true
	LevelManager.load_new_level(hub_area_path, "", Vector2(0, 0))
	PlayerManager.pause_menu_disabled = false
	LevelManager.reset_tilemap_bounds()
	
	await get_tree().process_frame
	PlayerManager.reset_player()
	pass # Replace with function body.

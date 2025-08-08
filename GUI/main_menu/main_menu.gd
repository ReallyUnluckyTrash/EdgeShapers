extends Node2D

@export_file("*.tscn") var hub_area_path
@onready var new_game: Button = $"CanvasLayer/VBoxContainer/New Game"

func _ready() -> void:
	PlayerHud.visible = false
	new_game.grab_focus()
	PlayerManager.pause_menu_disabled = true
	if !PlayerManager.player:
		PlayerManager.add_player_instance()

func _on_new_game_pressed() -> void:
	PlayerHud.visible = true
	LevelManager.load_new_level(hub_area_path, "StartTile", Vector2(96, 352))
	PlayerManager.pause_menu_disabled = false
	pass # Replace with function body.

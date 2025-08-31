extends Node2D

@export_file("*.tscn") var hub_area_path
@onready var new_game: Button = $"CanvasLayer/VBoxContainer/New Game"
@onready var guide_menu: Control = %GuideMenu
@onready var close_button: Button = %CloseButton
@onready var guide: Button = $CanvasLayer/VBoxContainer/Guide

@export var title_screen_bgm:AudioStream

func _ready() -> void:
	PlayerHud.visible = false
	guide_menu.visible = false
	new_game.grab_focus()
	PlayerManager.pause_menu_disabled = true
	LevelManager.level_load_started.connect(_free_level)
	AudioManager.play_music(title_screen_bgm)


func _on_new_game_pressed() -> void:
	PlayerHud.visible = true
	LevelManager.load_new_level(hub_area_path, "", Vector2(0, 0))
	PlayerManager.pause_menu_disabled = false
	LevelManager.reset_tilemap_bounds()
	
	await get_tree().process_frame
	PlayerManager.reset_player()
	pass # Replace with function body.

func _free_level()->void:
	PlayerManager.unparent_player(self)
	queue_free()


func _on_guide_pressed() -> void:
	guide_menu.visible = true
	close_button.visible = true
	close_button.grab_focus()
	pass # Replace with function body.


func _on_close_button_pressed() -> void:
	guide_menu.visible = false
	close_button.visible = false
	guide.grab_focus()
	pass # Replace with function body.

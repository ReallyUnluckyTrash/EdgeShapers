class_name ShopStatue extends Node2D

@onready var player_monitor: Area2D = $PlayerMonitor

func _ready() -> void:
	player_monitor.area_entered.connect(_on_area_entered)
	player_monitor.area_exited.connect(_on_area_exited)
	pass


func _on_player_interact()->void:
	ShopMenu.show_menu()
	#UpgradeChoiceMenu.show_menu()
	
	pass

func _on_area_entered(_area:Area2D):
	PlayerManager.interact_pressed.connect(_on_player_interact)
	pass

func _on_area_exited(_area:Area2D):
	PlayerManager.interact_pressed.disconnect(_on_player_interact)
	pass
	

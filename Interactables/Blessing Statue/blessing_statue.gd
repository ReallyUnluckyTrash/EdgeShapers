class_name BlessingStatue extends Interactable

@onready var player_monitor: Area2D = $PlayerMonitor

var blessing_received:bool = false


func _ready() -> void:
	player_monitor.area_entered.connect(_on_area_entered)
	player_monitor.area_exited.connect(_on_area_exited)
	pass


func _on_player_interact()->void:
	if blessing_received == false:
		UpgradeChoiceMenu.show_menu()
		blessing_received = true
		PlayerHud.hide_interact_hint()
	
	pass

func _on_area_entered(_area:Area2D):
	PlayerManager.interact_pressed.connect(_on_player_interact)
	if blessing_received == false:
		PlayerHud.show_interact_hint()
	pass

func _on_area_exited(_area:Area2D):
	PlayerManager.interact_pressed.disconnect(_on_player_interact)
	if blessing_received == false:
		PlayerHud.hide_interact_hint()
	pass
	

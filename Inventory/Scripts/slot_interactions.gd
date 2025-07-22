class_name SlotInteractions extends Control

@onready var equip_button: Button = %EquipButton
@onready var use_button: Button = %UseButton
#@onready var color_rect: ColorRect = $ColorRect

signal equip_pressed
signal use_pressed

func _on_equip_button_pressed() -> void:
	equip_pressed.emit()
	PauseMenu.inventory_blocker.visible = false
	PauseMenu.default_grab_focus()
	queue_free()
	
	pass # Replace with function body.


func _on_use_button_pressed() -> void:
	use_pressed.emit()
	PauseMenu.inventory_blocker.visible = false
	PauseMenu.default_grab_focus()
	queue_free()
	pass # Replace with function body.

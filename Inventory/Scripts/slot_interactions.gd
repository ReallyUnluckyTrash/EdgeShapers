class_name SlotInteractions extends Control

@onready var equip_button: Button = %EquipButton
@onready var use_button: Button = %UseButton
#@onready var color_rect: ColorRect = $ColorRect

const EQUIP = preload("res://General/Sound Effects/equip.mp3")
const USE_ITEM = preload("res://General/Sound Effects/use_item.wav")

signal equip_pressed
signal use_pressed

func _on_equip_button_pressed() -> void:
	equip_pressed.emit()
	PauseMenu.inventory_blocker.visible = false
	PauseMenu.default_grab_focus()
	PauseMenu.play_audio(EQUIP)
	queue_free()
	
	pass # Replace with function body.


func _on_use_button_pressed() -> void:
	use_pressed.emit()
	PauseMenu.inventory_blocker.visible = false
	PauseMenu.default_grab_focus()
	PauseMenu.play_audio(USE_ITEM)
	queue_free()
	pass # Replace with function body.

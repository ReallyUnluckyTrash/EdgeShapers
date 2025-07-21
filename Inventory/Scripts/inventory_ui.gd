class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("res://Inventory/Scenes/inventory_slot.tscn")

@export var data: InventoryData

func _ready() -> void:
	PauseMenu.shown.connect(update_inventory)
	PauseMenu.hidden.connect(clear_inventory)
	clear_inventory()
	data.connect_slots_signal()
	data.update_ui.connect(on_inventory_changed)
	pass

func clear_inventory() -> void:
	for child in get_children():
		child.queue_free()
		

func update_inventory()->void:
	for slot in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = slot
	
	#get_child(0).grab_focus()

func on_inventory_changed()->void:
	clear_inventory()
	update_inventory()
	pass

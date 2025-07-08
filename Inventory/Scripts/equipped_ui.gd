class_name EquippedUI extends Control

const EQUIPPED_SLOT = preload("res://Inventory/equipped_slot.tscn")

@export var equipped_data: InventoryData

func _ready() -> void:
	PlayerManager.weapon_equipped.connect(update_equipped)
	PauseMenu.hidden.connect(clear_equipped)
	pass

func update_equipped(item_data:ItemData):
	clear_equipped()
	if(item_data.type == "Weapon"):
		equipped_data.slots[0].item_data = item_data
		print(item_data)
	
	for slot in equipped_data.slots:
		var new_slot = EQUIPPED_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = slot
	pass
	
func clear_equipped()->void:
	for child in get_children():
		child.queue_free()
	pass

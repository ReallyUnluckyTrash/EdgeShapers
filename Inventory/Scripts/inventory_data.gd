class_name InventoryData extends Resource

@export var slots: Array[SlotData]

func add_item(item_data:ItemData, quantity:int):
	var new_slot = SlotData.new()
	new_slot.item_data = item_data
	new_slot.quantity = quantity
	print(new_slot)
	slots.append(new_slot)
	pass

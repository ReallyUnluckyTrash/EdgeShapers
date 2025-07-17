class_name InventoryData extends Resource

@export var slots: Array[SlotData]

func add_item(item_data:ItemData, quantity:int):
	
	#check if the item already exists, and is not a weapon
	if try_stack_item(item_data, quantity):
		return
	
	var new_slot = SlotData.new()
	new_slot.item_data = item_data
	new_slot.quantity = quantity
	print(new_slot)
	slots.append(new_slot)
	pass

#function to remove item in a specific index
func remove_item_index(slot_index:int)->void:
	if slot_index >= 0 and slot_index < slots.size():
		slots.remove_at(slot_index)
	pass

#function that checks if the same type of item already exists
func has_item_(item_data:ItemData)->bool:
	for slot in slots:
		if slot.item_data == item_data:
			return true
	return false

#function that checks if item already exists, and returns the slot 
func find_item_slot(item_data:ItemData) -> SlotData:
	for slot in slots:
		if slot.item_data == item_data:
			return slot
	return null

#func to check item quantity
func get_item_quantity(item_data:ItemData) -> int:
	var slot = find_item_slot(item_data)
	if slot:
		return slot.quantity
	return 0

func try_stack_item(item_data:ItemData, quantity:int)->bool:
	#if the item is a weapon, return false as weapons cannot be stacked
	if item_data.type == "Weapon":
		return false
	
	#find item slot with the inputted item, and increase the quantity accordingly
	var existing_slot = find_item_slot(item_data)
	if existing_slot:
		existing_slot.quantity += quantity
		return true

	return false

class_name EquippedUI extends Control

const EQUIPPED_SLOT = preload("res://Inventory/Scenes/equipped_slot.tscn")
@export var equipped_data: InventoryData

func _ready() -> void:
	PlayerManager.weapon_equipped.connect(on_weapon_equipped)
	PlayerManager.item_equipped.connect(on_item_equipped)
	PauseMenu.hidden.connect(clear_equipped)
	PauseMenu.shown.connect(show_equipped)
	pass

func on_weapon_equipped(item_data:ItemData):
	clear_equipped()
	if(item_data.type == "Weapon"):
		equipped_data.slots[0].item_data = item_data
	
	show_equipped()
	pass

func on_item_equipped(item_data:ItemData, quantity:int):
	clear_equipped()
	if(item_data.type == "Item"):
		equipped_data.slots[1].item_data = item_data
		equipped_data.slots[1].quantity = quantity
		print("equipped item: " + equipped_data.slots[1].item_data.name + " count of: " + str(equipped_data.slots[1].quantity))
	show_equipped()
	pass


func show_equipped()->void:
	for slot in equipped_data.slots:
		var new_slot = EQUIPPED_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = slot
	
func clear_equipped()->void:
	for child in get_children():
		child.queue_free()
	pass

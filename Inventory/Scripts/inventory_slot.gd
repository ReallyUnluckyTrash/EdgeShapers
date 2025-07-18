class_name InventorySlot extends Button

var slot_data: SlotData : set = set_slot_data

@onready var texture_rect: TextureRect = $TextureRect
@onready var quantity: Label = $Quantity

@onready var interactions: Control = $Interactions

func _ready() -> void:
	texture_rect.texture = null
	quantity.text = ""
	interactions.visible = false
	focus_entered.connect(item_focused)
	focus_exited.connect(item_unfocused)
	
func set_slot_data(value : SlotData) ->void:
	slot_data = value
	if slot_data == null:
		return
	texture_rect.texture = slot_data.item_data.texture
	quantity.text = str(slot_data.quantity)

func _on_pressed() -> void:
	if slot_data == null:
		return
	if slot_data.item_data.type == "Weapon":
		PlayerManager.set_equipped_weapon(slot_data.item_data.scene, slot_data.item_data)
	elif slot_data.item_data.type == "Item":
		print("tried to use item: " + slot_data.item_data.name)
		var was_used = slot_data.item_data.use()
		
		if was_used == false:
			return 
		
		slot_data.quantity -= 1
		quantity.text = str(slot_data.quantity)
		
			
	pass # Replace with function body.

func item_focused():
	if slot_data != null:
		if slot_data.item_data != null:
			PauseMenu.update_item_description(slot_data.item_data.description)
	pass

func item_unfocused():
	PauseMenu.update_item_description("")
	pass

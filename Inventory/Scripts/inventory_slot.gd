class_name InventorySlot extends Button

var slot_data: SlotData : set = set_slot_data

@onready var texture_rect: TextureRect = $TextureRect
@onready var quantity: Label = $Quantity

@onready var interactions: Control = $Interactions

signal item_depleted()

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
	
	if interactions.visible == true:
		interactions.visible = false
	elif interactions.visible == false:
		interactions.visible = true
	
	#if slot_data.item_data.type == "Weapon":
		#PlayerManager.set_equipped_weapon(slot_data.item_data.scene, slot_data.item_data)
	#elif slot_data.item_data.type == "Item":
		#print("tried to use item: " + slot_data.item_data.name)
		#var was_used = slot_data.item_data.use()
		#
		#if was_used == false:
			#return 
			#
		#slot_data.quantity -= 1
		#if slot_data.quantity > 0:
			#quantity.text = str(slot_data.quantity)
			#print(slot_data.item_data.name + " count: " + str(slot_data.quantity) )
			
	pass # Replace with function body.

func item_focused():
	if slot_data != null:
		if slot_data.item_data != null:
			PauseMenu.update_item_description(slot_data.item_data.description)
	pass

func item_unfocused():
	PauseMenu.update_item_description("")
	pass


func _on_equip_button_pressed() -> void:
	print("trying to equip!")
	if slot_data.item_data.type == "Weapon":
		PlayerManager.set_equipped_weapon(slot_data.item_data.scene, slot_data.item_data)
		
	if slot_data.item_data.type == "Item":
		if PlayerManager.equipped_item.item_data == slot_data.item_data:
			print("Item already equipped!")
			return
		
		
		var quantity_to_be_equipped:int = 3
		
		if slot_data.quantity < quantity_to_be_equipped:
			quantity_to_be_equipped = slot_data.quantity
		
		slot_data.quantity -= quantity_to_be_equipped
		
		if slot_data.quantity > 0:
			quantity.text = str(slot_data.quantity)
		
		PlayerManager.set_equipped_item(slot_data.item_data, quantity_to_be_equipped)
		pass
	pass # Replace with function body.


func _on_use_button_pressed() -> void:
	if slot_data.item_data.type == "Item":
		print("tried to use item: " + slot_data.item_data.name)
		var was_used = slot_data.item_data.use()
		
		if was_used == false:
			return 
			
		slot_data.quantity -= 1
		if slot_data.quantity > 0:
			quantity.text = str(slot_data.quantity)
			print(slot_data.item_data.name + " count: " + str(slot_data.quantity))
	else:
		print("not a usable item!")
	pass # Replace with function body.

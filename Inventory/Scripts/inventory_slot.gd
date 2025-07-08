class_name InventorySlot extends Button

var slot_data: SlotData : set = set_slot_data

@onready var texture_rect: TextureRect = $TextureRect
@onready var quantity: Label = $Quantity

@onready var interactions: VBoxContainer = $Interactions


func _ready() -> void:
	texture_rect.texture = null
	quantity.text = ""
	interactions.visible = false
	
func set_slot_data(value : SlotData) ->void:
	slot_data = value
	if slot_data == null:
		return
	texture_rect.texture = slot_data.item_data.texture
	quantity.text = str(slot_data.quantity)


func _on_pressed() -> void:
	if slot_data == null:
		return
	PlayerManager.set_equipped_weapon(slot_data.item_data.scene)
	pass # Replace with function body.

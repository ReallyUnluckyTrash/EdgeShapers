class_name EquippedSlot extends Control

var slot_data: SlotData : set = set_slot_data
@onready var texture_rect: TextureRect = $TextureRect
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	texture_rect.texture = null
	# Update texture if slot_data was set before _ready()
	color_rect.visible = false
	if slot_data != null:
		update_texture()
	
func set_slot_data(value : SlotData) -> void:
	slot_data = value
	update_texture()

func update_texture() -> void:
	if not texture_rect:
		return  # texture_rect not ready yet
	
	if slot_data == null or slot_data.item_data == null:
		texture_rect.texture = null
		return
		
	color_rect.visible = true
	texture_rect.texture = slot_data.item_data.texture

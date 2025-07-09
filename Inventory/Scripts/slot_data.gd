class_name SlotData extends Resource

@export var item_data:ItemData
@export var quantity: int = 0

#func _init(_item_data:ItemData, _quantity:int) -> void:
	#item_data = _item_data
	#quantity = _quantity
	#pass

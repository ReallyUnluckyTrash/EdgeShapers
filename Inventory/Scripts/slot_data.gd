class_name SlotData extends Resource

@export var item_data:ItemData
@export var quantity: int = 0 : set = set_quantity

signal item_depleted(item:ItemData)

func set_quantity(value:int)->void:
	quantity = value
	if quantity < 1:
		print("item depleted")
		item_depleted.emit(item_data)
	pass

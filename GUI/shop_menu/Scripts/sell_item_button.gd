class_name SellItemButton extends Button

var item:ItemData
@onready var name_label: Label = %NameLabel
@onready var texture_rect: TextureRect = %TextureRect
@onready var price_label: Label = %PriceLabel
@onready var quantity_label: Label = %QuantityLabel


func setup_item(_item:ItemData, _quantity:int) ->void:
	item = _item
	name_label.text = item.name
	texture_rect.texture = item.texture
	price_label.text = "Sell:" + str(item.price)
	quantity_label.text = "Qt:" + str(_quantity)
	pass

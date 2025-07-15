class_name ShopItemButton extends Button

var item:ItemData
@onready var name_label: Label = $NameLabel
@onready var texture_rect: TextureRect = $TextureRect
@onready var price_label: Label = $PriceLabel


func setup_item(_item:ItemData) ->void:
	item = _item
	name_label.text = item.name
	texture_rect.texture = item.texture
	price_label.text = str(item.price)
	pass

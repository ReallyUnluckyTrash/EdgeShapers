extends CanvasLayer

@onready var health_bar: TextureProgressBar = %HealthBar
@onready var edge_power_bar: TextureProgressBar = %EdgePowerBar
@onready var currency_label: Label = %CurrencyLabel
@onready var equipped_item_texture: TextureRect = %EquippedItemTexture


func _ready() -> void:
	PlayerHud.update_equipped_texture(PlayerManager.INVENTORY_WEAPON_DATA.slots[0].item_data.texture)
	pass

func update_hp(_hp:int, _max_hp:int) -> void:
	health_bar.max_value = _max_hp
	health_bar.value = _hp
	pass

func update_ep(_ep:int, _max_ep:int) -> void:
	edge_power_bar.max_value = _max_ep
	edge_power_bar.value = _ep
	pass

func update_equipped_texture(_new_texture)->void:
	equipped_item_texture.texture = _new_texture
	pass

func update_currency_label(_currency:int)->void:
	currency_label.text = str(_currency)
	pass

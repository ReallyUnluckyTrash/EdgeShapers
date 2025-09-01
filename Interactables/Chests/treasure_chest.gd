@tool
class_name TreasureChest
extends Interactable

@export var item_data:ItemData: set = _set_item_data
@export var quantity: int = 1:set = _set_quantity

var is_opened:bool = false

@onready var chest_sprite: Sprite2D = $ChestSprite
@onready var label: Label = $ItemSprite/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_monitor: Area2D = $PlayerMonitor
@onready var item_sprite: Sprite2D = $ItemSprite


func _ready() -> void:
	update_label()
	update_texture()
	if Engine.is_editor_hint():
		return
	player_monitor.area_entered.connect(_on_area_entered)
	player_monitor.area_exited.connect(_on_area_exited)
	pass


func _set_item_data(value: ItemData)->void:
	item_data = value
	update_texture()
	pass

func _set_quantity(value:int)->void:
	quantity = value
	update_label()
	pass
	
func _on_player_interact():
	if is_opened == true:
		return
	is_opened = true
	animation_player.play("opened_chest")
	PlayerHud.hide_interact_hint()
	
	if item_data and quantity > 0:
		if item_data.type == "Weapon":
			if PlayerManager.INVENTORY_WEAPON_DATA.has_item_(item_data):
				print("Weapon already owned, automatically sold!")
				PlayerManager.vertex_points += item_data.price
				PlayerHud.update_currency_label(PlayerManager.vertex_points)
				return
			PlayerManager.INVENTORY_WEAPON_DATA.add_item(item_data, quantity)
			
		elif item_data.type == "Item":
			PlayerManager.INVENTORY_ITEM_DATA.add_item(item_data, quantity)
			pass
	
	else:
		push_error("No items present in chest! Chest Name: ", name)
	pass
	
func update_texture()->void:
	if item_data and item_sprite:
		item_sprite.texture = item_data.texture
	pass

func update_label()->void:
	if label:
		if quantity < 1:
			label.text = "x0"
		else:
			label.text = "x" + str(quantity)

func _on_area_entered(_area:Area2D):
	PlayerManager.interact_pressed.connect(_on_player_interact)
	if is_opened == false:
		PlayerHud.show_interact_hint()
	pass

func _on_area_exited(_area:Area2D):
	PlayerManager.interact_pressed.disconnect(_on_player_interact)
	if is_opened == false:
		PlayerHud.hide_interact_hint()
	pass
	

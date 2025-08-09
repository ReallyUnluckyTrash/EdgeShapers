extends CanvasLayer

@onready var health_bar: TextureProgressBar = %HealthBar
@onready var edge_power_bar: TextureProgressBar = %EdgePowerBar
@onready var currency_label: Label = %CurrencyLabel
@onready var equipped_item_texture: TextureRect = %EquippedItemTexture
@onready var equipped_item_quantity: Label = %EquippedItemQuantity
@onready var health_label: Label = %HealthLabel
@onready var edge_power_label: Label = %EdgePowerLabel
@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer
@onready var game_over: Control = $Control/GameOver
@onready var title_button: Button = $Control/GameOver/VBoxContainer/TitleButton

func _ready() -> void:
	update_currency_label(PlayerManager.vertex_points)
	hide_game_over_screen()
	LevelManager.level_load_started.connect(hide_game_over_screen)
	pass

func update_hp(_hp:int, _max_hp:int) -> void:
	health_bar.max_value = _max_hp
	health_bar.value = _hp
	health_label.text = str(_hp) + "/" + str(_max_hp)
	pass

func update_ep(_ep:int, _max_ep:int) -> void:
	edge_power_bar.max_value = _max_ep
	edge_power_bar.value = _ep
	edge_power_label.text = str(_ep) + "/" + str(_max_ep)
	pass

func update_equipped_texture(_new_texture)->void:
	equipped_item_texture.texture = _new_texture
	pass

func update_equipped_quantity(_new_quantity)->void:
	equipped_item_quantity.text = str(_new_quantity)

func update_currency_label(_currency:int)->void:
	currency_label.text = str(_currency)
	pass

func show_game_over_screen()->void:
	game_over.visible = true
	#game_over.mouse_filter = Control.MOUSE_FILTER_STOP
	animation_player.play("show_game_over")
	await animation_player.animation_finished
	title_button.grab_focus()
	pass

func hide_game_over_screen()->void:
	game_over.visible = false
	game_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over.modulate = Color(1,1,1,0)
	pass

func fade_to_black()->bool:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	return true

func _on_title_button_pressed() -> void:
	await fade_to_black()
	LevelManager.load_new_level("res://GUI/main_menu/main_menu.tscn", "", Vector2.ZERO)
	
	pass # Replace with function body.

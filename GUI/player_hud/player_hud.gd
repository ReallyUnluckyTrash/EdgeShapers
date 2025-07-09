extends CanvasLayer

@onready var health_bar = $Control/VBoxContainer/HealthBar

func _ready() -> void:
	pass

func update_hp(_hp:int, _max_hp:int) -> void:
	health_bar.max_value = _max_hp
	health_bar.value = _hp
	pass

	

class_name VolumeSlider extends HSlider

@export var bus_name:String

var bus_index:int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	value = AudioManager.get_bus_volume(bus_name)
	
func _on_value_changed(value:float)->void:
	AudioManager.set_bus_volume(bus_name, value)
	pass

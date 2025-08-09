class_name Level extends Node2D

func _ready() -> void:
	self.y_sort_enabled = true
	call_deferred("setup_player")
	LevelManager.level_load_started.connect(_free_level)

func _free_level()->void:
	PlayerManager.unparent_player(self)
	queue_free()
	
func setup_player():
	PlayerManager.set_as_parent(self)

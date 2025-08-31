class_name GreatArrow extends Arrow

func _ready() -> void:
	shot.emit()
	#hurt_box.area_entered.connect(_on_hurtbox_entered)
	#timer.timeout.connect(_on_timer_timeout)
	pass

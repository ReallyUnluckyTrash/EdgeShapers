class_name LightningHit extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
const LIGHTNING = preload("res://General/Sound Effects/lightning.wav")

signal queue_freed
func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	animation_player.play("spawn")
	PlayerManager.play_audio(LIGHTNING)

func _on_animation_finished(anim_name: String)->void:
	if anim_name == "spawn":
		queue_freed.emit()
		queue_free()

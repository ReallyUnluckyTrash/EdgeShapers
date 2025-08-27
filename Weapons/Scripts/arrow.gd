class_name Arrow extends Node2D

var direction: Vector2
var speed : float = 0

@export var acceleration:float = 500.0
@export var max_speed:float = 400.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurt_box: HurtBox = $HurtBox
@onready var timer: Timer = $Timer
@onready var ray_cast_2d: RayCast2D = $RayCast2D

signal shot
signal queue_freed

func _ready() -> void:
	shot.emit()
	hurt_box.area_entered.connect(_on_hurtbox_entered)
	#timer.timeout.connect(_on_timer_timeout)
	pass

func _physics_process(delta: float) -> void:
	speed += acceleration * delta
	var movement = direction * speed * delta
	position += movement
	
	if ray_cast_2d.is_colliding():
		speed = 0.0
		acceleration = 0.0
		animation_player.play("hit")

func setup_hurtbox(_damage:int, _knockback:float):
	hurt_box.damage = _damage
	hurt_box.knockback_force = _knockback

func setup_direction(new_direction : Vector2) -> void:
	match new_direction:
		Vector2.DOWN:
			rotation_degrees = 90
		Vector2.UP:
			rotation_degrees = -90
		Vector2.RIGHT:
			rotation_degrees = 0
		Vector2.LEFT:
			rotation_degrees = 180
		_:
			rotation_degrees = 0
	pass

func shoot(shoot_direction:Vector2)->void:
	direction = shoot_direction
	speed = max_speed

func _on_hurtbox_entered(area : Area2D)->void:
	if area is HitBox:
		speed = 0.0
		acceleration = 0.0
		hurt_box.set_deferred("monitoring", false)
		animation_player.play("hit")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		queue_freed.emit()
		print("arrow queue freed")
		queue_free()
	pass # Replace with function body.

func _on_timer_timeout() -> void:
	animation_player.play("hit")
	timer.timeout.disconnect(_on_timer_timeout)
	pass # Replace with function body.

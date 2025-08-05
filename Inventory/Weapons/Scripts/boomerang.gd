class_name Boomerang extends Node2D

enum BoomerangState {INACTIVE, THROW, RETURN}

var player:Player
var direction: Vector2
var speed : float = 0
var state:BoomerangState

@export var acceleration:float = 500.0
@export var max_speed:float = 400.0
var inherited_velocity: Vector2 = Vector2.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurt_box: HurtBox = $HurtBox


signal thrown
signal queue_freed

func _ready() -> void:
	visible = false
	state = BoomerangState.INACTIVE
	player = PlayerManager.player
	
func _physics_process(delta: float) -> void:
	if state == BoomerangState.THROW:
		speed -= acceleration * delta
		var movement = direction * speed * delta + inherited_velocity * delta
		position += movement
		thrown.emit()
		if speed <= 0:
			state = BoomerangState.RETURN
		pass
	elif state == BoomerangState.RETURN:
		direction = global_position.direction_to(player.global_position)
		speed += acceleration * delta
		position += direction * speed * delta
		if global_position.distance_to(player.global_position) <= 10:
			queue_free()
			queue_freed.emit()
		pass
	pass

func throw(throw_direction:Vector2)->void:
	direction = throw_direction
	speed = max_speed
	inherited_velocity = player.velocity
	state = BoomerangState.THROW
	animation_player.play("spin")
	visible = true
	pass

func setup_hitbox(_damage:int, _knockback:float):
	hurt_box.damage = _damage
	hurt_box.knockback_force = _knockback

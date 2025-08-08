class_name State_Stun extends State

@export var decelerate_speed: float = 10.0
@export var invulnerable_duration: float = 1.0

var _attack:Attack
var _direction:Vector2

var next_state:State = null


@onready var idle : State_Idle = $"../Idle"
@onready var death: State_Death = $"../Death"


func initialize():
	player.player_damaged.connect(_player_damaged)

func enter() -> void:
	player.animated_sprite_2d.stop()
	player.animated_sprite_2d.animation_finished.connect(_animation_finished)
	
	if _attack:
		_direction = _attack.attack_position.direction_to(player.global_position)
		player.set_direction(_direction)
		player.velocity = _direction * _attack.knockback_force
	
	player.update_animation("stun")
	player.make_invulnerable(invulnerable_duration)
	player.effect_animation_player.play("damaged")
	pass
	
func exit() -> void:
	next_state = null
	player.animated_sprite_2d.animation_finished.disconnect(_animation_finished)
	pass
	
func process(_delta : float) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	return next_state
	
func physics(_delta : float) -> State:
	return null
	
func handle_input(_event: InputEvent) -> State:
	return null

func _player_damaged(attack:Attack)->void:
	_attack = attack
	if state_machine.current_state != death:
		state_machine.change_state(self)
	pass

func _animation_finished()->void:
	next_state = idle
	if player.hp <=0:
		next_state = death
	pass

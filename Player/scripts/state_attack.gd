class_name State_Attack extends State

@onready var weapon_animation_player = $"../../WeaponPosition/Sword/AnimationPlayer"

@onready var idle : State_Idle = $"../Idle"
@onready var walk: State_Walk = $"../Walk"
@onready var slash_hurtbox = $"../../Interactions/HurtBox"

@export_range(1, 20, 0.5) var decelerate_speed: float = 5.0

var attacking: bool = false

func Enter() -> void:
	weapon_animation_player.play("sword_animations/sword_swing")
	weapon_animation_player.animation_finished.connect(EndAttack)
	attacking = true
	
	await get_tree().create_timer( 0.15).timeout
	slash_hurtbox.monitoring = true
	pass
	
func Exit() -> void:
	weapon_animation_player.animation_finished.disconnect(EndAttack)
	attacking = false
	slash_hurtbox.monitoring = false
	pass
	
func Process(_delta : float) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	
	if attacking == false:
		weapon_animation_player.play("sword_animations/idle")
		if player.direction == Vector2.ZERO:
			return idle
		else: 
			return walk
	return null
	
func Physics(_delta : float) -> State:
	return null
	
func HandleInput(_event: InputEvent) -> State:
	return null

func EndAttack( _NewAnimName:String) -> void:
	attacking = false

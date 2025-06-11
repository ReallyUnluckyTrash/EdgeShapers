class_name Player extends Entity


@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

signal player_damaged(hurt_box: HurtBox)

var invulnerable: bool = false
var hp: float = 6.0
var max_hp: float = 6.0

@onready var hit_box: HitBox = $Interactions/HitBox
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer


func _ready():
	PlayerManager.player = self
	state_machine.initialize(self)
	hit_box.damaged.connect(_take_damage)
	update_hp(99.0)
	pass

func _process(_delta):
	
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	PlayerHud.update_hp(hp, max_hp)
	
	pass
	
func _physics_process(_delta: float):
	move_and_slide()

func update_animation(anim_name : String):
	animated_sprite_2d.play()
	animated_sprite_2d.animation = anim_name
	
func _take_damage(hurt_box: HurtBox)-> void:
	if invulnerable == true:
		return
	update_hp(-hurt_box.damage)	
	print("player's hp", hp)
	if hp > 0:
		player_damaged.emit(hurt_box)
	else:
		player_damaged.emit(hurt_box)
		update_hp(99.0)
	pass

func update_hp(delta:float) ->void:
	hp = clamp(hp + delta, 0, max_hp)
	pass

func make_invulnerable(_duration:float = 1.0)->void:
	invulnerable = true
	hit_box.monitoring = false
	
	await get_tree().create_timer(_duration).timeout
	
	invulnerable = false
	hit_box.monitoring = true
	pass

	
	

	

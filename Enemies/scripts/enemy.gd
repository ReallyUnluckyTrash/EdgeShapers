class_name Enemy extends Entity

signal enemy_damaged(attack:Attack)
signal enemy_destroyed(attack:Attack)

@export var hp: int = 3
@export var raycast_length:float = 0.0
@export var enemy_range:float = 0.0

var player: Player
var invulnerable : bool = false
var level : int = 1

#variable for the states to keep track of the last attack
var last_attack:Attack = null

@export var weapon: Weapon = null
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_box: HitBox = $HitBox
@onready var state_machine: EnemyStateMachine = $EnemyStateMachine
@onready var destroy_animation_player: AnimationPlayer = $DestroyEffectSprite/AnimationPlayer
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var weapon_position: WeaponPosition = $WeaponPosition

func _ready() -> void:
	state_machine.initialize(self)
	player = PlayerManager.player
	hit_box.damaged.connect(_take_damage)
	pass

func _process(_delta: float) -> void:
	pass	
	
func _physics_process(_delta: float) -> void:
	move_and_slide()

func _take_damage(attack:Attack) -> void:
	if invulnerable == true:
		return
	
	last_attack = attack
	
	hp -= attack.damage
	print(hp)
	if hp > 0:
		enemy_damaged.emit(attack)
	else:
		enemy_destroyed.emit(attack)
	pass

func update_animation(anim_name : String):
	animation_player.play(anim_name)

func destroy_animation():
	destroy_animation_player.play("destroy")

class_name Enemy extends Entity

signal enemy_damaged()
signal enemy_destroyed()

@export var hp: int = 3

var player: Player
var invulnerable : bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box: HitBox = $HitBox
@onready var state_machine: EnemyStateMachine = $EnemyStateMachine
@onready var destroy_animation_player: AnimationPlayer = $DestroyEffectSprite/AnimationPlayer

func _ready() -> void:
	state_machine.initialize(self)
	player = PlayerManager.player
	hit_box.damaged.connect(_take_damage)
	pass

func _process(_delta: float) -> void:
	pass	

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _take_damage(damage: int) -> void:
	if invulnerable == true:
		return
	hp -= damage
	print(hp)
	if hp > 0:
		enemy_damaged.emit()
	else:
		enemy_destroyed.emit()
	pass

func update_animation(anim_name : String):
	animated_sprite_2d.play()
	animated_sprite_2d.animation = anim_name

func destroy_animation():
	destroy_animation_player.play("destroy")

class_name EnemyStateGuard extends EnemyState

@export var anim_name: String = "guard"

@export var next_state : EnemyState
var _animation_finished: bool = false
@onready var shield_sprite: Sprite2D = $"../../ShieldPosition/ShieldSprite"

var _attack:Attack
var _direction:Vector2
@export var turn_rate:float = 0.25


func initialize() -> void:
	pass

func enter() -> void:
	print("entering guard state")
	enemy.invulnerable = true
	_animation_finished = false
	enemy.velocity = Vector2.ZERO
	
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	pass
	
func exit() -> void:
	enemy.invulnerable = false
	shield_sprite.scale = Vector2(2.5, 2.5)
	var direction_to_player = enemy.global_position.direction_to(PlayerManager.player.global_position)
	enemy.set_direction(direction_to_player)
	enemy.weapon_position.update_position(enemy.anim_direction())
	
	enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	pass
	
func process(_delta : float) -> EnemyState:
	if _animation_finished == true:
		return next_state
	return null
	
func physics(_delta : float) -> EnemyState:
	return null


func _on_animation_finished(_anim_name:String):
	_animation_finished = true
	

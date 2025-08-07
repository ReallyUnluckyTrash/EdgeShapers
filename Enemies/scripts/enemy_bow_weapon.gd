class_name EnemyBowWeapon extends Weapon

var is_attacking: bool = false
@export var knockback_force: float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arrow_sprite: Sprite2D = $ArrowSprite
const ARROW = preload("res://Enemies/1_Domain/tri_bow/enemy_arrow.tscn")

@export var enemy:Enemy
var player:Player

func _ready() -> void:
	player = PlayerManager.player
	pass

func attack():
	if is_attacking == true:
		return
	is_attacking = true
	arrow_sprite.visible = true
	animation_player.play("shoot")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot":
		create_arrow()
		is_attacking = false
		animation_player.play("idle")
		attack_finished.emit()
	pass # Replace with function body.

func create_arrow()->void:
	var new_arrow = ARROW.instantiate() as Arrow
	enemy.add_sibling(new_arrow)
	
	#new_arrow.setup_direction(player.direction)
	new_arrow.setup_hurtbox(damage, knockback_force)
	#new_arrow.shot.connect()
	#new_arrow.queue_freed.connect()
	
	var arrow_direction:Vector2 = enemy.direction
	if arrow_direction == Vector2.ZERO:
		arrow_direction = enemy.cardinal_direction
	new_arrow.setup_direction(arrow_direction)
	
	var shoot_direction:Vector2 = enemy.global_position.direction_to(player.global_position)
	
	new_arrow.global_position = enemy.weapon_position.global_position
	new_arrow.shoot(shoot_direction)
	pass

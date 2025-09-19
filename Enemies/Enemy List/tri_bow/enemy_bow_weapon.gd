class_name EnemyBowWeapon extends Weapon

var is_attacking: bool = false
@export var knockback_force: float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arrow_sprite: Sprite2D = $ArrowSprite
const ARROW = preload("res://Enemies/Enemy List/tri_bow/enemy_arrow.tscn")

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
		#after animation finishes, create arrow
		create_arrow()
		is_attacking = false
		animation_player.play("idle")
		attack_finished.emit()
	pass 

#create arrow function
func create_arrow()->void:
	#instantiate arrow and add as sibling
	var new_arrow = ARROW.instantiate() as Arrow
	enemy.add_sibling(new_arrow)
	
	#setup the hurtbox with damage and knockback force
	new_arrow.setup_hurtbox(damage, knockback_force)
	
	#gets the direction towards the player to shoot the arrow at, while also adjusting the
	#rotation of the arrow
	var shoot_direction:Vector2 = enemy.global_position.direction_to(player.global_position)
	new_arrow.global_position = enemy.weapon_position.global_position
	new_arrow.shoot(shoot_direction)
	var arrow_direction:Vector2 = enemy.cardinal_direction
	new_arrow.setup_direction(arrow_direction)
	pass

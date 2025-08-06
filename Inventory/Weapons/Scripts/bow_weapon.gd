class_name BowWeapon extends Weapon

var is_attacking: bool = false
@export var knockback_force: float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arrow_sprite: Sprite2D = $ArrowSprite
const ARROW = preload("res://Inventory/Weapons/Scenes/arrow.tscn")

var player:Player

func _ready() -> void:
	player = PlayerManager.player

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
	player.add_sibling(new_arrow)
	
	#new_arrow.setup_direction(player.direction)
	new_arrow.setup_hurtbox(damage, knockback_force)
	#new_arrow.shot.connect()
	#new_arrow.queue_freed.connect()
	
	var shoot_direction = player.direction
	if shoot_direction == Vector2.ZERO:
		shoot_direction = player.cardinal_direction
	new_arrow.setup_direction(shoot_direction)
	
	new_arrow.global_position = player.front_weapon_position.global_position
	new_arrow.shoot(shoot_direction)
	pass

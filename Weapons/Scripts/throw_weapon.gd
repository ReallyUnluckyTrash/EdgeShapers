class_name ThrowWeapon extends Weapon

@export var knockback_force: float
var is_attacking: bool = false

@export var BOOMERANG = preload("res://Weapons/Scenes/boomerang.tscn")

var boomerang_instance:Boomerang = null
var player:Player

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	player = PlayerManager.player
	pass

func attack():
	if is_attacking == true:
		return
	is_attacking = true
	if boomerang_instance != null:
		is_attacking = false
		await get_tree().process_frame
		attack_finished.emit()
		return
	create_throwable()
	pass

func end_attack_immediately():
	if is_attacking:
		is_attacking = false
		attack_interrupted.emit()

func _on_weapon_thrown():
	is_attacking = false
	attack_finished.emit()
	sprite_2d.visible = false

func _on_weapon_queue_freed():
	boomerang_instance = null
	sprite_2d.visible = true

func create_throwable()->void:
	var new_boomerang = BOOMERANG.instantiate() as Boomerang
	player.add_sibling(new_boomerang)
	
	new_boomerang.thrown.connect(_on_weapon_thrown)
	new_boomerang.queue_freed.connect(_on_weapon_queue_freed)
	new_boomerang.setup_hurtbox(damage, knockback_force)
	
	new_boomerang.global_position = player.global_position
	
	var throw_direction = player.direction
	if throw_direction == Vector2.ZERO:
		throw_direction = player.cardinal_direction
	
	new_boomerang.throw(throw_direction)
	boomerang_instance = new_boomerang
	pass

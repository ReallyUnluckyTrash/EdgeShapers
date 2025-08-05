class_name ThrustWeapon extends Weapon

@export var attack_speed: float
@export var knockback_force: float

@onready var hurt_box: HurtBox = $HurtBoxPosition/HurtBox
@onready var hurt_box_position: Node2D = $HurtBoxPosition

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_attacking: bool = false

func _ready() -> void:
	animation_player.speed_scale = attack_speed
	call_deferred("setup_hurt_box")
	pass

func attack():
	if is_attacking == true:
		return
	is_attacking = true
	animation_player.play("thrust")
	pass

func end_attack_immediately():
	if is_attacking:
		is_attacking = false
		animation_player.stop()
		animation_player.play("idle")
		attack_interrupted.emit()
	
func return_to_idle():
	if animation_player.current_animation != "idle":
		animation_player.play("idle")
	is_attacking = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "thrust":
		is_attacking = false
		animation_player.play("idle")
		attack_finished.emit()
	pass

func setup_hurt_box():
	if hurt_box:
		hurt_box.damage = damage
		hurt_box.knockback_force = knockback_force

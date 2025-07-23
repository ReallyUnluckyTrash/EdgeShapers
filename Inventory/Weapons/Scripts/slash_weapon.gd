class_name SlashWeapon extends Weapon

@export var attack_speed: float
@export var knockback_force: float

@onready var hurt_box: HurtBox = $HurtBoxPosition/HurtBox
@onready var hurt_box_position: Node2D = $HurtBoxPosition

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_attacking: bool = false

func _ready() -> void:
	animation_player.speed_scale = attack_speed
	hurt_box.damage = damage
	hurt_box.knockback_force = knockback_force
	pass

func attack():
	if is_attacking == true:
		return
	is_attacking = true
	animation_player.play("sword_animations/sword_swing")
	pass

func end_attack_immediately():
	if is_attacking:
		is_attacking = false
		animation_player.stop()
		animation_player.play("sword_animations/idle")
		attack_interrupted.emit()
	
func return_to_idle():
	if animation_player.current_animation != "sword_animations/idle":
		animation_player.play("sword_animations/idle")
	is_attacking = false

func set_damage(new_damage:int):
		damage = new_damage
		hurt_box.damage = damage

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "sword_animations/sword_swing":
		is_attacking = false
		animation_player.play("sword_animations/idle")
		attack_finished.emit()
	pass
	

class_name BossWeapon extends SlashWeapon

const BOSS_SWORD_WAVE = preload("res://Weapons/Scenes/boss_sword_wave.tscn")

var player:Player

func _ready() -> void:
	animation_player.speed_scale = attack_speed
	call_deferred("setup_hurt_box")
	player = PlayerManager.player
	pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "sword_swing":
		create_arrow()
		is_attacking = false
		animation_player.play("sword_animations/idle")
		attack_finished.emit()
	pass

func create_arrow()->void:
	var new_arrow = BOSS_SWORD_WAVE.instantiate() as Arrow
	player.add_sibling(new_arrow)
	
	#new_arrow.setup_direction(player.direction)
	new_arrow.setup_hurtbox(damage, knockback_force)
	#new_arrow.shot.connect()
	#new_arrow.queue_freed.connect()
	
	var shoot_direction:Vector2 = player.direction
	if shoot_direction == Vector2.ZERO:
		shoot_direction = player.cardinal_direction
	new_arrow.setup_direction(shoot_direction)
	
	new_arrow.global_position = player.front_weapon_position.global_position
	new_arrow.shoot(shoot_direction)
	pass

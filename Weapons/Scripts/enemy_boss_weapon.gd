class_name EnemyBossWeapon extends SlashWeapon

const ENEMY_BOSS_SWORD_WAVE = preload("res://Weapons/Scenes/enemy_boss_sword_wave.tscn")
var player:Player

@export var enemy:Enemy

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
	var new_arrow = ENEMY_BOSS_SWORD_WAVE.instantiate() as Arrow
	player.add_sibling(new_arrow)
	
	#new_arrow.setup_direction(player.direction)
	new_arrow.setup_hurtbox(damage, knockback_force)
	#new_arrow.shot.connect()
	#new_arrow.queue_freed.connect()
	
	var shoot_direction:Vector2 = enemy.global_position.direction_to(player.global_position)
	new_arrow.global_position = enemy.weapon_position.global_position
	new_arrow.shoot(shoot_direction)
	var arrow_direction:Vector2 = enemy.cardinal_direction
	new_arrow.setup_direction(arrow_direction)
	pass

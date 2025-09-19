class_name EnemyBossWeapon extends SlashWeapon

const ENEMY_BOSS_SWORD_WAVE = preload("res://Weapons/Scenes/enemy_boss_sword_wave.tscn")
var player:Player

@export var enemy:Enemy

var arrow_direction:Vector2

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
	
func attack():
	if is_attacking == true:
		return
	is_attacking = true
	animation_player.play("sword_swing")
	hurt_box.monitoring = true
	effect_sprite.visible = true
	AudioManager.play_sfx(SWORD_SWOOSH)
	
	arrow_direction = enemy.cardinal_direction
	pass


func create_arrow()->void:
	var new_arrow = ENEMY_BOSS_SWORD_WAVE.instantiate() as Arrow
	enemy.add_sibling(new_arrow)

	new_arrow.setup_hurtbox(damage, knockback_force)
	
	var shoot_direction:Vector2 = enemy.global_position.direction_to(player.global_position)
	new_arrow.global_position = enemy.weapon_position.global_position
	new_arrow.shoot(shoot_direction)
	new_arrow.setup_direction(arrow_direction)
	pass

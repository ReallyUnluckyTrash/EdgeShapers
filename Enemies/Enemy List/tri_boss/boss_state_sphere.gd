class_name BossStateSphere extends EnemyStateAttack

@onready var effect_sprite: Sprite2D = $"../../EffectSprite"

func enter() -> void:
	attacking = true
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	enemy.update_animation("sphere_attack")
	pass
	
func exit() -> void:
	attacking = false
	
	effect_sprite.hide()
	enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	
	if enemy.weapon and enemy.weapon.has_method("return_to_idle"):
		enemy.weapon.return_to_idle()
	
	if enemy.weapon is SlashWeapon:
		enemy.weapon_position.update_position(enemy.anim_direction())
		pass
	pass
	
func process(_delta : float) -> EnemyState:
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta
	
	if attacking == false:
		return chase
	return null
	
func physics(_delta : float) -> EnemyState:
	return null
	
func handle_input(_event: InputEvent) -> EnemyState:
	return null

func end_attack() -> void:
	attacking = false

func _on_animation_finished(anim_name:String)->void:
	if anim_name == "sphere_attack":
		attacking = false
	pass

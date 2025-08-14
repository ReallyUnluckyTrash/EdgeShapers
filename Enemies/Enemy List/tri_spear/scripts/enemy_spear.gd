class_name EnemySpear extends Enemy

func _ready() -> void:
	state_machine.initialize(self)
	player = PlayerManager.player
	hit_box.damaged.connect(_take_damage)
	pass

func _process(_delta: float) -> void:
	pass	
	
func _physics_process(_delta: float) -> void:
	move_and_slide()

func _take_damage(attack:Attack) -> void:
	if invulnerable == true:
		return
	
	last_attack = attack
	
	hp -= attack.damage
	print(hp)
	if hp > 0:
		enemy_damaged.emit(attack)
	else:
		enemy_destroyed.emit(attack)
	pass

func update_animation(anim_name : String):
	#animated_sprite_2d.play()
	#animated_sprite_2d.animation = anim_name
	
	animation_player.play(anim_name)

func destroy_animation():
	destroy_animation_player.play("destroy")

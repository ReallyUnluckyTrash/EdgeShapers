class_name Player extends Entity


@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var front_weapon_position: FrontWeaponPosition = $FrontWeaponPosition
@onready var weapon_position: WeaponPosition = $WeaponPosition

signal player_damaged(attack:Attack)

var invulnerable: bool = false
var hp: float = 6.0
var max_hp: float = 6.0

var ep: float = 10.0
var max_ep:float = 10.0

var current_weapon: Weapon = null
var weapon_type = ""

# Export weapon scenes for easy assignment in inspector
@export var weapon_scenes: Array[PackedScene] = []
@export var starting_weapon_index: int = 0

@onready var hit_box: HitBox = $Interactions/HitBox
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D


func _ready():
	PlayerManager.player = self
	state_machine.initialize(self)
	hit_box.damaged.connect(_take_damage)
	update_hp(99.0)
	
	#temporary starting weapon
	equip_weapon(weapon_scenes[0])
	PlayerManager.equipped_weapon = PlayerManager.INVENTORY_WEAPON_DATA.slots[0].item_data
	activate_upgrades_player()
	
	pass

func _process(_delta):
	
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	PlayerHud.update_hp(hp, max_hp)
	PlayerHud.update_ep(ep, max_ep)
	
	pass
	
func _physics_process(_delta: float):
	move_and_slide()

func update_animation(anim_name : String):
	animated_sprite_2d.play()
	animated_sprite_2d.animation = anim_name
	
func _take_damage(attack:Attack)-> void:
	if invulnerable == true:
		return
	update_hp(-attack.damage)	
	print("player's hp", hp)
	if hp > 0:
		player_damaged.emit(attack)
	else:
		player_damaged.emit(attack)
		update_hp(99.0)
	pass

func update_hp(delta:float) ->void:
	hp = clamp(hp + delta, 0, max_hp)
	pass

func update_ep(delta:float) ->void:
	ep = clamp(ep + delta, 0, max_ep)
	pass

func make_invulnerable(_duration:float = 1.0)->void:
	invulnerable = true
	hit_box.monitoring = false
	
	await get_tree().create_timer(_duration).timeout
	
	invulnerable = false
	hit_box.monitoring = true
	pass
	
func equip_weapon_by_index(index:int):
	if index < 0 or index >= weapon_scenes.size():
		return
	equip_weapon(weapon_scenes[index])
	pass
	
func equip_weapon(weapon_scene: PackedScene):
	if weapon_scene == null:
		print("Weapon scene is null")
		return
	
	unequip_weapon()
	
	var new_weapon = weapon_scene.instantiate()
	if new_weapon == null:
		print("failed to instantiate weapon")
		return
	
	if new_weapon is BowWeapon:
		front_weapon_position.add_child(new_weapon)
		front_weapon_position.update_position(anim_direction())
	else:
		weapon_position.add_child(new_weapon)
	
	current_weapon = new_weapon
	
	activate_upgrades_weapon()
	var weapon_name = current_weapon.weapon_name
	weapon_type = current_weapon.get_class()
	print("Equipped weapon: ", weapon_name, " of type: ", weapon_type)
	pass

func unequip_weapon():
	if current_weapon == null:
		return
	
	current_weapon.queue_free()
	current_weapon = null
	weapon_type = ""
	print("weapon unequipped")
	
	pass
	
func activate_upgrades_weapon():
	print("activating weapon upgrades!")
	var upgrade_list = PlayerManager.PLAYER_UPGRADE_LIST.upgrades_weapon
	#weird how i have to use a dynamic variable here... maybe try a way to avoid this
	var weapon_ref = current_weapon
	for upgrade in upgrade_list:
		upgrade.apply_upgrade(weapon_ref)

func activate_upgrades_player():	
	print("activating player upgrades!")
	var upgrade_list = PlayerManager.PLAYER_UPGRADE_LIST.upgrades_player
	#weird how i have to use a dynamic variable here... maybe try a way to avoid this
	var player = self
	for upgrade in upgrade_list:
		upgrade.apply_player_upgrade(player)

#might just not allow selling of buffs to make it less complicated
func clear_upgrades_player():
	hp = 6.0
	max_hp = 6.0

	ep = 10.0
	max_ep = 10.0
	pass

##function to test if modular system works, delete later and replace by using an inventory system
#func switch_to_next_weapon():
	#if weapon_scenes.size() <= 1:
		#return
	#
	#var next_index = (starting_weapon_index + 1) % weapon_scenes.size()
	#starting_weapon_index = next_index
	#equip_weapon_by_index(next_index)
	#
	

	

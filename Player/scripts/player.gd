class_name Player extends Entity

@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var front_weapon_position: FrontWeaponPosition = $FrontWeaponPosition
@onready var weapon_position: WeaponPosition = $WeaponPosition
@onready var ep_recharge_timer: Timer = $"EP Recharge Timer"

const HIT_PLAYER = preload("res://General/Sound Effects/hit_player.wav")
const USE_ITEM = preload("res://General/Sound Effects/use_item.wav")

signal player_damaged(attack:Attack)

#player variables
var invulnerable: bool = false
var hp: float = 10.0
var max_hp: float = 10.0

var ep: float = 10.0
var max_ep:float = 10.0
var ep_recharge_count:float = 1.0

#for now these variables are here to keep track of the upgrades
#changing these values directly does not do anything
var damage_boost:int = 0
var attack_speed:float = 1.0

#weapon references
var current_weapon: Weapon = null
var weapon_type = ""

@onready var hit_box: HitBox = $Interactions/HitBox
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D


func _ready():
	#initialize self, heal to full and activate player upgrades
	PlayerManager.player = self
	state_machine.initialize(self)
	hit_box.damaged.connect(_take_damage)
	update_hp(99.0)
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
	#if invulnerble dont receive damage
	if invulnerable == true:
		return
	#if vulnerable deals damage to player
	if hp > 0:
		AudioManager.play_sfx(HIT_PLAYER)
		update_hp(-attack.damage)	
		player_damaged.emit(attack)
	pass

#update hp function
func update_hp(delta:float) ->void:
	hp = clamp(hp + delta, 0, max_hp)
	pass

#update ep function
func update_ep(delta:float) ->void:
	ep = clamp(ep + delta, 0, max_ep)
	pass

#function to turn vulnerable
func make_invulnerable(_duration:float = 1.0)->void:
	invulnerable = true
	hit_box.monitoring = false
	
	await get_tree().create_timer(_duration).timeout
	
	invulnerable = false
	hit_box.monitoring = true
	pass
	

#function to equip weapon onto player
func equip_weapon(weapon_scene: PackedScene):
	#if no weapon scene is null return
	if weapon_scene == null:
		print("Player.gd::Weapon scene is null")
		return
	
	#first, unequip the previous weapon
	unequip_weapon()
	
	#instantiate weapon
	var new_weapon = weapon_scene.instantiate() as Weapon
	if new_weapon == null:
		print("Player.gd::failed to instantiate weapon")
		return
	
	#for bow weapons, place them in front of the player 
	if new_weapon is BowWeapon:
		front_weapon_position.add_child(new_weapon)
		front_weapon_position.update_position(anim_direction())
	else:
		#else put them in the normal weapon position
		weapon_position.add_child(new_weapon)
	
	#update weapon reference
	current_weapon = new_weapon
	
	#set currently equipped weapon name
	var weapon_name = current_weapon.weapon_name
	weapon_type = current_weapon.get_class()
	print("Player.gd::Equipped weapon: ", weapon_name, " of type: ", weapon_type)
	
	#activate the weapon upgrades on the newly equipped weapon
	activate_upgrades_weapon()
	pass

#unequip weapon and reset upgrade trackers
func unequip_weapon():
	if current_weapon == null:
		return
	
	current_weapon.queue_free()
	current_weapon = null
	weapon_type = ""
	attack_speed = 1.0
	damage_boost = 0
	print("Player.gd::weapon unequipped")
	
	pass
	

#activate all upgrades for weapon
func activate_upgrades_weapon():
	if current_weapon == null:
		return
	
	for i in range(PlayerManager.PLAYER_UPGRADE_LIST.upgrades_weapon.size()):
		var upgrade = PlayerManager.PLAYER_UPGRADE_LIST.upgrades_weapon[i]
		if upgrade == null:
			continue
		
		var weapon_ref = current_weapon
		upgrade.apply_upgrade(weapon_ref)

#activate all upgrades for player
func activate_upgrades_player():	
	var upgrade_list = PlayerManager.PLAYER_UPGRADE_LIST.upgrades_player
	var player = self
	for upgrade in upgrade_list:
		upgrade.apply_player_upgrade(player)

#clear all upgrades on the player and reset trackers
func clear_upgrades_player():
	hp = 10.0
	max_hp = 10.0

	ep = 10.0
	max_ep = 10.0
	ep_recharge_count = 1.0
	ep_recharge_timer.wait_time = 5.0
	damage_boost = 0
	attack_speed = 1.0
	pass

#on timeout recharge ep
func _on_ep_recharge_timer_timeout() -> void:
	if ep != max_ep:
		AudioManager.play_sfx(USE_ITEM)
	update_ep(ep_recharge_count)
	pass 

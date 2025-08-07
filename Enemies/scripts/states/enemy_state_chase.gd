class_name EnemyStateChase extends EnemyState

@export var attack: EnemyStateAttack 

@export var anim_name: String = "chase"
@export var chase_speed: float = 40.0
@export var turn_rate: float = 0.25

@export_category("AI")
@export var vision_area: VisionArea
@export var attack_area: HurtBox
@export var state_aggro_duration: float = 2.0
@export var next_state: EnemyState

var _timer: float = 0.0
var _direction: Vector2
var _can_see_player: bool = false
var _has_line_of_sight: bool = false

func initialize() -> void:
	if vision_area:
		vision_area.player_entered.connect(_on_player_entered)
		vision_area.player_exited.connect(_on_player_exited)
	pass

func enter() -> void:
	_can_see_player = true
	_timer = state_aggro_duration
	
	var new_anim_name: String = anim_name + "_" + enemy.anim_direction()
	print("enemy_state_chase.gd::Printing new animation name: " + new_anim_name)
	enemy.update_animation(new_anim_name)
	
	if attack_area:
		attack_area.monitoring = true
	pass
	
func exit() -> void:
	if attack_area:
		attack_area.monitoring = false
	_can_see_player = false
	_has_line_of_sight = false
	pass
	
func process(_delta: float) -> EnemyState:
	# Safety check
	if not PlayerManager.player:
		return next_state
		
	var new_direction: Vector2 = enemy.global_position.direction_to(PlayerManager.player.global_position)
	
	check_line_of_sight(new_direction)
	var can_actively_chase: bool = _can_see_player && _has_line_of_sight
	
	if can_actively_chase:
		# Can see and chase player
		_direction = lerp(_direction, new_direction, turn_rate)
		enemy.velocity = _direction * chase_speed
		if enemy.set_direction(_direction):
			enemy.update_animation(anim_name + "_" + enemy.anim_direction())
			enemy.weapon_position.update_position(enemy.anim_direction())
		_timer = state_aggro_duration  # Reset timer when actively chasing
		
		#if player is in the enemy's range, enter the attack state
		#TODO for the weaponless enemies, have the attack state be a tackle
		var distance_to_player = enemy.global_position.distance_to(PlayerManager.player.global_position)
		if distance_to_player < enemy.range:
			return attack
	else:
		# Cannot actively chase (either out of vision cone OR blocked by obstacle)
		_timer -= _delta
		if _timer <= 0:
			return next_state
	
	return null
	
func physics(_delta: float) -> EnemyState:
	return null

func check_line_of_sight(_direction_to_player: Vector2) -> void:
	if not enemy.ray_cast_2d:
		_has_line_of_sight = false
		return
	
	var distance_to_player = enemy.global_position.distance_to(PlayerManager.player.global_position)
	enemy.ray_cast_2d.target_position = _direction_to_player * clamp(distance_to_player, 0.0, enemy.raycast_length)
	enemy.ray_cast_2d.force_raycast_update()
	
	_has_line_of_sight = !enemy.ray_cast_2d.is_colliding()

func _on_player_entered():
	_can_see_player = true
	if state_machine.current_state is EnemyStateStun || state_machine.current_state is EnemyStateDestroy:
		return
	state_machine.change_state(self)
	pass

func _on_player_exited():
	_can_see_player = false
	pass

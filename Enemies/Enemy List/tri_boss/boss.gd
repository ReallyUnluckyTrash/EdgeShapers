class_name Boss extends Enemy

@export var max_hp:int = 0

signal spawn_lightning
const LIGHTNING_HIT = preload("res://Enemies/Enemy List/tri_boss/lightning_hit.tscn")
@onready var vision_area: VisionArea = $VisionArea

func _ready() -> void:
	state_machine.initialize(self)
	player = PlayerManager.player
	hit_box.damaged.connect(_take_damage)
	spawn_lightning.connect(_on_spawn_lightning)
	pass

func _process(_delta: float) -> void:
	PlayerHud.update_boss_hp(hp, max_hp)
	if hp < 0:
		PlayerHud.boss_bar.hide()
	pass	

func _on_spawn_lightning()->void:
	current_lightning_wave = 0
	lightning_strikes_count = 0
	current_wave_centers.clear()
	
	var boss_tile_pos = LevelManager.local_to_map(global_position)
	
	#spawn a 9x9 lighting strike around the boss 
	var initial_positions:Array[Vector2i] = set_group_lightning_positions(boss_tile_pos)
	
	var lightning_strikes:Array[LightningHit] = []
	for tile_pos in initial_positions:
		var world_pos:Vector2 = LevelManager.map_to_local(tile_pos)
		var lightning:LightningHit = LIGHTNING_HIT.instantiate() as LightningHit
		add_sibling(lightning)
		lightning.global_position = world_pos
		lightning.queue_freed.connect(_on_lightning_finished)
		lightning_strikes.append(lightning)
		
	pass

func set_group_lightning_positions(initial_position:Vector2i)->Array[Vector2i]:
	var positions:Array[Vector2i] = []
	for x in range (-1, 2):
		for y in range (-1, 2):
			positions.append(initial_position + Vector2i(x, y))
	return positions

var lightning_strikes_count:int = 0
var current_lightning_wave:int = 0
var max_waves:int = 4
var current_wave_centers:Array[Vector2i] = []

func _on_lightning_finished()->void:
	lightning_strikes_count += 1
	
	var expected_strikes:int = 9 if current_lightning_wave == 0 else 36
	
	if lightning_strikes_count >= expected_strikes:
		current_lightning_wave += 1
		lightning_strikes_count = 0
		if current_lightning_wave <= max_waves:
			_spawn_next_wave()
		else:
			current_lightning_wave = 0
			current_wave_centers.clear()
	pass

func _spawn_next_wave()->void:
	var boss_tile_pos = LevelManager.local_to_map(global_position)
	var positions: Array[Vector2i] = []
	
	if current_lightning_wave == 1:
		current_wave_centers = [
			boss_tile_pos + Vector2i(0, -3),
			boss_tile_pos + Vector2i(0, 3),
			boss_tile_pos + Vector2i(3, 0),
			boss_tile_pos + Vector2i(-3, 0)
		]
	elif current_lightning_wave == 2:
		current_wave_centers = [
			boss_tile_pos + Vector2i(-3, -3),
			boss_tile_pos + Vector2i(-3, 3),
			boss_tile_pos + Vector2i(3, 3),
			boss_tile_pos + Vector2i(3, -3)
		]
	elif current_lightning_wave == 3:
		current_wave_centers = [
			boss_tile_pos + Vector2i(0, -6),
			boss_tile_pos + Vector2i(0, 6),
			boss_tile_pos + Vector2i(6, 0),
			boss_tile_pos + Vector2i(-6, 0)
		]
	elif current_lightning_wave == 4:
		current_wave_centers = [
			boss_tile_pos + Vector2i(6, -6),
			boss_tile_pos + Vector2i(6, 6),
			boss_tile_pos + Vector2i(-6, -6),
			boss_tile_pos + Vector2i(-6, 6)
		]
	
	for center in current_wave_centers:
		positions.append_array(set_group_lightning_positions(center))
	
	lightning_strikes_count = 0
	for tile_pos in positions:
		var world_pos:Vector2 = LevelManager.map_to_local(tile_pos)
		var lightning:LightningHit = LIGHTNING_HIT.instantiate() as LightningHit
		add_sibling(lightning)
		lightning.global_position = world_pos
		lightning.queue_freed.connect(_on_lightning_finished)

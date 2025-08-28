class_name Boss extends Enemy

signal spawn_lightning
@onready var tilemaplayer: TileMapLayer = $"../Background"

const LIGHTNING_HIT = preload("res://Enemies/Enemy List/tri_boss/lightning_hit.tscn")

func _ready() -> void:
	state_machine.initialize(self)
	player = PlayerManager.player
	hit_box.damaged.connect(_take_damage)
	spawn_lightning.connect(_on_spawn_lightning)
	pass
	
func _on_spawn_lightning()->void:
	var boss_tile_pos = local_to_map(global_position)
	
	var lightning_offsets = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0), Vector2i(0, 0),  Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)
	]
	
	for offset in lightning_offsets:
		var lightning_tile_pos = boss_tile_pos + offset
		var world_pos = tilemaplayer.map_to_local(lightning_tile_pos)
		
		var lightning = LIGHTNING_HIT.instantiate()
		add_sibling(lightning)
		lightning.global_position = world_pos
	pass

func local_to_map(world_pos: Vector2) -> Vector2i:
	return Vector2i(floor(world_pos.x / 64), floor(world_pos.y / 64))

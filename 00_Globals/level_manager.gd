extends Node

signal level_load_started
signal level_loaded
signal tilemap_bounds_changed(bounds: Array[Vector2])

var current_tilemap_bounds : Array[Vector2]
var target_transition: String
var position_offset: Vector2

func _ready() -> void:
	await get_tree().process_frame
	level_loaded.emit()

func change_tilemap_bounds(bounds: Array[Vector2]) -> void:
	current_tilemap_bounds = bounds
	tilemap_bounds_changed.emit(bounds)
	pass

func reset_tilemap_bounds()->void:
	current_tilemap_bounds.clear()
	var default_bounds: Array[Vector2] = [Vector2(-3000000, -3000000), Vector2(3000000, 3000000)]
	tilemap_bounds_changed.emit(default_bounds)	

func local_to_map(world_pos: Vector2) -> Vector2i:
	return Vector2i(floor(world_pos.x / 64), floor(world_pos.y / 64))

func map_to_local(tile_pos: Vector2i) -> Vector2:
	return Vector2(tile_pos.x * 64 + 32, tile_pos.y * 64 + 32)

func load_new_level(
	level_path: String,	
	_target_transition: String,
	_position_offset: Vector2
) -> void:
	
	print("LevelManager::Loading new level!")
	get_tree().paused = true
	target_transition = _target_transition
	position_offset = _position_offset
	
	await SceneTransition.fade_out()
	
	level_load_started.emit()
	
	await get_tree().process_frame #level transition
	
	get_tree().change_scene_to_file(level_path)
	
	await SceneTransition.fade_in()
	
	get_tree().paused = false
	
	await get_tree().process_frame #level transition
	
	level_loaded.emit()
	pass

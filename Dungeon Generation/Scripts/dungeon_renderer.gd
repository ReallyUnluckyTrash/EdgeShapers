class_name DungeonRenderer extends Node

var tilemaplayer: TileMapLayer
var config: DungeonConfig

var floor_tiles: Array = []

func setup(tilemap: TileMapLayer, dungeon_config: DungeonConfig):
	tilemaplayer = tilemap
	config = dungeon_config
	
func render_dungeon(root_node: Branch):
	_clear_previous_render()
	_place_floor_tiles(root_node)
	_place_corridor_tiles(root_node)
	_place_wall_tiles()

func _clear_previous_render():
	tilemaplayer.clear()
	floor_tiles.clear()

func _place_wall_tiles():
	var wall_positions = {}  # Use dictionary for O(1) lookup
	
	# Collect all potential wall positions first
	for floor_pos in floor_tiles:
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				
				var wall_pos = Vector2i(floor_pos.x + dx, floor_pos.y + dy)
				
				# Only add if not already a floor tile
				if not _is_floor_tile(wall_pos):
					wall_positions[wall_pos] = true
	
	# Place all wall tiles at once
	for wall_pos in wall_positions:
		tilemaplayer.set_cell(wall_pos, 4, config.wall_tile)

func _is_floor_tile(pos: Vector2i) -> bool:
	return pos in floor_tiles

func _is_wall_tile(pos: Vector2i) -> bool:
	var cell_data = tilemaplayer.get_cell_source_id(pos)
	if cell_data == -1:
		return false
	var atlas_coords = tilemaplayer.get_cell_atlas_coords(pos)
	return atlas_coords == config.wall_tile


func _place_corridor_tiles(root_node:Branch):
	# Place floor tiles for corridors
	var corridors = root_node.get_corridors()
	for corridor in corridors:
		_create_corridor_tiles(corridor['start'], corridor['end'])

func _create_corridor_tiles(start: Vector2i, end: Vector2i):
	# Create L-shaped corridor: horizontal first, then vertical
	
	# Horizontal segment
	var start_x = min(start.x, end.x)
	var end_x = max(start.x, end.x)
	for x in range(start_x, end_x + 1):
		var pos = Vector2i(x, start.y)
		tilemaplayer.set_cell(pos, 4, config.floor_tile)
		if pos not in floor_tiles:
			floor_tiles.append(pos)
	
	# Vertical segment
	var start_y = min(start.y, end.y)
	var end_y = max(start.y, end.y)
	for y in range(start_y, end_y + 1):
		var pos = Vector2i(end.x, y)
		tilemaplayer.set_cell(pos, 4, config.floor_tile)
		if pos not in floor_tiles:
			floor_tiles.append(pos)

func _place_floor_tiles(root_node:Branch):
	# Place floor tiles for rooms
	var leaves = root_node.get_leaves()
	for leaf in leaves:
		if leaf.has_room:
			for x in range(leaf.room_top_left.x, leaf.room_bottom_right.x):
				for y in range(leaf.room_top_left.y, leaf.room_bottom_right.y):
					var pos = Vector2i(x, y)
					tilemaplayer.set_cell(pos, 4, config.floor_tile)
					floor_tiles.append(pos)

func _set_camera_bounds() -> Array[Vector2]:
	var bounds : Array[Vector2] = []
	var used_rect = tilemaplayer.get_used_rect()
	
	# Get actual world bounds
	var top_left = tilemaplayer.map_to_local(used_rect.position)
	var bottom_right = tilemaplayer.map_to_local(used_rect.end - Vector2i.ONE)
	
	#var tile_size = tilemaplayer.tile_set.tile_size
	top_left -= Vector2(config.tile_size, config.tile_size) / 2
	bottom_right += Vector2(config.tile_size, config.tile_size) / 2
	
	bounds.append(top_left)
	bounds.append(bottom_right)
	
	return bounds

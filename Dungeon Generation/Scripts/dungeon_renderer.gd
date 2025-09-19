class_name DungeonRenderer extends Node

var floor_layer: TileMapLayer
var wall_layer: TileMapLayer
var config: DungeonConfig

var floor_tiles: Array = []

func setup(floormap: TileMapLayer, wallmap:TileMapLayer, dungeon_config: DungeonConfig):
	floor_layer = floormap
	wall_layer = wallmap
	config = dungeon_config

#render dungeon function, clears tiles present and places different kinds of tiles
func render_dungeon(root_node: Branch):
	_clear_previous_render()
	_place_floor_tiles(root_node)
	_place_corridor_tiles(root_node)
	_place_wall_tiles()

#function to clear all tiles
func _clear_previous_render():
	floor_layer.clear()
	floor_tiles.clear()
	wall_layer.clear()

#function that places wall tiles surrounding floor tiles
func _place_wall_tiles():
	var wall_positions = {}
	
	#collect all potential wall positions first
	for floor_pos in floor_tiles:
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				
				var wall_pos = Vector2i(floor_pos.x + dx, floor_pos.y + dy)
				
				#only add if not already a floor tile
				if not _is_floor_tile(wall_pos):
					wall_positions[wall_pos] = true
	
	#place all wall tiles at once
	for wall_pos in wall_positions:
		wall_layer.set_cell(wall_pos, 4, config.wall_tile)

#function to check if floor tile
func _is_floor_tile(pos: Vector2i) -> bool:
	return pos in floor_tiles

#function to check if wall tile
func _is_wall_tile(pos: Vector2i) -> bool:
	var cell_data = floor_layer.get_cell_source_id(pos)
	if cell_data == -1:
		return false
	var atlas_coords = floor_layer.get_cell_atlas_coords(pos)
	return atlas_coords == config.wall_tile

#function that places corridor tiles
func _place_corridor_tiles(root_node:Branch)->void:
	#place floor tiles for corridors
	var corridors = root_node.original_corridors
	for corridor in corridors:
		_create_corridor_tiles(corridor['start'], corridor['end'])

#function to create the corridor tiles alignment
func _create_corridor_tiles(start: Vector2i, end: Vector2i):
	#create L-shaped corridor: horizontal first, then vertical
	
	#horizontal segment
	var start_x = min(start.x, end.x)
	var end_x = max(start.x, end.x)
	for x in range(start_x, end_x + 1):
		var pos = Vector2i(x, start.y)
		floor_layer.set_cell(pos, 4, config.floor_tile)
		if pos not in floor_tiles:
			floor_tiles.append(pos)
	
	#vertical segment
	var start_y = min(start.y, end.y)
	var end_y = max(start.y, end.y)
	for y in range(start_y, end_y + 1):
		var pos = Vector2i(end.x, y)
		floor_layer.set_cell(pos, 4, config.floor_tile)
		if pos not in floor_tiles:
			floor_tiles.append(pos)

func _place_floor_tiles(root_node:Branch):
	#place floor tiles for rooms
	var leaves = root_node.get_leaves()
	for leaf in leaves:
		if leaf.has_room:
			for x in range(leaf.room_top_left.x, leaf.room_bottom_right.x):
				for y in range(leaf.room_top_left.y, leaf.room_bottom_right.y):
					var pos = Vector2i(x, y)
					floor_layer.set_cell(pos, 4, config.floor_tile)
					floor_tiles.append(pos)

func _set_camera_bounds() -> Array[Vector2]:
	var bounds : Array[Vector2] = []
	var used_rect = floor_layer.get_used_rect()
	
	# Get actual world bounds
	var top_left = floor_layer.map_to_local(used_rect.position)
	var bottom_right = floor_layer.map_to_local(used_rect.end - Vector2i.ONE)
	
	top_left -= Vector2(config.tile_size, config.tile_size) / 2
	bottom_right += Vector2(config.tile_size, config.tile_size) / 2
	
	bounds.append(top_left)
	bounds.append(bottom_right)
	
	return bounds

extends Node2D

var root_node: Branch
var tile_size: int = 64
var tilemaplayer: TileMapLayer

@export var map_width: int = 60
@export var map_height: int = 30

var min_cell_size: Vector2i

var floor_tile = Vector2i(17, 8)
var wall_tile = Vector2i(16, 5)
var floor_tiles: Array = []

#placeholders for spawning enemies and chests
var chest_tile = Vector2i(17,5)

var enemy_scenes = {
	1: preload("res://Enemies/1_Domain/tri_slime/tri_slime.tscn")
}

var spawned_enemies: Array = []

var entrance_tile = Vector2i(0,1)
var exit_tile = Vector2i(0,2)

var entrance_pos: Vector2i
var exit_pos: Vector2i

@onready var player: Player = $Player

func _ready() -> void:
	tilemaplayer = get_node("TileMapLayer")
	min_cell_size = Vector2i(map_width/4, map_height/4)
	generate_dungeon()

func generate_dungeon():
	# Step 1: Start with entire dungeon area (root node)
	root_node = Branch.new(Vector2i(0, 0), Vector2i(map_width, map_height))
	
	# Steps 2-6: Divide areas recursively until minimal size is reached
	root_node.split(min_cell_size)
	
	# Steps 7-8: Create rooms in each partition cell
	root_node.create_all_rooms()
	
	# Clear previous tiles and floor tracking
	tilemaplayer.clear()
	floor_tiles.clear()
	
	# Generate floor tiles for rooms and corridors
	_place_floor_tiles()
	
	# Generate walls around floor tiles
	_place_wall_tiles()
	
	_place_chests()
	_place_enemies()
	_place_entrance_exit()
	
	LevelManager.change_tilemap_bounds(_set_camera_bounds())
	

	queue_redraw()

func _draw():
	if not root_node:
		return
	
	# Draw partition boundaries (for debugging)
	_draw_partitions(root_node)

func _draw_partitions(node: Branch):
	# Draw outline of current partition
	draw_rect(
		Rect2(
			node.position.x * tile_size,
			node.position.y * tile_size,
			node.size.x * tile_size,
			node.size.y * tile_size
		),
		Color.GREEN,
		false
	)
	
	# Recursively draw child partitions
	if node.left_child:
		_draw_partitions(node.left_child)
	if node.right_child:
		_draw_partitions(node.right_child)


func _place_floor_tiles():
	# Place floor tiles for rooms
	var leaves = root_node.get_leaves()
	for leaf in leaves:
		if leaf.has_room:
			for x in range(leaf.room_top_left.x, leaf.room_bottom_right.x):
				for y in range(leaf.room_top_left.y, leaf.room_bottom_right.y):
					var pos = Vector2i(x, y)
					tilemaplayer.set_cell(pos, 4, floor_tile)
					floor_tiles.append(pos)
	
	# Place floor tiles for corridors
	var corridors = root_node.get_corridors()
	for corridor in corridors:
		_create_corridor_tiles(corridor['start'], corridor['end'])

func _place_wall_tiles():
	# For each floor tile, check surrounding positions for walls
	for floor_pos in floor_tiles:
		# Check all 8 directions around each floor tile
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if dx == 0 and dy == 0:
					continue # Skip the center (floor tile itself)
				
				var wall_pos = Vector2i(floor_pos.x + dx, floor_pos.y + dy)
				
				# If this position is not a floor tile and not already a wall, place a wall
				if not _is_floor_tile(wall_pos) and not _is_wall_tile(wall_pos):
					tilemaplayer.set_cell(wall_pos, 4, wall_tile)

func _is_floor_tile(pos: Vector2i) -> bool:
	return pos in floor_tiles

func _is_wall_tile(pos: Vector2i) -> bool:
	var cell_data = tilemaplayer.get_cell_source_id(pos)
	if cell_data == -1:
		return false
	var atlas_coords = tilemaplayer.get_cell_atlas_coords(pos)
	return atlas_coords == wall_tile
	
func _create_corridor_tiles(start: Vector2i, end: Vector2i):
	# Create L-shaped corridor: horizontal first, then vertical
	
	# Horizontal segment
	var start_x = min(start.x, end.x)
	var end_x = max(start.x, end.x)
	for x in range(start_x, end_x + 1):
		var pos = Vector2i(x, start.y)
		tilemaplayer.set_cell(pos, 4, floor_tile)
		if pos not in floor_tiles:
			floor_tiles.append(pos)
	
	# Vertical segment
	var start_y = min(start.y, end.y)
	var end_y = max(start.y, end.y)
	for y in range(start_y, end_y + 1):
		var pos = Vector2i(end.x, y)
		tilemaplayer.set_cell(pos, 4, floor_tile)
		if pos not in floor_tiles:
			floor_tiles.append(pos)
			
func _place_chests():
	var leaves = root_node.get_leaves()
	for leaf in leaves:
		leaf.place_chest()
		for chest_pos in leaf.chest_positions:
			tilemaplayer.set_cell(chest_pos, 4, chest_tile)

func _place_entrance_exit():
	var leaves = root_node.get_leaves()
	var bounds : Array[Vector2] = []
	
	if leaves.size() >= 2:
		var entrance_room = leaves[0]
		entrance_pos = entrance_room.get_room_center()
		tilemaplayer.set_cell(entrance_pos, 4, entrance_tile)
		player.position = tilemaplayer.map_to_local(entrance_pos)
		
		var camera_upper_left_bounds = entrance_room.room_top_left
		bounds.append(tilemaplayer.map_to_local(camera_upper_left_bounds))
		
		var exit_room = leaves[-1]
		exit_pos = exit_room.get_room_center()
		tilemaplayer.set_cell(exit_pos, 4, exit_tile)
		
		var camera_bottom_right_bounds = exit_room.room_bottom_right
		bounds.append(tilemaplayer.map_to_local(camera_bottom_right_bounds))
		
	pass
	
func _set_camera_bounds() -> Array[Vector2]:
	var bounds : Array[Vector2] = []
	var used_rect = tilemaplayer.get_used_rect()
	
	# Get actual world bounds
	var top_left = tilemaplayer.map_to_local(used_rect.position)
	var bottom_right = tilemaplayer.map_to_local(used_rect.end - Vector2i.ONE)
	
	#var tile_size = tilemaplayer.tile_set.tile_size
	top_left -= Vector2(tile_size, tile_size) / 2
	bottom_right += Vector2(tile_size, tile_size) / 2
	
	bounds.append(top_left)
	bounds.append(bottom_right)
	
	return bounds

func _place_enemies():
	var leaves = root_node.get_leaves()
	for leaf in leaves:
		leaf.spawn_enemies()
		for enemy_data in leaf.enemy_positions:
			var enemy_level = enemy_data['level']
			var enemy_pos = enemy_data['position']
			
			var enemy_instance = enemy_scenes[enemy_level].instantiate()
			enemy_instance.position = Vector2(
				enemy_pos.x * tile_size + tile_size/2,
				enemy_pos.y * tile_size + tile_size/2,
			)
			enemy_instance.level = enemy_level
			add_child(enemy_instance)
			spawned_enemies.append(enemy_instance)
	pass

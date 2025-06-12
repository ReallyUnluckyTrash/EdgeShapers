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
	1: preload("res://Enemies/1_Domain/tri_slime/tri_slime.tscn"),
	2: preload("res://Enemies/1_Domain/tri_slime/tri_slime2.tscn"),
	3: preload("res://Enemies/1_Domain/tri_slime/tri_slime3.tscn")
}

var spawned_enemies: Array = []

var entrance_tile = Vector2i(0,1)
var exit_tile = Vector2i(0,2)

var entrance_pos: Vector2i
var exit_pos: Vector2i

var entrance_room: Branch = null
var exit_room: Branch = null

@onready var floor_transition_tile: FloorTransition = $FloorTransition




func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent(self)
	tilemaplayer = get_node("TileMapLayer")
	min_cell_size = Vector2i(
		max(5, map_width/4), 
		max(5, map_height/4)
		)
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
	
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()
	
	# Generate floor tiles for rooms and corridors
	_place_floor_tiles()
	
	_place_corridor_tiles()
	
	# Generate walls around floor tiles
	_place_wall_tiles()
	
	#place entities (such as enemies and chests) and set the entrance and exit points
	_place_entrance_exit()
	_place_objects()
	
	#set the player and exit collision to their proper positions and change camera bounds
	PlayerManager.set_player_position(tilemaplayer.map_to_local(entrance_pos))
	floor_transition_tile.global_position = tilemaplayer.map_to_local(exit_pos)
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


func _place_corridor_tiles():
	# Place floor tiles for corridors
	var corridors = root_node.get_corridors()
	for corridor in corridors:
		_create_corridor_tiles(corridor['start'], corridor['end'])

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
			

func _place_entrance_exit():
	var leaves = root_node.get_leaves()
	var rooms_with_space = []
	
	# Only consider leaves that actually have rooms
	for leaf in leaves:
		if leaf.has_room:
			rooms_with_space.append(leaf)
	
	if rooms_with_space.size() >= 2:
		entrance_room = rooms_with_space[0]
		entrance_pos = entrance_room.get_room_center()
		tilemaplayer.set_cell(entrance_pos, 4, entrance_tile)
		
		exit_room = rooms_with_space[-1]
		exit_pos = exit_room.get_room_center()
		tilemaplayer.set_cell(exit_pos, 4, exit_tile)

	else:
		print("Warning: Not enough rooms for entrance/exit placement, regenerating dungeon")
		_on_floor_transition_regenerate_dungeon()

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

func _place_objects():
	var leaves = root_node.get_leaves()
	for i in range(0, leaves.size()):
		var leaf = leaves[i]
		
		if leaf == entrance_room:
			print("skip the entrance room for object placement")
			continue
		
		if not leaf.has_room:
			continue
		
		leaf.set_object_spawn_positions()
		
		for chest_pos in leaf.chest_positions:
			tilemaplayer.set_cell(chest_pos, 4, chest_tile)
		
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
			
			


func _on_floor_transition_regenerate_dungeon() -> void:
	print("regenerate the floor!")
	get_tree().paused = true
	await SceneTransition.fade_out()
	
	
	generate_dungeon()
	
	await SceneTransition.fade_in()
	get_tree().paused = false
	pass

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
	#generate_dungeon()
	run_multiple_evaluations(50)

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


# Add these functions to your bsp.gd file for complete evaluation

# Helper function to calculate variance
func calculate_variance(values: Array) -> float:
	if values.size() <= 1:
		return 0.0
	
	var mean = values.reduce(func(a, b): return a + b, 0.0) / values.size()
	var sum_squared_diff = 0.0
	
	for value in values:
		sum_squared_diff += pow(value - mean, 2)
	
	return sum_squared_diff / values.size()

# Helper function to calculate standard deviation
func calculate_std_deviation(values: Array) -> float:
	return sqrt(calculate_variance(values))

# Complete room distribution analysis
func evaluate_room_distribution() -> Dictionary:
	var rooms = root_node.get_leaves()
	var room_areas = []
	var room_aspect_ratios = []
	var room_widths = []
	var room_heights = []
	var valid_room_count = 0
	
	for room in rooms:
		if room.has_room:
			valid_room_count += 1
			var width = room.room_bottom_right.x - room.room_top_left.x
			var height = room.room_bottom_right.y - room.room_top_left.y
			var area = width * height
			
			room_areas.append(area)
			room_widths.append(width)
			room_heights.append(height)
			room_aspect_ratios.append(float(width) / float(height))
	
	if room_areas.size() == 0:
		return {"error": "No valid rooms found"}
	
	# Calculate statistics
	var total_room_area = room_areas.reduce(func(a, b): return a + b, 0)
	var total_dungeon_area = map_width * map_height
	
	return {
		"room_count": valid_room_count,
		"total_rooms_attempted": rooms.size(),
		"room_generation_success_rate": float(valid_room_count) / rooms.size(),
		
		# Area statistics
		"mean_area": total_room_area / room_areas.size(),
		"min_area": room_areas.min(),
		"max_area": room_areas.max(),
		"area_variance": calculate_variance(room_areas),
		"area_std_dev": calculate_std_deviation(room_areas),
		
		# Size statistics
		"mean_width": room_widths.reduce(func(a, b): return a + b, 0.0) / room_widths.size(),
		"mean_height": room_heights.reduce(func(a, b): return a + b, 0.0) / room_heights.size(),
		"width_variance": calculate_variance(room_widths),
		"height_variance": calculate_variance(room_heights),
		
		# Shape diversity
		"mean_aspect_ratio": room_aspect_ratios.reduce(func(a, b): return a + b, 0.0) / room_aspect_ratios.size(),
		"aspect_ratio_variance": calculate_variance(room_aspect_ratios),
		
		# Space efficiency
		"room_density": float(total_room_area) / total_dungeon_area,
		"average_room_area": float(total_room_area) / valid_room_count
	}

# Flood fill algorithm to find all reachable rooms from entrance
func flood_fill_from_entrance() -> Array:
	if not entrance_pos or not entrance_room:
		print("Warning: No entrance found for flood fill analysis")
		return []
	
	var visited_positions = {}
	var visited_rooms = []
	var queue = [entrance_pos]
	
	# Get all rooms for reference
	var all_rooms = root_node.get_leaves().filter(func(r): return r.has_room)
	
	while queue.size() > 0:
		var current_pos = queue.pop_front()
		
		# Skip if already visited
		if current_pos in visited_positions:
			continue
		
		visited_positions[current_pos] = true
		
		# Check if this position is in a room we haven't recorded yet
		for room in all_rooms:
			if _is_position_in_room(current_pos, room) and room not in visited_rooms:
				visited_rooms.append(room)
		
		# Add neighboring floor tiles to queue
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				if dx == 0 and dy == 0:
					continue
				
				var neighbor_pos = Vector2i(current_pos.x + dx, current_pos.y + dy)
				
				# Check if neighbor is a floor tile and not yet visited
				if _is_floor_tile(neighbor_pos) and not (neighbor_pos in visited_positions):
					queue.append(neighbor_pos)
	
	return visited_rooms

# Helper function to check if a position is within a room's bounds
func _is_position_in_room(pos: Vector2i, room: Branch) -> bool:
	if not room.has_room:
		return false
	
	return (pos.x >= room.room_top_left.x and pos.x < room.room_bottom_right.x and
			pos.y >= room.room_top_left.y and pos.y < room.room_bottom_right.y)

# Complete connectivity analysis
func evaluate_connectivity() -> Dictionary:
	var reachable_rooms = flood_fill_from_entrance()
	var all_rooms = root_node.get_leaves().filter(func(r): return r.has_room)
	var total_rooms = all_rooms.size()
	
	if total_rooms == 0:
		return {"error": "No rooms found for connectivity analysis"}
	
	# Find unreachable rooms
	var unreachable_rooms = []
	for room in all_rooms:
		if room not in reachable_rooms:
			unreachable_rooms.append(room)
	
	# Calculate path redundancy by counting corridor connections
	var corridors = root_node.get_corridors()
	var connection_count = corridors.size()
	
	# Theoretical minimum connections for full connectivity is n-1 for n rooms
	var min_connections_needed = max(0, total_rooms - 1)
	var redundant_connections = max(0, connection_count - min_connections_needed)
	
	return {
		"total_rooms": total_rooms,
		"reachable_rooms": reachable_rooms.size(),
		"unreachable_rooms": unreachable_rooms.size(),
		"connectivity_ratio": float(reachable_rooms.size()) / total_rooms,
		"is_fully_connected": unreachable_rooms.size() == 0,
		
		# Path analysis
		"total_corridors": connection_count,
		"minimum_connections_needed": min_connections_needed,
		"redundant_connections": redundant_connections,
		"path_redundancy_ratio": float(redundant_connections) / max(1, min_connections_needed),
		
		# Distance analysis
		"entrance_to_exit_distance": _calculate_path_distance(entrance_pos, exit_pos) if entrance_pos and exit_pos else -1
	}

# Calculate shortest path distance between two points using A*
func _calculate_path_distance(start: Vector2i, end: Vector2i) -> int:
	if not _is_floor_tile(start) or not _is_floor_tile(end):
		return -1
	
	var open_set = [start]
	var came_from = {}
	var g_score = {start: 0}
	var f_score = {start: _heuristic_distance(start, end)}
	
	while open_set.size() > 0:
		# Find node in open_set with lowest f_score
		var current = open_set[0]
		var current_f = f_score.get(current, INF)
		
		for node in open_set:
			var node_f = f_score.get(node, INF)
			if node_f < current_f:
				current = node
				current_f = node_f
		
		if current == end:
			# Reconstruct path length
			var path_length = 0
			var trace = current
			while trace in came_from:
				trace = came_from[trace]
				path_length += 1
			return path_length
		
		open_set.erase(current)
		
		# Check all neighbors
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				if dx == 0 and dy == 0:
					continue
				
				var neighbor = Vector2i(current.x + dx, current.y + dy)
				
				if not _is_floor_tile(neighbor):
					continue
				
				var tentative_g_score = g_score.get(current, INF) + 1
				
				if tentative_g_score < g_score.get(neighbor, INF):
					came_from[neighbor] = current
					g_score[neighbor] = tentative_g_score
					f_score[neighbor] = tentative_g_score + _heuristic_distance(neighbor, end)
					
					if neighbor not in open_set:
						open_set.append(neighbor)
	
	return -1  # No path found

# Manhattan distance heuristic for A*
func _heuristic_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

# Challenge rating and enemy distribution analysis
func evaluate_challenge_distribution() -> Dictionary:
	var rooms = root_node.get_leaves().filter(func(r): return r.has_room)
	var total_enemies = 0
	var enemy_levels = []
	var challenge_ratings = []
	var rooms_with_enemies = 0
	var rooms_with_chests = 0
	
	for room in rooms:
		if room.enemy_positions.size() > 0:
			rooms_with_enemies += 1
			
		if room.chest_positions.size() > 0:
			rooms_with_chests += 1
		
		for enemy_data in room.enemy_positions:
			total_enemies += 1
			enemy_levels.append(enemy_data['level'])
		
		if room.challenge_rating > 0:
			challenge_ratings.append(room.challenge_rating)
	
	# Calculate enemy level distribution
	var level_1_count = enemy_levels.count(1)
	var level_2_count = enemy_levels.count(2)
	var level_3_count = enemy_levels.count(3)
	
	return {
		"total_enemies": total_enemies,
		"rooms_with_enemies": rooms_with_enemies,
		"rooms_with_chests": rooms_with_chests,
		"enemy_density": float(total_enemies) / rooms.size(),
		
		# Enemy level distribution
		"level_1_enemies": level_1_count,
		"level_2_enemies": level_2_count,
		"level_3_enemies": level_3_count,
		"level_1_percentage": float(level_1_count) / max(1, total_enemies),
		"level_2_percentage": float(level_2_count) / max(1, total_enemies),
		"level_3_percentage": float(level_3_count) / max(1, total_enemies),
		
		# Challenge rating analysis
		"mean_challenge_rating": challenge_ratings.reduce(func(a, b): return a + b, 0.0) / max(1, challenge_ratings.size()),
		"max_challenge_rating": challenge_ratings.max() if challenge_ratings.size() > 0 else 0,
		"min_challenge_rating": challenge_ratings.min() if challenge_ratings.size() > 0 else 0,
		"challenge_rating_variance": calculate_variance(challenge_ratings)
	}

# Comprehensive evaluation function that runs all analyses
func run_full_evaluation() -> Dictionary:
	print("Starting comprehensive dungeon evaluation...")
	
	var evaluation_results = {
		"generation_timestamp": Time.get_unix_time_from_system(),
		"dungeon_parameters": {
			"map_width": map_width,
			"map_height": map_height,
			"min_cell_size": min_cell_size,
			"total_dungeon_area": map_width * map_height
		}
	}
	
	# Run all evaluation components
	evaluation_results["room_distribution"] = evaluate_room_distribution()
	evaluation_results["connectivity"] = evaluate_connectivity()
	evaluation_results["challenge_distribution"] = evaluate_challenge_distribution()
	
	print("Evaluation complete.")
	return evaluation_results

# Print comprehensive evaluation results in a readable format
func print_evaluation_results(results: Dictionary):
	print("\n" + "=".repeat(60))
	print("DUNGEON EVALUATION RESULTS")
	print("=".repeat(60))
	
	# Dungeon Parameters
	var params = results.get("dungeon_parameters", {})
	print("\nDUNGEON PARAMETERS:")
	print("  Map Size: %d x %d" % [params.get("map_width", 0), params.get("map_height", 0)])
	print("  Min Cell Size: %s" % str(params.get("min_cell_size", Vector2i.ZERO)))
	print("  Total Area: %d tiles" % params.get("total_dungeon_area", 0))
	
	# Room Distribution Analysis
	var room_dist = results.get("room_distribution", {})
	if "error" not in room_dist:
		print("\nROOM DISTRIBUTION:")
		print("  Total Rooms: %d" % room_dist.get("room_count", 0))
		print("  Rooms Attempted: %d" % room_dist.get("total_rooms_attempted", 0))
		print("  Success Rate: %.1f%%" % (room_dist.get("room_generation_success_rate", 0.0) * 100))
		print("  Room Density: %.1f%%" % (room_dist.get("room_density", 0.0) * 100))
		
		print("\n  Area Statistics:")
		print("    Mean Area: %.1f tiles" % room_dist.get("mean_area", 0.0))
		print("    Min Area: %d tiles" % room_dist.get("min_area", 0))
		print("    Max Area: %d tiles" % room_dist.get("max_area", 0))
		print("    Area Std Dev: %.2f" % room_dist.get("area_std_dev", 0.0))
		
		print("\n  Size Statistics:")
		print("    Mean Width: %.1f" % room_dist.get("mean_width", 0.0))
		print("    Mean Height: %.1f" % room_dist.get("mean_height", 0.0))
		print("    Mean Aspect Ratio: %.2f" % room_dist.get("mean_aspect_ratio", 0.0))
		print("    Aspect Ratio Variance: %.3f" % room_dist.get("aspect_ratio_variance", 0.0))
	else:
		print("\nROOM DISTRIBUTION: ERROR - %s" % room_dist.get("error", "Unknown"))
	
	# Connectivity Analysis
	var connectivity = results.get("connectivity", {})
	if "error" not in connectivity:
		print("\nCONNECTIVITY:")
		print("  Total Rooms: %d" % connectivity.get("total_rooms", 0))
		print("  Reachable Rooms: %d" % connectivity.get("reachable_rooms", 0))
		print("  Unreachable Rooms: %d" % connectivity.get("unreachable_rooms", 0))
		print("  Connectivity Ratio: %.1f%%" % (connectivity.get("connectivity_ratio", 0.0) * 100))
		print("  Fully Connected: %s" % ("YES" if connectivity.get("is_fully_connected", false) else "NO"))
		
		print("\n  Path Analysis:")
		print("    Total Corridors: %d" % connectivity.get("total_corridors", 0))
		print("    Minimum Needed: %d" % connectivity.get("minimum_connections_needed", 0))
		print("    Redundant Connections: %d" % connectivity.get("redundant_connections", 0))
		print("    Path Redundancy: %.2f" % connectivity.get("path_redundancy_ratio", 0.0))
		
		var distance = connectivity.get("entrance_to_exit_distance", -1)
		if distance > 0:
			print("    Entrance to Exit Distance: %d tiles" % distance)
		else:
			print("    Entrance to Exit Distance: Not calculated")
	else:
		print("\nCONNECTIVITY: ERROR - %s" % connectivity.get("error", "Unknown"))
	
	# Challenge Distribution Analysis
	var challenge = results.get("challenge_distribution", {})
	print("\nCHALLENGE DISTRIBUTION:")
	print("  Total Enemies: %d" % challenge.get("total_enemies", 0))
	print("  Rooms with Enemies: %d" % challenge.get("rooms_with_enemies", 0))
	print("  Rooms with Chests: %d" % challenge.get("rooms_with_chests", 0))
	print("  Enemy Density: %.2f enemies/room" % challenge.get("enemy_density", 0.0))
	
	print("\n  Enemy Level Distribution:")
	print("    Level 1: %d (%.1f%%)" % [challenge.get("level_1_enemies", 0), challenge.get("level_1_percentage", 0.0) * 100])
	print("    Level 2: %d (%.1f%%)" % [challenge.get("level_2_enemies", 0), challenge.get("level_2_percentage", 0.0) * 100])
	print("    Level 3: %d (%.1f%%)" % [challenge.get("level_3_enemies", 0), challenge.get("level_3_percentage", 0.0) * 100])
	
	print("\n  Challenge Rating:")
	print("    Mean CR: %.2f" % challenge.get("mean_challenge_rating", 0.0))
	print("    Min CR: %d" % challenge.get("min_challenge_rating", 0))
	print("    Max CR: %d" % challenge.get("max_challenge_rating", 0))
	print("    CR Variance: %.2f" % challenge.get("challenge_rating_variance", 0.0))
	
	print("\n" + "=".repeat(60))


# Save evaluation results to CSV files for visualization (modified for multiple runs)
func save_evaluation_results(results: Dictionary):
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var base_path = "C:/Users/John Parker/Documents/Classroom/edgeshapers/Results/"
	
	# Save room distribution data
	save_room_distribution_csv_append(results.get("room_distribution", {}), base_path + "room_distribution_multi_run.csv", timestamp)
	
	# Save connectivity data
	save_connectivity_csv_append(results.get("connectivity", {}), base_path + "connectivity_multi_run.csv", timestamp)
	
	# Save challenge distribution data
	save_challenge_distribution_csv_append(results.get("challenge_distribution", {}), base_path + "challenge_distribution_multi_run.csv", timestamp)

func save_room_distribution_csv_append(room_data: Dictionary, filepath: String, run_id: String):
	if "error" in room_data:
		print("Cannot save room distribution CSV - error in data")
		return
	
	# Check if file exists to determine if we need to write headers
	var file_exists = FileAccess.file_exists(filepath)
	
	var file = FileAccess.open(filepath, FileAccess.WRITE if not file_exists else FileAccess.READ_WRITE)
	if not file:
		print("Failed to create/open room distribution CSV at: ", filepath)
		return
	
	# If file exists, move to end for appending
	if file_exists:
		file.seek_end()
	else:
		# Write header for new file
		file.store_line("run_id,room_count,total_rooms_attempted,room_generation_success_rate,room_density,mean_area,min_area,max_area,area_variance,area_std_dev,mean_width,mean_height,width_variance,height_variance,mean_aspect_ratio,aspect_ratio_variance,average_room_area")
	
	# Write data row
	var data_row = "%s,%d,%d,%.4f,%.4f,%.2f,%d,%d,%.4f,%.4f,%.2f,%.2f,%.4f,%.4f,%.4f,%.4f,%.2f" % [
		run_id,
		room_data.get("room_count", 0),
		room_data.get("total_rooms_attempted", 0),
		room_data.get("room_generation_success_rate", 0.0),
		room_data.get("room_density", 0.0),
		room_data.get("mean_area", 0.0),
		room_data.get("min_area", 0),
		room_data.get("max_area", 0),
		room_data.get("area_variance", 0.0),
		room_data.get("area_std_dev", 0.0),
		room_data.get("mean_width", 0.0),
		room_data.get("mean_height", 0.0),
		room_data.get("width_variance", 0.0),
		room_data.get("height_variance", 0.0),
		room_data.get("mean_aspect_ratio", 0.0),
		room_data.get("aspect_ratio_variance", 0.0),
		room_data.get("average_room_area", 0.0)
	]
	
	file.store_line(data_row)
	file.close()
	print("Room distribution data appended to: ", filepath)

func save_connectivity_csv_append(connectivity_data: Dictionary, filepath: String, run_id: String):
	if "error" in connectivity_data:
		print("Cannot save connectivity CSV - error in data")
		return
	
	# Check if file exists to determine if we need to write headers
	var file_exists = FileAccess.file_exists(filepath)
	
	var file = FileAccess.open(filepath, FileAccess.WRITE if not file_exists else FileAccess.READ_WRITE)
	if not file:
		print("Failed to create/open connectivity CSV at: ", filepath)
		return
	
	# If file exists, move to end for appending
	if file_exists:
		file.seek_end()
	else:
		# Write header for new file
		file.store_line("run_id,total_rooms,reachable_rooms,unreachable_rooms,connectivity_ratio,is_fully_connected,total_corridors,minimum_connections_needed,redundant_connections,path_redundancy_ratio,entrance_to_exit_distance")
	
	# Write data row
	var data_row = "%s,%d,%d,%d,%.4f,%d,%d,%d,%d,%.4f,%d" % [
		run_id,
		connectivity_data.get("total_rooms", 0),
		connectivity_data.get("reachable_rooms", 0),
		connectivity_data.get("unreachable_rooms", 0),
		connectivity_data.get("connectivity_ratio", 0.0),
		1 if connectivity_data.get("is_fully_connected", false) else 0,
		connectivity_data.get("total_corridors", 0),
		connectivity_data.get("minimum_connections_needed", 0),
		connectivity_data.get("redundant_connections", 0),
		connectivity_data.get("path_redundancy_ratio", 0.0),
		connectivity_data.get("entrance_to_exit_distance", -1)
	]
	
	file.store_line(data_row)
	file.close()
	print("Connectivity data appended to: ", filepath)

func save_challenge_distribution_csv_append(challenge_data: Dictionary, filepath: String, run_id: String):
	# Check if file exists to determine if we need to write headers
	var file_exists = FileAccess.file_exists(filepath)
	
	var file = FileAccess.open(filepath, FileAccess.WRITE if not file_exists else FileAccess.READ_WRITE)
	if not file:
		print("Failed to create/open challenge distribution CSV at: ", filepath)
		return
	
	# If file exists, move to end for appending
	if file_exists:
		file.seek_end()
	else:
		# Write header for new file
		file.store_line("run_id,total_enemies,rooms_with_enemies,rooms_with_chests,enemy_density,level_1_enemies,level_2_enemies,level_3_enemies,level_1_percentage,level_2_percentage,level_3_percentage,mean_challenge_rating,max_challenge_rating,min_challenge_rating,challenge_rating_variance")
	
	# Write data row
	var data_row = "%s,%d,%d,%d,%.4f,%d,%d,%d,%.4f,%.4f,%.4f,%.4f,%d,%d,%.4f" % [
		run_id,
		challenge_data.get("total_enemies", 0),
		challenge_data.get("rooms_with_enemies", 0),
		challenge_data.get("rooms_with_chests", 0),
		challenge_data.get("enemy_density", 0.0),
		challenge_data.get("level_1_enemies", 0),
		challenge_data.get("level_2_enemies", 0),
		challenge_data.get("level_3_enemies", 0),
		challenge_data.get("level_1_percentage", 0.0),
		challenge_data.get("level_2_percentage", 0.0),
		challenge_data.get("level_3_percentage", 0.0),
		challenge_data.get("mean_challenge_rating", 0.0),
		challenge_data.get("max_challenge_rating", 0),
		challenge_data.get("min_challenge_rating", 0),
		challenge_data.get("challenge_rating_variance", 0.0)
	]
	
	file.store_line(data_row)
	file.close()
	print("Challenge distribution data appended to: ", filepath)

# Optional: Function to run multiple evaluations automatically
func run_multiple_evaluations(num_runs: int = 10):
	print("Starting %d dungeon evaluations..." % num_runs)
	
	for i in range(num_runs):
		print("Generating and evaluating dungeon %d/%d..." % [i + 1, num_runs])
		
		# Generate new dungeon
		generate_dungeon()
		
		# Wait a frame to ensure generation is complete
		await get_tree().process_frame
		
		# Run evaluation
		var results = run_full_evaluation()
		
		# Create unique run ID
		var run_id = str(i + 1)
		
		# Save results (this will append to existing files)
		save_evaluation_results_with_id(results, run_id)
		
		# Optional: Add a small delay between runs
		await get_tree().create_timer(0.1).timeout
	
	print("Completed %d dungeon evaluations. Results saved to CSV files." % num_runs)


# Modified save function that accepts a custom run ID
func save_evaluation_results_with_id(results: Dictionary, run_id: String):
	var base_path = "C:/Users/John Parker/Documents/Classroom/edgeshapers/Results/"
	
	# Save room distribution data
	save_room_distribution_csv_append(results.get("room_distribution", {}), base_path + "room_distribution_multi_run.csv", run_id)
	
	# Save connectivity data
	save_connectivity_csv_append(results.get("connectivity", {}), base_path + "connectivity_multi_run.csv", run_id)
	
	# Save challenge distribution data
	save_challenge_distribution_csv_append(results.get("challenge_distribution", {}), base_path + "challenge_distribution_multi_run.csv", run_id)

# Example usage function - call this after generating a dungeon
func test_dungeon_quality():
	var results = run_full_evaluation()
	print_evaluation_results(results)
	#save_evaluation_results(results)

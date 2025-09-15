class_name RoomGrammar extends Resource

# RoomTypes symbols - actual room types
enum RoomTypes {
	TREASURE,
	SUPER_TREASURE,
	EASY_ENEMY,
	NORMAL_ENEMY,
	HARD_ENEMY,
	MINI_BOSS,
	ENTRANCE,
	EXIT,
	EMPTY
}

# Room classification based on graph topology
enum RoomClass {
	ENTRANCE_ROOM,    # First room
	EXIT_ROOM,        # Last room  
	DEAD_END,         # 1 connection
	HALL_ROOM,         # more than 1 connection
	LARGE_ROOM,       # Big area regardless of connections
	SMALL_ROOM        # Small area
}

# Assignment strategy that considers room relationships
class AssignmentStrategy:
	var room_classes: Array[RoomClass] = []
	var room_graph: Dictionary = {}  # room_index -> Array[connected_indices]
	var room_areas: Array[int] = []
	var floor_level: int = 0
	var assigned_types: Array[RoomTypes] = []
	
	func _init(rooms: Array[Branch], floor: int):
		floor_level = floor
		_build_room_graph(rooms)
		_classify_rooms(rooms)
		assigned_types.resize(rooms.size())
		assigned_types.fill(RoomTypes.NORMAL_ENEMY)  # Default fallback

	func _build_room_graph(rooms: Array[Branch]):
		room_graph.clear()
		room_areas.resize(rooms.size())
		
		for i in range(rooms.size()):
			var room = rooms[i]
			var connected_indices = []
			
			# Find indices of connected rooms
			for connected_room in room.connected_rooms:
				var connected_index = rooms.find(connected_room)
				if connected_index != -1:
					connected_indices.append(connected_index)
			
			room_graph[i] = connected_indices
			room_areas[i] = _get_room_area(room)
	
	func _classify_rooms(rooms: Array[Branch]):
		room_classes.resize(rooms.size())
		
		for i in range(rooms.size()):
			var connections = room_graph[i].size()
			var area = room_areas[i]
			
			if i == 0:
				room_classes[i] = RoomClass.ENTRANCE_ROOM
			elif i == rooms.size() - 1:
				room_classes[i] = RoomClass.EXIT_ROOM
			elif connections == 1:
				room_classes[i] = RoomClass.DEAD_END
			elif connections >= 2:
				room_classes[i] = RoomClass.HALL_ROOM
			elif area >= 80:
				room_classes[i] = RoomClass.LARGE_ROOM
			elif area <= 20:
				room_classes[i] = RoomClass.SMALL_ROOM
			else:
				room_classes[i] = RoomClass.SMALL_ROOM
	
	func assign_room_types() -> Array[RoomTypes]:
		#step 1: assign entrance and exit rooms
		_assign_entrance_exit()
		#step 2: assign special rooms that occur because of certain conditions
		_assign_special_rooms()
		#step 3: assign remaining rooms with appropriate types
		_assign_remaining_rooms()
		#step 4: assign already assigned rooms new assignments based on special conditions
		_assign_post_rooms()
		return assigned_types
	
	
	func _assign_entrance_exit():
		for i in range(room_classes.size()):
			if room_classes[i] == RoomClass.ENTRANCE_ROOM:
				assigned_types[i] = RoomTypes.ENTRANCE
			elif room_classes[i] == RoomClass.EXIT_ROOM:
				assigned_types[i] = RoomTypes.EXIT
	
	func _assign_special_rooms():
		# Find candidates for mini-boss (large rooms not adjacent to entrance/exit)
		var mini_boss_candidates = []
		
		for i in range(room_classes.size()):
			if _determine_mini_boss_candidate(i):
				mini_boss_candidates.append(i)
		
		# Assign one mini-boss if we have good candidates and floor is high enough
		if mini_boss_candidates.size() > 0 and floor_level >= 5:
			var mini_boss_index = mini_boss_candidates[randi() % mini_boss_candidates.size()]
			assigned_types[mini_boss_index] = RoomTypes.MINI_BOSS
			print("Assigned mini-boss to room %d" % mini_boss_index)
	
	func _determine_mini_boss_candidate(room_index: int) -> bool:
		# Skip already assigned rooms
		if assigned_types[room_index] in [RoomTypes.ENTRANCE, RoomTypes.EXIT]:
			return false
		
		# Must be large or have interesting topology
		var is_large:bool = room_areas[room_index] >= 30
		
		var has_dead_end_neighbor:bool = false
		
		# Don't place next to entrance/exit
		var connected_indices = room_graph[room_index]
		for connected_index in connected_indices:
			if room_classes[connected_index] in [RoomClass.ENTRANCE_ROOM, RoomClass.EXIT_ROOM]:
				return false
			if room_classes[connected_index] == RoomClass.DEAD_END:
				has_dead_end_neighbor = true
		
		return is_large and has_dead_end_neighbor
	
	func _assign_remaining_rooms():
		for i in range(assigned_types.size()):
			# Skip already assigned rooms
			if assigned_types[i] in [RoomTypes.ENTRANCE, RoomTypes.EXIT, RoomTypes.MINI_BOSS]:
				continue
			
			assigned_types[i] = _determine_room_type(i)
	
	func _determine_room_type(room_index: int) -> RoomTypes:
		var room_class = room_classes[room_index]
		var area = room_areas[room_index]
		var connections = room_graph[room_index].size()
		
		#base probabilities on room characteristics
		var weights = {}
		
		match room_class:
			RoomClass.DEAD_END:
				# Dead ends are good for treasure or tough enemies
				weights[RoomTypes.TREASURE] = 1.0
				weights[RoomTypes.SUPER_TREASURE] = 0.1
				weights[RoomTypes.HARD_ENEMY] = 2.0
				weights[RoomTypes.NORMAL_ENEMY] = 2.0
				
			RoomClass.HALL_ROOM:
				# Corridors have standard encounters
				weights[RoomTypes.EASY_ENEMY] = 2.0
				weights[RoomTypes.NORMAL_ENEMY] = 1.0
				weights[RoomTypes.EASY_ENEMY] = 0.5
				weights[RoomTypes.TREASURE] = 0.5
				
			RoomClass.LARGE_ROOM:
				# Large rooms favor harder encounters
				weights[RoomTypes.HARD_ENEMY] = 3.0
				weights[RoomTypes.NORMAL_ENEMY] = 2.0
				weights[RoomTypes.TREASURE] = 1.0
				
			RoomClass.SMALL_ROOM:
				# Small rooms have easier content
				weights[RoomTypes.EASY_ENEMY] = 3.0
				weights[RoomTypes.NORMAL_ENEMY] = 2.0
				weights[RoomTypes.TREASURE] = 1.0
		
		# Adjust weights based on floor level
		if weights.has(RoomTypes.HARD_ENEMY) and floor_level > 5:
			weights[RoomTypes.HARD_ENEMY] *= 2
		if weights.has(RoomTypes.NORMAL_ENEMY) and floor_level > 5:
			weights[RoomTypes.NORMAL_ENEMY] *= 2
		
		return _weighted_random_selection(weights)
	
	func _assign_post_rooms():
		# Find mini-boss rooms and upgrade their dead-end neighbors
		for i in range(assigned_types.size()):
			if assigned_types[i] == RoomTypes.MINI_BOSS:
				_change_mini_boss_neighbors(i)
	
	func _change_mini_boss_neighbors(mini_boss_index: int):
		var connected_indices = room_graph[mini_boss_index]
		
		for connected_index in connected_indices:
			# Only upgrade dead-end neighbors that aren't special rooms
			if (room_classes[connected_index] == RoomClass.DEAD_END and 
				assigned_types[connected_index] not in [RoomTypes.ENTRANCE, RoomTypes.EXIT, RoomTypes.MINI_BOSS]):
				
				assigned_types[connected_index] = RoomTypes.SUPER_TREASURE
				print("changed room %d to super treasure (mini-boss neighbor)" % connected_index)
	
	func _weighted_random_selection(weights: Dictionary) -> RoomTypes:
		if weights.is_empty():
			return RoomTypes.NORMAL_ENEMY
		
		var total_weight = 0.0
		for weight in weights.values():
			total_weight += weight
		
		var random_value = randf() * total_weight
		var current_weight = 0.0
		
		for room_type in weights.keys():
			current_weight += weights[room_type]
			if random_value <= current_weight:
				return room_type
		
		# Fallback to first option
		return weights.keys()[0]
	
	func _get_room_area(room: Branch) -> int:
		return (room.room_bottom_right.x - room.room_top_left.x) * (room.room_bottom_right.y - room.room_top_left.y)

# Main grammar application function
func apply_grammar(rooms: Array[Branch]) -> Array[RoomTypes]:
	var strategy = AssignmentStrategy.new(rooms, PlayerManager.current_floor)
	var room_types = strategy.assign_room_types()
	return room_types
	
	print("applying graph-based room assignment to %d rooms..." % rooms.size())
	# Debug output
	for i in range(rooms.size()):
		print("Room %d: %s (Area: %d, Connections: %d)" % [
			i,
			_terminal_to_string(room_types[i]),
			strategy.room_areas[i],
			strategy.room_graph[i].size()
		])

# Helper function for debugging
func _terminal_to_string(t: RoomTypes) -> String:
	match t:
		RoomTypes.TREASURE: return "TREASURE"
		RoomTypes.SUPER_TREASURE: return "SUPER_TREASURE"
		RoomTypes.EASY_ENEMY: return "EASY_ENEMY"
		RoomTypes.NORMAL_ENEMY: return "NORMAL_ENEMY"
		RoomTypes.HARD_ENEMY: return "HARD_ENEMY"
		RoomTypes.MINI_BOSS: return "MINI_BOSS"
		RoomTypes.ENTRANCE: return "ENTRANCE"
		RoomTypes.EXIT: return "EXIT"
		RoomTypes.EMPTY: return "EMPTY"
		_: return "UNKNOWN"

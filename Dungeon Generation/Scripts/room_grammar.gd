class_name RoomGrammar extends Resource
#not actually a grammar implementation, name is a remain from my attempt
#approach is more of a graph based approach based on the map of connections between rooms

#RoomTypes enums, effectively the terminal symbols in a sense
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

#room classification based on graph topology
enum RoomClass {
	ENTRANCE_ROOM,    #first room
	EXIT_ROOM,        #last room  
	DEAD_END,         #1 connection
	HALL_ROOM,        #more than 1 connection
	LARGE_ROOM,       #Big area regardless of connections
	SMALL_ROOM        #Small area
}

#assignment strategy class that considers room relationships
class AssignmentStrategy:
	var room_classes: Array[RoomClass] = []
	var room_graph: Dictionary = {}  # room_index -> Array[connected_indices]
	var room_areas: Array[int] = []
	var floor_level: int = 0
	var assigned_types: Array[RoomTypes] = []
	
	#initialize function
	func _init(rooms: Array[Branch], floor: int):
		#when initialized, build the room graph, then classify rooms based on that room graph
		floor_level = floor
		_build_room_graph(rooms)
		_classify_rooms(rooms)
		assigned_types.resize(rooms.size())
		#for default fill the assigned types as normal enemy room types
		assigned_types.fill(RoomTypes.NORMAL_ENEMY)  

	#build room graph function
	func _build_room_graph(rooms: Array[Branch]):
		room_graph.clear()
		room_areas.resize(rooms.size())
		
		#iterate through all the rooms
		for i in range(rooms.size()):
			var room = rooms[i]
			var connected_indices = []
			
			#find indices of connected rooms then save the connected room info to the room graph
			for connected_room in room.connected_rooms:
				var connected_index = rooms.find(connected_room)
				if connected_index != -1:
					connected_indices.append(connected_index)
			
			room_graph[i] = connected_indices
			room_areas[i] = _get_room_area(room)
	
	#classify rooms function to set the room classes of each room
	func _classify_rooms(rooms: Array[Branch]):
		room_classes.resize(rooms.size())
		
		for i in range(rooms.size()):
			var connections = room_graph[i].size()
			var area = room_areas[i]
			
			#set room class as entrance room if is the very first room in the rooms array (top left room in the dungeon)
			if i == 0:
				room_classes[i] = RoomClass.ENTRANCE_ROOM
			#set as exit room if the very last (bottom right)
			elif i == rooms.size() - 1:
				room_classes[i] = RoomClass.EXIT_ROOM
			#if only has one connected room set as a dead end room
			elif connections == 1:
				room_classes[i] = RoomClass.DEAD_END
			#if has more than one, then considered a hall room
			elif connections >= 2:
				room_classes[i] = RoomClass.HALL_ROOM
			#large areas are considered large rooms
			elif area >= 80:
				room_classes[i] = RoomClass.LARGE_ROOM
			#smaller areas are considered small rooms
			elif area <= 20:
				room_classes[i] = RoomClass.SMALL_ROOM
			else:
			#default to a small room otherwise
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
	
	#set entrance and exit room classes into entrance and exit room types
	func _assign_entrance_exit():
		for i in range(room_classes.size()):
			if room_classes[i] == RoomClass.ENTRANCE_ROOM:
				assigned_types[i] = RoomTypes.ENTRANCE
			elif room_classes[i] == RoomClass.EXIT_ROOM:
				assigned_types[i] = RoomTypes.EXIT
	
	#assign special rooms that occur because of certain conditions
	func _assign_special_rooms():
		#find candidates for mini-boss (large rooms not adjacent to entrance/exit)
		var mini_boss_candidates = []
		
		#loop through the room class and check for rooms that fit mini boss room conditions
		for i in range(room_classes.size()):
			if _determine_mini_boss_candidate(i):
				mini_boss_candidates.append(i)
		
		#assign one mini-boss if we have good candidates and floor level is high enough
		if mini_boss_candidates.size() > 0 and floor_level >= 5:
			var mini_boss_index = mini_boss_candidates[randi() % mini_boss_candidates.size()]
			assigned_types[mini_boss_index] = RoomTypes.MINI_BOSS
			print("Assigned mini-boss to room %d" % mini_boss_index)
	
	#check if room is suitable as a mini boss
	func _determine_mini_boss_candidate(room_index: int) -> bool:
		# Skip already assigned rooms
		if assigned_types[room_index] in [RoomTypes.ENTRANCE, RoomTypes.EXIT]:
			return false
		
		#must be large enough to fit miniboss
		var is_large:bool = room_areas[room_index] >= 30
		#must also have a neighbor that is a dead end to turn into a super treasure room
		var has_dead_end_neighbor:bool = false
		
		#check adjacency of rooms, if beside entrance and exit then return false
		var connected_indices = room_graph[room_index]
		for connected_index in connected_indices:
			if room_classes[connected_index] in [RoomClass.ENTRANCE_ROOM, RoomClass.EXIT_ROOM]:
				return false
			if room_classes[connected_index] == RoomClass.DEAD_END:
				has_dead_end_neighbor = true
		
		#if both large enough and has a dead end neighbor than return true
		return is_large and has_dead_end_neighbor
	
	#assign leftover rooms without room types
	func _assign_remaining_rooms()->void:
		for i in range(assigned_types.size()):
			#skip already assigned rooms
			if assigned_types[i] in [RoomTypes.ENTRANCE, RoomTypes.EXIT, RoomTypes.MINI_BOSS]:
				continue
			#determine what room type the room is going to be
			assigned_types[i] = _determine_room_type(i)
	
	#function to determine the room type based on weights
	func _determine_room_type(room_index: int) -> RoomTypes:
		var room_class = room_classes[room_index]
		var area = room_areas[room_index]
		var connections = room_graph[room_index].size()
		
		#base probabilities on room characteristics
		var weights = {}
		
		match room_class:
			RoomClass.DEAD_END:
				#dead ends are good for treasure or tough enemies
				weights[RoomTypes.TREASURE] = 0.5
				weights[RoomTypes.SUPER_TREASURE] = 0.1
				weights[RoomTypes.HARD_ENEMY] = 3.0
				weights[RoomTypes.NORMAL_ENEMY] = 2.0
				
			RoomClass.HALL_ROOM:
				#corridors have standard encounters
				weights[RoomTypes.EASY_ENEMY] = 3.0
				weights[RoomTypes.NORMAL_ENEMY] = 2.0
				weights[RoomTypes.HARD_ENEMY] = 1.0
				weights[RoomTypes.TREASURE] = 0.5
				
			RoomClass.LARGE_ROOM:
				# Large rooms favor harder encounters
				weights[RoomTypes.HARD_ENEMY] = 3.0
				weights[RoomTypes.NORMAL_ENEMY] = 2.0
				weights[RoomTypes.TREASURE] = 0.5
				
			RoomClass.SMALL_ROOM:
				#small rooms have easier content
				weights[RoomTypes.EASY_ENEMY] = 3.0
				weights[RoomTypes.NORMAL_ENEMY] = 2.0
		
		#adjust weights based on floor level, harder room types are more common later on
		if weights.has(RoomTypes.HARD_ENEMY) and floor_level > 5:
			weights[RoomTypes.HARD_ENEMY] *= 2
		if weights.has(RoomTypes.NORMAL_ENEMY) and floor_level > 5:
			weights[RoomTypes.NORMAL_ENEMY] *= 2
		
		return _weighted_random_selection(weights)
	
	#function to force room types when certain conditions are triggered
	func _assign_post_rooms():
		#find mini-boss rooms and upgrade their dead-end neighbors
		for i in range(assigned_types.size()):
			if assigned_types[i] == RoomTypes.MINI_BOSS:
				_change_mini_boss_neighbors(i)
	
	#changes mini boss neighbor room into super treasure rooms
	func _change_mini_boss_neighbors(mini_boss_index: int):
		var connected_indices = room_graph[mini_boss_index]
		
		for connected_index in connected_indices:
			# Only upgrade dead-end neighbors that aren't special rooms
			if (room_classes[connected_index] == RoomClass.DEAD_END and 
				assigned_types[connected_index] not in [RoomTypes.ENTRANCE, RoomTypes.EXIT, RoomTypes.MINI_BOSS]):
				
				assigned_types[connected_index] = RoomTypes.SUPER_TREASURE
				print("RoomGrammar.gd::changed room %d to super treasure (mini-boss neighbor)" % connected_index)
	
	#calculate weights and randomly select
	func _weighted_random_selection(weights: Dictionary) -> RoomTypes:
		if weights.is_empty():
			return RoomTypes.NORMAL_ENEMY
		
		#add up all the weights
		var total_weight = 0.0
		for weight in weights.values():
			total_weight += weight
		
		#random value based on total weight
		var random_value = randf() * total_weight
		var current_weight = 0.0
		
		#determine room type based on random value
		for room_type in weights.keys():
			current_weight += weights[room_type]
			if random_value <= current_weight:
				return room_type
		
		#fallback to first option
		return weights.keys()[0]
	
	#get room area function
	func _get_room_area(room: Branch) -> int:
		return (room.room_bottom_right.x - room.room_top_left.x) * (room.room_bottom_right.y - room.room_top_left.y)

#main grammar application function
func apply_grammar(rooms: Array[Branch]) -> Array[RoomTypes]:
	var strategy = AssignmentStrategy.new(rooms, PlayerManager.current_floor)
	var room_types = strategy.assign_room_types()
	
	print("RoomGrammar.gd::applying graph-based room assignment to %d rooms..." % rooms.size())
	#debug output
	for i in range(rooms.size()):
		print("Room %d: %s (Area: %d, Connections: %d)" % [
			i,
			_terminal_to_string(room_types[i]),
			strategy.room_areas[i],
			strategy.room_graph[i].size()
		])
	return room_types
	
#helper function to convert room types into proper strings
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

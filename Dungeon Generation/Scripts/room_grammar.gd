class_name RoomGrammar extends Resource

enum RoomType{
	UNDEFINED, 
	TREASURE,
	SUPER_TREASURE,
	EASY_ENEMY,
	NORMAL_ENEMY,
	HARD_ENEMY,
	MINI_BOSS,
	ENTRANCE,
	EXIT
}

class GrammarRule:
	var from_type:RoomType
	var to_type:RoomType
	var condition: Callable
	var weight:float = 1.0
	
	func _init(_from: RoomType, _to: RoomType, _condition: Callable = Callable(), _weight: float = 1.0):
		from_type = _from
		to_type = _to
		condition = _condition
		weight = _weight

class RoomContext:
	var room:Branch
	var room_index:int
	var total_rooms:int
	var previous_rooms: Array[RoomType] = []
	var depth_level:int
	var area:int
	# NEW: Add access to current room type assignments
	var all_rooms: Array[Branch] = []
	var current_room_types: Array[RoomType] = []
	
	func _init(_room:Branch, _index:int, _total:int, _previous:Array[RoomType] = [], _all_rooms:Array[Branch] = [], _current_types:Array[RoomType] = []) -> void:
		room = _room
		room_index = _index
		total_rooms = _total
		previous_rooms = _previous
		depth_level = _room.depth
		area = (_room.room_bottom_right.x - _room.room_top_left.x) * (_room.room_bottom_right.y - _room.room_top_left.y)
		all_rooms = _all_rooms
		current_room_types = _current_types

var grammar_rules:Array[GrammarRule] = []

func _init()->void:
	_setup_rules()

func add_rule(from:RoomType, to:RoomType, condition:Callable, weight:float = 1.0):
	grammar_rules.append(GrammarRule.new(from, to, condition, weight))	

func _setup_rules()->void:
	
	add_rule(RoomType.UNDEFINED, RoomType.EASY_ENEMY,
		func(context:RoomContext):return context.area <= 16, 2.0 )
	
	add_rule(RoomType.UNDEFINED, RoomType.NORMAL_ENEMY,
		func(context:RoomContext):return context.area >= 17 && context.area <= 59, 1.0 )
	
	add_rule(RoomType.UNDEFINED, RoomType.HARD_ENEMY,
		func(context:RoomContext):return context.area >= 60, 1.0 )
	
	add_rule(RoomType.UNDEFINED, RoomType.TREASURE,
		func(context: RoomContext):return context.area <= 16, 0.5)
	
	# NEW: Super treasure rule that checks for mini-boss neighbor
	#add_rule(RoomType.UNDEFINED, RoomType.SUPER_TREASURE, 
		#func(context:RoomContext): return _check_if_room_type_is_neighbor(context, RoomType.MINI_BOSS) and context.area >= 15, 50.0)
	#
	# Regular super treasure (rare)
	#add_rule(RoomType.UNDEFINED, RoomType.SUPER_TREASURE, 
		#func(context:RoomContext): return randf() < 0.2, 0.1)
	
	add_rule(RoomType.UNDEFINED, RoomType.MINI_BOSS, 
		func(context:RoomContext):
			if context.area < 30:
				return false
			
			if _is_adjacent_to_entrance_exit(context):
				return false
			
			if context.room.is_dead_end():
				return false
			
			var has_dead_end_neighbor:bool = false
			for connected_room in context.room.connected_rooms:
				if connected_room.is_dead_end():
					has_dead_end_neighbor = true
					break
			
			return has_dead_end_neighbor
			, 50.5)
	
	add_rule(RoomType.UNDEFINED, RoomType.NORMAL_ENEMY, 
		func(context: RoomContext): return true, 0.5)

func apply_grammar(rooms:Array[Branch]) -> Array[RoomType]:
	var room_types:Array[RoomType] = []
	
	# Initialize all rooms as undefined
	for i in range(rooms.size()):
		room_types.append(RoomType.UNDEFINED)
	
	# Run multiple iterations
	var max_iterations = 5
	for iteration in range(max_iterations):
		var changes_made = false
		
		# Iterate over all the rooms
		for i in range(rooms.size()):
			if i == 0:
				room_types[i] = RoomType.ENTRANCE
				continue
			elif i == rooms.size()-1:
				room_types[i] = RoomType.EXIT
			
			# Skip if room type is already assigned
			if room_types[i] != RoomType.UNDEFINED:
				continue
			
			var context = RoomContext.new(
				rooms[i], 
				i, 
				rooms.size(), 
				room_types.slice(0, i),  # Previous rooms
				rooms,  # All rooms
				room_types  # Current room type assignments
			)
			
			var new_type = _apply_rules_to_room(room_types[i], context)
			
			# If new type is different, update it
			if new_type != room_types[i]:
				room_types[i] = new_type
				changes_made = true
		
		if not changes_made:
			break
	_convert_neighbors_to_super_treasure(rooms, room_types)
	
	return room_types

func _apply_rules_to_room(current_type:RoomType, context:RoomContext)->RoomType:
	var applicable_rules:Array[GrammarRule] = []
	
	for rule in grammar_rules:
		if rule.from_type == current_type:
			if rule.condition.is_null() or rule.condition.call(context):
				applicable_rules.append(rule)
	
	if applicable_rules.is_empty():
		return current_type
	
	var total_weight = 0.0
	for rule in applicable_rules:
		total_weight += rule.weight
	
	var random_value = randf() * total_weight
	var current_weight = 0.0
	
	for rule in applicable_rules:
		current_weight += rule.weight
		if random_value <= current_weight:
			return rule.to_type
	
	return applicable_rules[0].to_type

func _count_type_in_previous(previous: Array[RoomType], type: RoomType) -> int:
	return previous.count(type)

func _check_if_room_type_is_neighbor(context: RoomContext, room_type: RoomType) -> bool:
	print("Checking room %d for neighbors of type %s" % [context.room_index, _room_type_to_string(room_type)])
	print("Connected rooms count: %d" % context.room.connected_rooms.size())

	for i in range(context.room.connected_rooms.size()):
		var connected_room = context.room.connected_rooms[i]
		var room_index = context.all_rooms.find(connected_room)
		if room_index != -1:
			var current_type = context.current_room_types[room_index]
			print("  Neighbor %d has type: %s" % [room_index, _room_type_to_string(current_type)])

	var result = context.room.has_neighbor_of_type(room_type, context.all_rooms, context.current_room_types)
	print("Result: %s" % result)
	return result

func _is_adjacent_to_entrance_exit(context:RoomContext)->bool:
	for connected_room in context.room.connected_rooms:
		var room_index = context.all_rooms.find(connected_room)
		#if room_index != -1:
			#if room_index == 0 || room_index == context.all_rooms.size() - 1:
				#return true
		if room_index == context.all_rooms.size() - 1:
				return true
	return false


func _convert_neighbors_to_super_treasure(rooms: Array[Branch], room_types: Array[RoomType]):
	for i in range(rooms.size()):
		# Skip if already a special room type
		if room_types[i] in [RoomType.SUPER_TREASURE, RoomType.ENTRANCE, RoomType.EXIT]:
			continue
			
		var context = RoomContext.new(rooms[i], i, rooms.size(), [], rooms, room_types)
		# Check if this room has a mini-boss neighbor
		if _check_if_room_type_is_neighbor(context, RoomType.MINI_BOSS) && context.room.is_dead_end():
			room_types[i] = RoomType.SUPER_TREASURE
			print("Converted room %d to SUPER_TREASURE (neighbor of mini-boss)" % i)

# Helper function for debugging
func _room_type_to_string(type: RoomType) -> String:
	match type:
		RoomType.UNDEFINED:
			return "UNDEFINED"
		RoomType.EASY_ENEMY:
			return "EASY_ENEMY"
		RoomType.NORMAL_ENEMY:
			return "NORMAL_ENEMY"
		RoomType.HARD_ENEMY:
			return "HARD_ENEMY"
		RoomType.TREASURE:
			return "TREASURE"
		RoomType.SUPER_TREASURE:
			return "SUPER_TREASURE"
		RoomType.MINI_BOSS:
			return "MINI_BOSS"
		RoomType.ENTRANCE:
			return "ENTRANCE"
		RoomType.EXIT:
			return "EXIT"
		_:
			return "UNKNOWN"

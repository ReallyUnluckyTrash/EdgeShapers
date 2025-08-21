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
		func(context: RoomContext):return randf() < 0.2, 0.5)
	
	# NEW: Super treasure rule that checks for mini-boss neighbor
	add_rule(RoomType.UNDEFINED, RoomType.SUPER_TREASURE, 
		func(context:RoomContext): return _check_if_mini_boss_neighbor(context) and context.area >= 15, 50.0)
	
	# Regular super treasure (rare)
	add_rule(RoomType.UNDEFINED, RoomType.SUPER_TREASURE, 
		func(context:RoomContext): return randf() < 0.05, 0.1)
	
	add_rule(RoomType.UNDEFINED, RoomType.MINI_BOSS, 
		func(context:RoomContext):return context.area >= 30 and context.depth_level >= 1, 0.5)
	
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
			# Skip if room type is already assigned
			if room_types[i] != RoomType.UNDEFINED:
				continue
			
			# Create context with current state of all room assignments
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

func _check_if_mini_boss_neighbor(context:RoomContext)->bool:
	# Check if this room is a leaf (end room) and has only one connection
	if context.room.left_child != null or context.room.right_child != null:
		return false  # Not a leaf room
	
	if context.room.parent == null:
		return false  # Root room, no parent
	
	# Find the sibling room
	var sibling_room: Branch = null
	if context.room.parent.left_child == context.room:
		sibling_room = context.room.parent.right_child
	elif context.room.parent.right_child == context.room:
		sibling_room = context.room.parent.left_child
	
	if sibling_room == null:
		return false
	
	# Find the sibling room's index in our rooms array to check its type
	var sibling_index = -1
	for i in range(context.all_rooms.size()):
		if context.all_rooms[i] == sibling_room:
			sibling_index = i
			break
	
	if sibling_index == -1:
		return false
	
	# Check if the sibling room is (or will become) a mini-boss room
	var sibling_type = context.current_room_types[sibling_index]
	
	print("room_grammar.gd:: checking sibling at index %d, type: %s" % [sibling_index, _room_type_to_string(sibling_type)])
	
	if sibling_type == RoomType.MINI_BOSS:
		print("room_grammar.gd:: room is beside miniboss, can become super treasure room")
		return true
	
	# Also check if the sibling could become a mini-boss (for future iterations)
	# This is more complex but helps with ordering issues
	return false

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

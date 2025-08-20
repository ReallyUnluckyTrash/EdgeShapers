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
	
	func _init(_room:Branch, _index:int, _total:int, _previous:Array[RoomType] = []) -> void:
		room = _room
		room_index = _index
		total_rooms = _total
		previous_rooms = _previous
		depth_level = _room.depth
		area = (_room.room_bottom_right.x - _room.room_top_left.x) * (_room.room_bottom_right.y - _room.room_top_left.y)
		pass

var grammar_rules:Array[GrammarRule] = []

func _init()->void:
	_setup_rules()

func add_rule(from:RoomType, to:RoomType, condition:Callable, weight:float = 1.0):
	grammar_rules.append(GrammarRule.new(from, to, condition, weight))	

func _setup_rules()->void:
	pass

func apply_grammar(rooms:Array[Branch]) -> Array[RoomType]:
	var room_types:Array[RoomType] = []
	var previous_types:Array[RoomType] = []
	
	#set all rooms as undefined
	for i in range(rooms.size()):
		room_types.append(RoomType.UNDEFINED)
	
	#run the room type assigning 5 times so as to not miss anything?
	var max_iterations = 5
	for iteration in range(max_iterations):
		var changes_made = false
		
		#iterate over all the rooms
		for i in range(rooms.size()):
			#if room type is not UNDEFINED then continue
			if room_types[i] != RoomType.UNDEFINED:
				continue
			
			var context = RoomContext.new(rooms[i], i, rooms.size(), previous_types.slice(0, i))
			var new_type = _apply_rules_to_room(room_types[i], context)
			
			#if new type is not the same as the room type then change
			if new_type != room_types[i]:
				room_types[i] = new_type
				changes_made = true
		
		if not changes_made == true:
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
	
	

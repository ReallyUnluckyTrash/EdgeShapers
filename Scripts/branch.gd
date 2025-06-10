extends Node

class_name Branch

var left_child: Branch
var right_child: Branch
var position: Vector2i
var size: Vector2i
var room_top_left: Vector2i
var room_bottom_right: Vector2i 
var has_room: bool = false

#refactor candidates
var chest_positions: Array = []

var enemy_positions: Array = []
var challenge_rating:int = 0


func _init(_position, _size) -> void:
	self.position = _position
	self.size = _size
	
func get_leaves():
	if not(left_child && right_child):
		return[self]
	else:
		return left_child.get_leaves() + right_child.get_leaves()

func get_room_center():
	if has_room:
		return Vector2i(
			(room_top_left.x + room_bottom_right.x) / 2,
			(room_top_left.y + room_bottom_right.y) / 2
		)
	return Vector2i(position.x + size.x / 2, position.y + size.y / 2)
		

#function to split set area into different areas
func split(min_size: Vector2i):
	
	#check if current size is smaller than min size
	if size.x <= min_size.x or size.y <= min_size.y:
		return
	
	var rng = RandomNumberGenerator.new()
	#keeps the split to a ratio of 30% to 70%
	var split_percent = rng.randf_range(0.3, 0.7)
	
	# if height is greater than width than split horizontally instead of vertically
	var split_horizontal = size.y >= size.x
	
	#split horizontally
	if(split_horizontal):
		var left_height = int(size.y * split_percent)
		left_child = Branch.new(position, Vector2i(size.x, left_height))
		right_child = Branch.new(
			Vector2i(position.x, position.y + left_height),
			Vector2i(size.x, size.y - left_height)
			)
	
	#split vertically
	else:
		var left_width = int(size.x * split_percent)
		left_child = Branch.new(position, Vector2i(left_width, size.y))
		right_child = Branch.new(
			Vector2i(position.x + left_width, position.y),
			Vector2i(size.x - left_width, size.y)
			)
	
	#recursively split children until min size
	left_child.split(min_size)
	right_child.split(min_size)
	pass

func create_room():
	var rng = RandomNumberGenerator.new()
	
	
	var padding = Vector2i(1,1)
	var available_space = Vector2i(size.x - padding.x * 2, size.y - padding.y * 2)
	
	var min_room_size = Vector2i(
		max(4, available_space.x / 2),
		max(4, available_space.y / 2)
	)
	
	var max_room_size = Vector2i(
		max(min_room_size.x, size.x - padding.x * 2),
		max(min_room_size.y, size.y - padding.y * 2),
	)
	
	var max_top_left = Vector2i(
		position.x + size.x - max_room_size.x,
		position.y + size.y - max_room_size.y
	)
	
	room_top_left = Vector2i(
		rng.randi_range(position.x + padding.x, max(position.x + padding.x, max_top_left.x)),
		rng.randi_range(position.y + padding.y, max(position.y + padding.y, max_top_left.y))
	)
	
	room_bottom_right = Vector2i(
		rng.randi_range(room_top_left.x + min_room_size.x, min(room_top_left.x + max_room_size.x, position.x + size.x - padding.x)),
		rng.randi_range(room_top_left.y + min_room_size.y, min(room_top_left.y + max_room_size.y, position.y + size.y - padding.y))
	)
	
	has_room = true

func create_all_rooms():
	var leaves = get_leaves()
	for leaf in leaves:
		leaf.create_room()

func get_corridors():
	var corridors = []
	_collect_corridors(corridors)
	return corridors

func _collect_corridors(corridors):
	var parent_center = _get_descendant_room_center(self)
	
	if left_child:
		var left_center = _get_descendant_room_center(left_child)
		if parent_center != Vector2i.ZERO 	&& left_center != Vector2i.ZERO:
			corridors.append({'start' : parent_center, 'end' : left_center})
		left_child._collect_corridors(corridors)
	
	if right_child:
		var right_center = _get_descendant_room_center(right_child)
		if parent_center != Vector2i.ZERO 	&& right_center != Vector2i.ZERO:
			corridors.append({'start' : parent_center, 'end' : right_center})
		right_child._collect_corridors(corridors)

func _get_descendant_room_center(node:Branch) -> Vector2i:
	if node.has_room:
		return node.get_room_center()
	
	if node.left_child && node.left_child.has_room:
		return node.left_child.get_room_center()
	elif node.right_child && node.right_child.has_room:
		return node.right_child.get_room_center()
	elif node.left_child:
		return _get_descendant_room_center(node.left_child)
	elif node.right_child:
		return _get_descendant_room_center(node.right_child)
	
	return Vector2.ZERO

#refactor candidate


func calculate_challenge_rating():
	if not has_room:
		return
	
	var room_area = (room_bottom_right.x - room_top_left.x) * (room_bottom_right.y - room_top_left.y)
	var depth = _get_depth_from_root()
	
	challenge_rating = min(3, max(1, (room_area/10) + (depth/2) ))

func _get_depth_from_root()->int:
	return 1 if size.x * size.y >100 else 2
	
#func place_chest():
	#if has_room && randf() < 0.2:
		#var rng = RandomNumberGenerator.new()
		#var chest_pos = Vector2i(
			#rng.randi_range(room_top_left.x + 1, room_bottom_right.x - 2),
			#rng.randi_range(room_top_left.y + 1, room_bottom_right.y - 2)
			#)
		#chest_positions.append(chest_pos)
#
#func spawn_enemies():
	#if not has_room:
		#return
	#
	#calculate_challenge_rating()
	#var remaining_cr = challenge_rating
	##var max_spawn_attempts = 20  # Prevent infinite loops
	##var spawn_attempts = 0
	#
	#while remaining_cr > 0:
		#var enemy_level = 1
		#var spawn_pos = _find_valid_enemy_position()
		#
		#if spawn_pos != Vector2i.ZERO:
			#enemy_positions.append({
				#'position': spawn_pos,
				#'level': enemy_level
			#})
			#remaining_cr -= enemy_level
		#
		##spawn_attempts += 1
		#
		## If we can't find valid positions, break out
		#if spawn_pos == Vector2i.ZERO:
			#break
#
#func _find_valid_enemy_position() -> Vector2i:
	#var rng = RandomNumberGenerator.new()
	#var attempts = 10
	#
	#while attempts > 0:
		#var pos = Vector2i(
			#rng.randi_range(room_top_left.x + 1, room_bottom_right.x - 2),
			#rng.randi_range(room_top_left.y + 1, room_bottom_right.y - 2)
		#)
		#
		## Check if position is valid (less strict distance requirement)
		#var room_center = get_room_center()
		#var min_distance_from_center = 1  # Reduced from 2
		#
		#if pos.distance_to(room_center) >= min_distance_from_center:
			#var valid = true
			#
			## Check distance from chests
			#for chest_pos in chest_positions:
				#if pos.distance_to(chest_pos) < 1.5:  # Reduced from 2
					#valid = false
					#break
			#
			## Check distance from other enemies
			#for enemy_data in enemy_positions:
				#var enemy_pos = enemy_data['position']
				#if pos.distance_to(enemy_pos) < 1.5:
					#valid = false
					#break
			#
			#if valid:
				#return pos
		#
		#attempts -= 1
	#
	#return Vector2i.ZERO
	#
	
func get_all_valid_positions() -> Array:
	var valid_positions = []
	var room_center = get_room_center()
	var min_distance_from_center = 1
	
	for x in range(room_top_left.x + 1, room_bottom_right.x - 1):
		for y in range(room_top_left.y + 1, room_bottom_right.y - 1):
			var pos = Vector2i(x, y)
			if pos.distance_to(room_center) >= min_distance_from_center:
				valid_positions.append(pos)
	
	return valid_positions


func set_object_spawn_positions():
	if not has_room:
		return
	
	var all_valid_pos = get_all_valid_positions()
	all_valid_pos.shuffle()
	
	place_chest_from_positions(all_valid_pos)
	spawn_enemies_from_positions(all_valid_pos)

func place_chest_from_positions(available_positions: Array):
	if randf() < 0.2 and available_positions.size() > 0:
		chest_positions.append(available_positions.pop_front())

func spawn_enemies_from_positions(available_positions: Array):
	calculate_challenge_rating()
	var remaining_cr = challenge_rating  
	
	while remaining_cr > 0 and available_positions.size() > 0:
		var enemy_level = randi_range(1, 3)
		#var enemy_level = 1
		enemy_positions.append({
			'position': available_positions.pop_front(),
			'level': enemy_level
		})
		remaining_cr -= enemy_level  # Decrement the local variable
	
	

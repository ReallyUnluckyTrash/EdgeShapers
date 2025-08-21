extends Node

class_name Branch

#the left child of the node
var left_child: Branch
#the right child of the node
var right_child: Branch

var position: Vector2i
var size: Vector2i
var parent: Branch = null
var depth:int = 0

var room_top_left: Vector2i
var room_bottom_right: Vector2i 

var has_room: bool = false

#refactor candidates
var chest_positions: Array = []

var enemy_positions: Array = []
var challenge_rating:int = 0

var room_type: RoomGrammar.RoomType = RoomGrammar.RoomType.UNDEFINED

func _init(_position:Vector2i, _size:Vector2i, _parent: Branch = null) -> void:
	self.position = _position
	self.size = _size
	self.parent = _parent
	
	if parent == null:
		depth = 0
	else:
		depth = parent.depth + 1


func get_leaves():
	if not(left_child && right_child):
		return[self]
	else:
		return left_child.get_leaves() + right_child.get_leaves()

func get_room_center()->Vector2i:
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
		left_child = Branch.new(position, Vector2i(size.x, left_height), self)
		right_child = Branch.new(
			Vector2i(position.x, position.y + left_height),
			Vector2i(size.x, size.y - left_height),
			self
			)
	#split vertically
	else:
		var left_width = int(size.x * split_percent)
		left_child = Branch.new(position, Vector2i(left_width, size.y), self)
		right_child = Branch.new(
			Vector2i(position.x + left_width, position.y),
			Vector2i(size.x - left_width, size.y),
			self
			)
	
	#recursively split children until min size
	left_child.split(min_size)
	right_child.split(min_size)
	pass

#function that sets the room parameters for the renderer to place tiles in later
func create_room():
	var rng = RandomNumberGenerator.new()
	
	#set padding so that rooms are not touching the edges of the partition,
	#to make space for the placement of the wall tiles
	var padding = Vector2i(1, 1)
	
	#set minimum room size, which is at least a 3x3 sized room 
	var min_room_size = Vector2i(3, 3)
	
	#maximum room size/available space is calculated from the size and previously set padding
	var max_room_size = Vector2i(size.x - padding.x * 2, size.y - padding.y * 2)
	
	#check if we can fit a room with area >= 8 in the available space
	if max_room_size.x < 3 or max_room_size.y < 3 or max_room_size.x * max_room_size.y < 9:
		#not enough space for minimum area requirement, mark partition as having no room
		has_room = false
		return
	
	#generate random room dimensions within the allowed size constraints
	var room_width = rng.randi_range(min_room_size.x, max_room_size.x)
	var room_height = rng.randi_range(min_room_size.y, max_room_size.y)
	
	#ensure the room has enough area by expanding dimensions if needed
	#this loop increases width or height until the area requirement is met
	while room_width * room_height <= 8:
		#prioritize expanding width first, then height, within maximum bounds
		if room_width <= room_height and room_width < max_room_size.x:
			room_width += 1
		elif room_height < max_room_size.y:
			room_height += 1
		else:
			#break if we can't expand further without exceeding bounds
			break
	
	#calculate the maximum possible top-left corner positions for the room
	#this ensures the room fits entirely within the partition with proper padding
	var max_top_left_x = position.x + size.x - padding.x - room_width
	var max_top_left_y = position.y + size.y - padding.y - room_height
	
	#validate that there's valid space for room placement
	#if the calculated max positions are invalid, the partition is too small
	if max_top_left_x < position.x + padding.x or max_top_left_y < position.y + padding.y:
		has_room = false
		return
	
	#randomly place the room's top-left corner within the valid range
	#while following both padding constraints and room dimensions
	room_top_left = Vector2i(
		rng.randi_range(position.x + padding.x, max_top_left_x),
		rng.randi_range(position.y + padding.y, max_top_left_y)
	)
	
	#calculate the bottom-right corner based on the top-left position and room dimensions
	room_bottom_right = Vector2i(
		room_top_left.x + room_width,
		room_top_left.y + room_height
	)
	
	#mark the partition as having a room
	has_room = true
	

func create_all_rooms():
	var leaves = get_leaves()
	for leaf in leaves:
		leaf.create_room()

#function to return an array containing all corridors
func get_corridors():
	var corridors = []
	_collect_corridors(corridors)
	return corridors

func _collect_corridors(corridors):
	#recursively traverse left subtree to collect corridors from child partitions
	if left_child:
		left_child._collect_corridors(corridors)
	
	#recursively traverse right subtree to collect corridors from child partitions
	if right_child:
		right_child._collect_corridors(corridors)
	
	#if this node has both children, create a corridor connecting them
	if left_child && right_child:
		#get both centers from the left and right child
		var left_center = _get_child_center(left_child)
		var right_center = _get_child_center(right_child)
		
		#then create a corridor if both children have valid room centers
		#if it does add corridor data to the input array
		if left_center != Vector2i.ZERO && right_center != Vector2i.ZERO:
			corridors.append({'start': left_center, 'end': right_center})

func _get_child_center(node:Branch) -> Vector2i:
	if node.has_room:
		return node.get_room_center()
	
	var left_rep = Vector2i.ZERO
	var right_rep = Vector2i.ZERO
	
	if node.left_child:
		left_rep = _get_child_center(node.left_child)
		right_rep = _get_child_center(node.right_child)
		
	if left_rep != Vector2i.ZERO:
		return left_rep
	elif right_rep != Vector2i.ZERO:
		return right_rep
	
	return Vector2i.ZERO


func calculate_challenge_rating(): 
	if not has_room:
		return
		
	var room_area = (room_bottom_right.x - room_top_left.x) * (room_bottom_right.y - room_top_left.y)
	var base_cr = 2
	var min_area = 9
	var area_bonus = max(0, (room_area-min_area)/6)
	var depth_bonus = max(0, depth/3)
	
	challenge_rating = base_cr + area_bonus + depth_bonus
	challenge_rating = min(challenge_rating, 10)


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
	
	RoomTypeHandler.apply_room_type(self, room_type)
	
	#var all_valid_pos = get_all_valid_positions()
	#all_valid_pos.shuffle()
	#
	#place_chest_from_positions(all_valid_pos)
	#spawn_enemies_from_positions(all_valid_pos)

func place_chest_from_positions(available_positions: Array):
	if randf() < 0.2 and available_positions.size() > 0:
		chest_positions.append(available_positions.pop_front())

func spawn_enemies_from_positions(available_positions: Array):
	calculate_challenge_rating()
	var remaining_cr = challenge_rating  
	
	if available_positions.size() == 0:
		return
	
	if challenge_rating <= 2:
		if available_positions.size() > 0:
			enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': 2
			})
			remaining_cr -= 2
	else:
			# For larger rooms, use a more strategic approach
		# Prioritize having at least one level 2+ enemy
		var has_strong_enemy = false
		
		while remaining_cr > 0 and available_positions.size() > 0:
			var enemy_level: int
			
			# Ensure we have at least one level 2+ enemy for the first spawn
			if not has_strong_enemy and remaining_cr >= 2:
				enemy_level = randi_range(2, min(3, remaining_cr))
				has_strong_enemy = true
			else:
				# Choose enemy level based on remaining CR
				if remaining_cr >= 3:
					# Can afford any level enemy
					enemy_level = randi_range(1, 3)
				elif remaining_cr >= 2:
					# Can afford level 1 or 2
					enemy_level = randi_range(1, 2)
				else:
					# Only level 1
					enemy_level = 1
			
			# Don't spawn enemy if it would exceed available CR
			if enemy_level > remaining_cr:
				break
				
			enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': enemy_level
			})
			remaining_cr -= enemy_level
	
	# Debug print to verify spawning
	if enemy_positions.size() > 0:
		var total_spawned_cr = 0
		for enemy in enemy_positions:
			total_spawned_cr += enemy['level']
		print("Room CR: ", challenge_rating, " | Spawned CR: ", total_spawned_cr, " | Enemies: ", enemy_positions.size())
	
	
	
	

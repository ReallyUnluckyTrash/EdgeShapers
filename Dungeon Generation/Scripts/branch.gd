#https://jonoshields.com/post/bsp-dungeon/
#BSP approach heavily modified from jonoshields

class_name Branch
extends Node
#the left child of the node
var left_child: Branch
#the right child of the node
var right_child: Branch

#position and size of node
var position: Vector2i
var size: Vector2i

#parent reference and how deep the node is in the tree
var parent: Branch = null
var depth:int = 0

#top left and bottom right coordinates of the room inside the node
var room_top_left: Vector2i
var room_bottom_right: Vector2i 

#does node have room tracker
var has_room: bool = false

#positions for interactables in the node
var chest_positions: Array = []
var enemy_positions: Array = []
var statue_positions: Array = []

#default room type is normal enemy room type
var room_type: RoomGrammar.RoomTypes = RoomGrammar.RoomTypes.NORMAL_ENEMY

#tracks which rooms this room is connected to via corridors
var connected_rooms: Array[Branch] = []
var original_corridors = []

#initialize function
func _init(_position:Vector2i, _size:Vector2i, _parent: Branch = null) -> void:
	self.position = _position
	self.size = _size
	self.parent = _parent
	
	#if is root node (no parents) set depth at 0, otherwise take parents depth and add 1
	if parent == null:
		depth = 0
	else:
		depth = parent.depth + 1

#recurisve function to retrieve self and children nodes
func get_leaves()->Array[Branch]:
	if not(left_child && right_child):
		return[self]
	else:
		return left_child.get_leaves() + right_child.get_leaves()

#retrieves room center coords by calculating top left and bottom right cooridnates
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
	
	#uses rng to keep the split to a ratio of 30% to 70%
	var rng = RandomNumberGenerator.new()
	var split_percent = rng.randf_range(0.3, 0.7)
	
	# if height is greater than width than split horizontally instead of vertically
	var split_horizontal = size.y >= size.x
	
	#split horizontally, create two children with the same vertical size but split horizontal size
	if(split_horizontal):
		var left_height = int(size.y * split_percent)
		left_child = Branch.new(position, Vector2i(size.x, left_height), self)
		right_child = Branch.new(
			Vector2i(position.x, position.y + left_height),
			Vector2i(size.x, size.y - left_height),
			self
			)
	#split vertically, create two children with the same horizontal size but split vertical size
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
func create_room()->void:
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

#gets all nodes and creates room in each node
func create_all_rooms()->void:
	var leaves = get_leaves()
	for leaf in leaves:
		leaf.create_room()

#build connected room references in self and children
func build_connections()->void:
	var corridors = get_corridors()
	var leaves = get_leaves()
	
	#clear existing connections
	for leaf in leaves:
		leaf.connected_rooms.clear()
	
	original_corridors = corridors
	
	print("Branch.gd::Building connections with %d corridors for %d rooms" % [corridors.size(), leaves.size()])
	
	#build connections based on corridors 
	for corridor in corridors:
		var start_pos = corridor['start']
		var end_pos = corridor['end']
				
		#find rooms that contain or are adjacent to corridor endpoints
		var room1 = _find_room_for_corridor_endpoint(start_pos, leaves)
		var room2 = _find_room_for_corridor_endpoint(end_pos, leaves)
		
		if room1 != null and room2 != null and room1 != room2:
			#add bidirectional connection
			if not room1.connected_rooms.has(room2):
				room1.connected_rooms.append(room2)
				print("Branch.gd::Connected room at (%d,%d) with room at (%d,%d)" % 
					[room1.room_top_left.x, room1.room_top_left.y, room2.room_top_left.x, room2.room_top_left.y])
			if not room2.connected_rooms.has(room1):
				room2.connected_rooms.append(room1)
		else:
			if room1 == null:
				print("Branch.gd::Could not find room for start position (%d,%d)" % [start_pos.x, start_pos.y])
			if room2 == null:
				print("Branch.gd::Could not find room for end position (%d,%d)" % [end_pos.x, end_pos.y])
			if room1 == room2 and room1 != null:
				print("Branch.gd::Both corridor endpoints are in the same room")

#function to find corridor endpoints in room
func _find_room_for_corridor_endpoint(point: Vector2i, all_rooms: Array) -> Branch:
	#first, try exact containment (point inside room)
	for room in all_rooms:
		if room.has_room and _point_in_room_bounds(point, room):
			return room
	
	#if not found, find the closest room (for cases where corridor endpoint is just outside room)
	var closest_room = null
	var min_distance = INF
	
	for room in all_rooms:
		#skip nodes without rooms
		if not room.has_room:
			continue
		
		#checks distance from point to room, if below minimum distance, set the
		#minimum distance and closest room
		var distance = _distance_to_room(point, room)
		if distance < min_distance:
			min_distance = distance
			closest_room = room
	
	#only accept if reasonably close (within 2 tiles)
	if min_distance <= 2.0:
		return closest_room
	
	return null

#function to check if point is indeed inside room boundaries
func _point_in_room_bounds(point: Vector2i, room: Branch) -> bool:
	return (point.x >= room.room_top_left.x and point.x < room.room_bottom_right.x and
			point.y >= room.room_top_left.y and point.y < room.room_bottom_right.y)

#function to alculate distance from point to room
func _distance_to_room(point: Vector2i, room: Branch) -> float:
	var room_center = room.get_room_center()
	return point.distance_to(room_center)

#function to retrive center points from children
func _get_child_center(node: Branch) -> Vector2i:
	#direct room center if this node has a room
	if node.has_room:
		return node.get_room_center()
	
	#for nodes without rooms, find the best representative center
	if node.left_child or node.right_child:
		var centers = []
		
		if node.left_child:
			var left_center = _get_child_center(node.left_child)
			if left_center != Vector2i.ZERO:
				centers.append(left_center)
		
		if node.right_child:
			var right_center = _get_child_center(node.right_child)
			if right_center != Vector2i.ZERO:
				centers.append(right_center)
		
		# Return first valid center found
		if centers.size() > 0:
			return centers[0]
	
	return Vector2i.ZERO

#function to check if this room has a neighbor of a specific type
func has_neighbor_of_type(target_type: RoomGrammar.RoomTypes, all_rooms: Array[Branch], current_types: Array[RoomGrammar.RoomTypes]) -> bool:
	for connected_room in connected_rooms:
		#find the index of this connected room in the all_rooms array
		var room_index = all_rooms.find(connected_room)
		if room_index != -1:
			var current_room_type = current_types[room_index]
			if current_room_type == target_type:
				return true
	return false

#check if this room is a dead-end (only one connection)
func is_dead_end() -> bool:
	return connected_rooms.size() == 1

#function to return an array containing all corridors
func get_corridors()->Array[Dictionary]:
	var corridors:Array[Dictionary] = []
	_collect_corridors(corridors)
	return corridors

func _collect_corridors(corridors:Array[Dictionary]):
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

#function to retrieve all valid positions that interactables/enemies can be placed
#ignores room centers as valid positions
func get_all_valid_positions() -> Array[Vector2i]:
	var valid_positions:Array[Vector2i] = []
	var room_center = get_room_center()
	var min_distance_from_center = 1
	
	for x in range(room_top_left.x + 1, room_bottom_right.x - 1):
		for y in range(room_top_left.y + 1, room_bottom_right.y - 1):
			var pos = Vector2i(x, y)
			if pos.distance_to(room_center) >= min_distance_from_center:
				valid_positions.append(pos)
	
	return valid_positions

#set entities spawn positions by applying room type on to the node
func set_object_spawn_positions()->void:
	if not has_room:
		return
	RoomTypeHandler.apply_room_type(self, room_type)

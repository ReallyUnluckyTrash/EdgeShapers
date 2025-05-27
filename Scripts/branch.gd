extends Node

class_name Branch

var left_child: Branch
var right_child: Branch
var position: Vector2i
var size: Vector2i
var room_top_left: Vector2i
var room_bottom_right: Vector2i 
var has_room: bool = false


func _init(position, size) -> void:
	self.position = position
	self.size = size
	
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
	
	var min_room_size = Vector2i(4,4)
	var padding = Vector2i(1,1)
	
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

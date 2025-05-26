extends Node

class_name Branch

var left_child: Branch
var right_child: Branch
var position: Vector2i
var size: Vector2i

func _init(position, size) -> void:
	self.position = position
	self.size = size
	
func get_leaves():
	if not(left_child && right_child):
		return[self]
	else:
		return left_child.get_leaves() + right_child.get_leaves()

func get_center():
	return Vector2i(position.x + size.x / 2, position.y + size.y / 2)
		
func split(split_count, paths):
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
	
	paths.push_back({'left': left_child.get_center(), 'right': right_child.get_center()})
	
	if(split_count > 0):
		left_child.split(split_count - 1, paths)
		right_child.split(split_count - 1, paths)
	pass

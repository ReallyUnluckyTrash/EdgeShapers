extends Node2D

var root_node: Branch
var tile_size: int = 64
var tilemaplayer: TileMapLayer

@export var map_width: int = 60
@export var map_height: int = 30

var min_cell_size: Vector2i

var floor_tile = Vector2i(17, 8)


func _ready() -> void:
	tilemaplayer = get_node("TileMapLayer")
	min_cell_size = Vector2i(map_width/4, map_height/4)
	generate_dungeon()
	
func generate_dungeon():
	root_node = Branch.new(Vector2i(0, 0), Vector2i(map_width, map_height))
	
	root_node.split(min_cell_size)
	
	root_node.create_all_rooms()
	
	queue_redraw()
	
func _draw():
	if not root_node:
		return
	
	_draw_partitions(root_node)
	
	_draw_rooms()
	
	_draw_corridors()
	
	pass

func _draw_partitions(node: Branch):
	# Draw outline of current partition
	draw_rect(
		Rect2(
			node.position.x * tile_size,
			node.position.y * tile_size,
			node.size.x * tile_size,
			node.size.y * tile_size
		),
		Color.GREEN,
		false
	)
	
	# Recursively draw child partitions
	if node.left_child:
		_draw_partitions(node.left_child)
	if node.right_child:
		_draw_partitions(node.right_child)

func _draw_rooms():
	var leaves = root_node.get_leaves()
	
	for leaf in leaves:
		if leaf.has_room:
			# Draw room outline
			#draw_rect(
				#Rect2(
					#leaf.room_top_left.x * tile_size,
					#leaf.room_top_left.y * tile_size,
					#(leaf.room_bottom_right.x - leaf.room_top_left.x) * tile_size,
					#(leaf.room_bottom_right.y - leaf.room_top_left.y) * tile_size
				#),
				#Color.BLUE,
				#false
			#)
		
		#tile placement
			for x in range(leaf.room_top_left.x, leaf.room_bottom_right.x):
					for y in range(leaf.room_top_left.y, leaf.room_bottom_right.y):
						tilemaplayer.set_cell(Vector2i(x, y), 4, floor_tile)
			
	pass

func _draw_corridors():
	var corridors = root_node.get_corridors()
	
	for corridor in corridors:
		var start = corridor['start']
		var end = corridor['end']
		
		## Draw corridor outline for visualization
		#draw_line(
			#Vector2(start.x * tile_size + tile_size/2, start.y * tile_size + tile_size/2),
			#Vector2(end.x * tile_size + tile_size/2, end.y * tile_size + tile_size/2),
			#Color.RED,
			#3
		#)
		
		# Create L-shaped corridor (horizontal then vertical)
		_create_corridor_tiles(start, end)
	pass

func _create_corridor_tiles(start: Vector2i, end: Vector2i):
	# Create L-shaped corridor: horizontal first, then vertical
	
	# Horizontal segment
	var start_x = min(start.x, end.x)
	var end_x = max(start.x, end.x)
	for x in range(start_x, end_x + 1):
		tilemaplayer.set_cell(Vector2i(x, start.y), 4, floor_tile)
	
	# Vertical segment
	var start_y = min(start.y, end.y)
	var end_y = max(start.y, end.y)
	for y in range(start_y, end_y + 1):
		tilemaplayer.set_cell(Vector2i(end.x, y), 4, floor_tile)
	

extends Node2D

var root_node: Branch
var tile_size: int = 64
var tilemaplayer: TileMapLayer

var paths: Array = []

func _ready() -> void:
	tilemaplayer = get_node("TileMapLayer")
	root_node = Branch.new(Vector2i(0, 0), Vector2i(60, 30))
	root_node.split(2, paths)
	queue_redraw()
	pass
	
func _draw():
	for leaf in root_node.get_leaves():
		var rng = RandomNumberGenerator.new()
		
		#padding to space out room from split section
		var padding = Vector4i(
			rng.randi_range(1,2),
			rng.randi_range(1,2),
			rng.randi_range(1,2),
			rng.randi_range(1,2)
		)
		
		#outline the split spaces
		draw_rect(
			Rect2(
				leaf.position.x * tile_size, # x
				leaf.position.y * tile_size, # y
				leaf.size.x * tile_size, # width
				leaf.size.y * tile_size # height
			), 
			Color.GREEN, # colour
			false # is filled
		)
		
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				#check if placed layer will be inside padding or not
				if not inside_padding(x, y, leaf, padding):
					tilemaplayer.set_cell(Vector2i(x + leaf.position.x, y + leaf.position.y), 4, Vector2i(17, 8))
		
		for path in paths:
			if path['left'].y == path['right'].y:
				for i in range(path['right'].x - path['left'].x):
					tilemaplayer.set_cell(Vector2i(path['left'].x + i, path['left'].y ), 4, Vector2i(17, 8))
			else:
				for i in range(path['right'].y - path['left'].y):
					tilemaplayer.set_cell(Vector2i(path['left'].x, path['left'].y + i ), 4, Vector2i(17, 8))
	pass
	
func inside_padding(x, y, leaf, padding):
	var inside_x =  x <= padding.x
	var inside_y =  y <= padding.y
	var inside_z =  x >= leaf.size.x - padding.z
	var inside_w =  y >= leaf.size.y - padding.w
	return inside_x or inside_y or inside_z or inside_w

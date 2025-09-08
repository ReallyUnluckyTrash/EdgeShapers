extends Level

var root_node: Branch
#var object_spawner: ObjectSpawner
#var dungeon_config: DungeonConfig

@export var map_width: int = 60
@export var map_height: int = 30

var entrance_pos: Vector2i
var exit_pos: Vector2i

var entrance_room: Branch = null
var exit_room: Branch = null

@onready var floor_transition_tile: FloorTransition = $FloorTransition

@onready var dungeon_config: DungeonConfig = $DungeonConfig
@onready var object_spawner: ObjectSpawner = $ObjectSpawner
@onready var dungeon_renderer: DungeonRenderer = $DungeonRenderer
@onready var floor_layer: TileMapLayer = $Floor
@onready var walls_layer: TileMapLayer = $Walls

var room_grammar:RoomGrammar

@export var music_array:Array[AudioStream] = []

func _ready() -> void:
	if PlayerManager.current_floor == 1:
		map_width = 30
		map_height = 30
	elif PlayerManager.current_floor == 2:
		map_width = 30
		map_height = 30
	elif PlayerManager.current_floor == 3:
		map_width = 40
		map_height = 30
	else:
		map_width = 60
		map_height = 30
	
	initialize_components()
	generate_dungeon()
	if PlayerManager.current_floor > 4:
		AudioManager.play_music(music_array[randi_range(2, 3)])
	else:
		AudioManager.play_music(music_array[randi_range(0, 1)])

func initialize_components():
	self.y_sort_enabled = true
	PlayerManager.set_as_parent(self)
	
	dungeon_config.setup(map_width, map_height)
	
	dungeon_renderer.setup(floor_layer, walls_layer, dungeon_config)
	
	object_spawner.setup(self, dungeon_config)
	
	#TODO
	room_grammar = RoomGrammar.new()
	
	LevelManager.level_load_started.connect(_free_level)
	


func generate_dungeon():
	print("Generating dungeon!")
	# Step 1: Start with entire dungeon area (root node)
	root_node = Branch.new(Vector2i(0, 0), Vector2i(map_width, map_height))
	
	# Steps 2-6: Divide areas recursively until minimal size is reached
	root_node.split(dungeon_config.min_cell_size)
	
	# Steps 7-8: Create rooms in each partition cell
	root_node.create_all_rooms()
	
	#root_node.get_corridors() 
	
	root_node.build_connections()
	
	_apply_room_grammar()
	
	#set tiles on the map
	dungeon_renderer.render_dungeon(root_node)
	
	#place entities (such as enemies and chests) and set the entrance and exit points
	_place_entrance_exit()
	object_spawner._place_objects(root_node, entrance_room)
	
	#set the player and exit collision to their proper positions and change camera bounds
	PlayerManager.set_player_position(floor_layer.map_to_local(entrance_pos))
	floor_transition_tile.global_position = floor_layer.map_to_local(exit_pos)
	LevelManager.change_tilemap_bounds(_set_camera_bounds())

	queue_redraw()
	

func _draw():
	if not root_node:
		return
	
	# Draw partition boundaries (for debugging)
	#_draw_partitions(root_node)

func _draw_partitions(node: Branch):
	# Draw outline of current partition
	draw_rect(
		Rect2(
			node.position.x * dungeon_config.tile_size,
			node.position.y * dungeon_config.tile_size,
			node.size.x * dungeon_config.tile_size,
			node.size.y * dungeon_config.tile_size
		),
		Color.GREEN,
		false
	)
	
	# Recursively draw child partitions
	if node.left_child:
		_draw_partitions(node.left_child)
	if node.right_child:
		_draw_partitions(node.right_child)


func _place_entrance_exit():
	var leaves = root_node.get_leaves()
	var rooms_with_space = []
	
	# Only consider leaves that actually have rooms
	for leaf in leaves:
		if leaf.has_room:
			rooms_with_space.append(leaf)
	
	if rooms_with_space.size() >= 2:
		entrance_room = rooms_with_space[0]
		entrance_pos = entrance_room.get_room_center()
		floor_layer.set_cell(entrance_pos, 4, dungeon_config.entrance_tile)
		
		exit_room = rooms_with_space[-1]
		exit_pos = exit_room.get_room_center()
		floor_layer.set_cell(exit_pos, 4, dungeon_config.exit_tile)

	else:
		print("Warning: Not enough rooms for entrance/exit placement, regenerating dungeon")
		_on_floor_transition_regenerate_dungeon()

func _set_camera_bounds() -> Array[Vector2]:
	var bounds : Array[Vector2] = []
	var used_rect = walls_layer.get_used_rect()
	
	# Get actual world bounds
	var top_left = walls_layer.map_to_local(used_rect.position)
	var bottom_right = floor_layer.map_to_local(used_rect.end - Vector2i.ONE)
	
	#var tile_size = tilemaplayer.tile_set.tile_size
	top_left -= Vector2(dungeon_config.tile_size, dungeon_config.tile_size) / 2
	bottom_right += Vector2(dungeon_config.tile_size, dungeon_config.tile_size) / 2
	
	bounds.append(top_left)
	bounds.append(bottom_right)
	
	return bounds

func _apply_room_grammar()->void:
	var leaves = root_node.get_leaves()
	var rooms_with_space:Array[Branch] = []
	
	for leaf in leaves:
		if leaf.has_room:
			rooms_with_space.append(leaf)
	
	if rooms_with_space.is_empty():
		return
	
	var room_types = room_grammar.apply_grammar(rooms_with_space)
	
	for i in range(rooms_with_space.size()):
		rooms_with_space[i].room_type = room_types[i]
		print("Room %d: %s (Area: %d)" % [i, room_grammar._room_type_to_string(rooms_with_space[i].room_type), 
			(rooms_with_space[i].room_bottom_right.x - rooms_with_space[i].room_top_left.x) * 
			(rooms_with_space[i].room_bottom_right.y - rooms_with_space[i].room_top_left.y)])
		print("Room has these many connections: " + str(rooms_with_space[i].connected_rooms.size()))
	

#TODO
#adjust!
func _on_floor_transition_regenerate_dungeon() -> void:
	print("regenerate the floor!")
	await SceneTransition.fade_out()
	
	UpgradeChoiceMenu.show_menu()
	
	SceneTransition.fade_in()
	generate_dungeon()
	pass

func _free_level()->void:
	PlayerManager.unparent_player(self)
	LevelManager.reset_tilemap_bounds()
	queue_free()

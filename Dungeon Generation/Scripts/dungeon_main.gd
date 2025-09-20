#main dungeon script
extends Level

#root node reference
var root_node: Branch

#base map width and height
@export var map_width: int = 60
@export var map_height: int = 30

#entrance and exit position trackers
var entrance_pos: Vector2i
var exit_pos: Vector2i

#entrance and exit room trackers
var entrance_room: Branch = null
var exit_room: Branch = null

@onready var floor_transition_tile: FloorTransition = $FloorTransition
@onready var dungeon_config: DungeonConfig = $DungeonConfig
@onready var object_spawner: ObjectSpawner = $ObjectSpawner
@onready var dungeon_renderer: DungeonRenderer = $DungeonRenderer
@onready var floor_layer: TileMapLayer = $Floor
@onready var walls_layer: TileMapLayer = $Walls

#room grammar variable
var room_grammar: RoomGrammar

#music array containing what music can be played in the dungeon floors
@export var music_array: Array[AudioStream] = []

func _ready() -> void:
	#changes map size based on current floor, earlier floors have smaller sizes
	#later floors have a set size
	if PlayerManager.current_floor == 1:
		map_width = 30
		map_height = 30
	elif PlayerManager.current_floor == 2:
		map_width = 40
		map_height = 30
	elif PlayerManager.current_floor == 3:
		map_width = 50
		map_height = 30
	else:
		map_width = 60
		map_height = 30
	
	#initialize components, dungeon config, object spawner and renderer
	initialize_components()
	
	#generate the dungeon!
	generate_dungeon()
	
	#different music choices for easier and latter stages
	if PlayerManager.current_floor > 4:
		AudioManager.play_music(music_array[randi_range(2, 3)])
	else:
		AudioManager.play_music(music_array[randi_range(0, 1)])

#function to setup all classes
func initialize_components()->void:
	self.y_sort_enabled = true
	#set self as player's parent
	PlayerManager.set_as_parent(self)
	
	#initialize and setup all other classes
	dungeon_config.setup(map_width, map_height)
	dungeon_renderer.setup(floor_layer, walls_layer, dungeon_config)
	object_spawner.setup(self, dungeon_config)
	room_grammar = RoomGrammar.new()
	
	#connect level load started signal with _free_level function
	LevelManager.level_load_started.connect(_free_level)

func generate_dungeon()->void:
	print("Generating dungeon!")
	# Step 1: Start with entire dungeon area (root node)
	root_node = Branch.new(Vector2i(0, 0), Vector2i(map_width, map_height))
	
	# Steps 2-6: Divide areas recursively until minimal size is reached
	root_node.split(dungeon_config.min_partition_size)
	
	# Steps 7-8: Create rooms in each partition cell
	root_node.create_all_rooms()
	
	# Build connections between rooms
	root_node.build_connections()
	
	# Apply the new room type determining system
	_apply_room_grammar()
	
	# Set tiles on the map
	dungeon_renderer.render_dungeon(root_node)
	
	# Place entities and set entrance/exit points
	_place_entrance_exit()
	object_spawner._place_objects(root_node, entrance_room)
	
	# Set player and exit positions and change camera bounds to fit dungeon space
	PlayerManager.set_player_position(floor_layer.map_to_local(entrance_pos))
	floor_transition_tile.global_position = floor_layer.map_to_local(exit_pos)
	LevelManager.change_tilemap_bounds(_set_camera_bounds())

	queue_redraw()

func _draw():
	if not root_node:
		return
	
	#draw partition boundaries (for debugging)
	#_draw_partitions(root_node)



func _draw_partitions(node: Branch)->void:
	#draw if this partition has a room
	if node.has_room:
		var rect = Rect2(
			node.position.x * dungeon_config.tile_size,
			node.position.y * dungeon_config.tile_size,
			node.size.x * dungeon_config.tile_size,
			node.size.y * dungeon_config.tile_size
		)
		
		#get color based on room type
		var room_color = _get_room_type_color(node.room_type)
		
		#draw filled rectangle with 50% transparency
		draw_rect(rect, Color(room_color.r, room_color.g, room_color.b, 0.5), true)
		
		#draw border for clarity
		draw_rect(rect, room_color, false, 2.0)
		
		#draw room type label
		var room_type_text = _terminal_to_string(node.room_type)
		var font = ThemeDB.fallback_font
		var font_size = 80
		
		#calculate text position (center of room)
		var text_size = font.get_string_size(room_type_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var text_pos = Vector2(
			rect.position.x + (rect.size.x - text_size.x) / 2,
			rect.position.y + (rect.size.y + text_size.y) / 2
		)
		
		#draw text background for readability
		var bg_rect = Rect2(text_pos - Vector2(4, text_size.y + 2), text_size + Vector2(8, 4))
		draw_rect(bg_rect, Color(0, 0, 0, 0.7), true)
		
		#draw the text
		draw_string(font, text_pos, room_type_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)
	
	#recursively draw child partitions
	if node.left_child:
		_draw_partitions(node.left_child)
	if node.right_child:
		_draw_partitions(node.right_child)

func _place_entrance_exit()->void:
	#get all nodes
	var leaves = root_node.get_leaves()
	var rooms_with_space:Array[Branch] = []
	
	# Only consider leaves that actually have rooms
	for leaf in leaves:
		if leaf.has_room:
			rooms_with_space.append(leaf)
	
	#sets entrance and exit tiles and entrance and exit positions 
	if rooms_with_space.size() >= 2:
		entrance_room = rooms_with_space[0]
		entrance_pos = entrance_room.get_room_center()
		floor_layer.set_cell(entrance_pos, 4, dungeon_config.entrance_tile)
		
		exit_room = rooms_with_space[-1]
		exit_pos = exit_room.get_room_center()
		floor_layer.set_cell(exit_pos, 4, dungeon_config.exit_tile)
	else:
		print("DungeonMain.gd::Not enough rooms for entrance/exit placement, regenerating dungeon")
		generate_dungeon()

func _set_camera_bounds() -> Array[Vector2]:
	#get bounds from walls tilemaplayer
	var bounds: Array[Vector2] = []
	var used_rect = walls_layer.get_used_rect()
	
	#get actual world bounds
	var top_left = walls_layer.map_to_local(used_rect.position)
	var bottom_right = floor_layer.map_to_local(used_rect.end - Vector2i.ONE)
	
	#set top left and bottom right tiles
	top_left -= Vector2(dungeon_config.tile_size, dungeon_config.tile_size) / 2
	bottom_right += Vector2(dungeon_config.tile_size, dungeon_config.tile_size) / 2
	
	bounds.append(top_left)
	bounds.append(bottom_right)
	
	return bounds
	
func _apply_room_grammar() -> void:
	#retrieve all nodes with rooms from root node
	var leaves = root_node.get_leaves()
	var rooms:Array[Branch] = []
	
	for leaf in leaves:
		if leaf.has_room:
			rooms.append(leaf)
	
	#if rooms is empty return
	if rooms.is_empty():
		return
	
	#apply grammar on all the rooms, then set the object spawn positions
	var room_types = room_grammar.apply_grammar(rooms)
	for i in range(rooms.size()):
		rooms[i].room_type = room_types[i]
		rooms[i].set_object_spawn_positions()
		
#helper function to convert RoomTypes enum into strings
func _terminal_to_string(terminal: RoomGrammar.RoomTypes) -> String:
	match terminal:
		RoomGrammar.RoomTypes.TREASURE:
			return "TREASURE"
		RoomGrammar.RoomTypes.SUPER_TREASURE:
			return "SUPER_TREASURE"
		RoomGrammar.RoomTypes.EASY_ENEMY:
			return "EASY_ENEMY"
		RoomGrammar.RoomTypes.NORMAL_ENEMY:
			return "NORMAL_ENEMY"
		RoomGrammar.RoomTypes.HARD_ENEMY:
			return "HARD_ENEMY"
		RoomGrammar.RoomTypes.MINI_BOSS:
			return "MINI_BOSS"
		RoomGrammar.RoomTypes.ENTRANCE:
			return "ENTRANCE"
		RoomGrammar.RoomTypes.EXIT:
			return "EXIT"
		RoomGrammar.RoomTypes.EMPTY:
			return "EMPTY"
		_:
			return "UNKNOWN"

#helper function to return colors based on room types
func _get_room_type_color(room_type: RoomGrammar.RoomTypes) -> Color:
	match room_type:
		RoomGrammar.RoomTypes.ENTRANCE:
			return Color.GREEN
		RoomGrammar.RoomTypes.EXIT:
			return Color.BLUE
		RoomGrammar.RoomTypes.TREASURE:
			return Color.YELLOW
		RoomGrammar.RoomTypes.SUPER_TREASURE:
			return Color.GOLD
		RoomGrammar.RoomTypes.EASY_ENEMY:
			return Color.LIGHT_CORAL
		RoomGrammar.RoomTypes.NORMAL_ENEMY:
			return Color.ORANGE_RED
		RoomGrammar.RoomTypes.HARD_ENEMY:
			return Color.DARK_RED
		RoomGrammar.RoomTypes.MINI_BOSS:
			return Color.PURPLE
		RoomGrammar.RoomTypes.EMPTY:
			return Color.LIGHT_GRAY
		_:
			return Color.WHITE

#resets tilemaps and unparents player from self, then queue free
func _free_level() -> void:
	PlayerManager.unparent_player(self)
	LevelManager.reset_tilemap_bounds()
	queue_free()

# RoomTypeHandler.gd
class_name RoomTypeHandler extends Resource

static func apply_room_type(room: Branch, room_type: RoomGrammar.RoomType):
	# Clear existing spawn data
	room.chest_positions.clear()
	room.enemy_positions.clear()
	
	if not room.has_room:
		return
	
	var available_positions = room.get_all_valid_positions()
	available_positions.shuffle()
	
	match room_type:
		RoomGrammar.RoomType.TREASURE:
			_setup_treasure_room(room, available_positions)
		RoomGrammar.RoomType.SUPER_TREASURE:
			_setup_super_treasure_room(room, available_positions)
		RoomGrammar.RoomType.EASY_ENEMY:
			_setup_normal_enemy_room(room, available_positions)
		RoomGrammar.RoomType.NORMAL_ENEMY:
			_setup_normal_enemy_room(room, available_positions)
		RoomGrammar.RoomType.HARD_ENEMY:
			_setup_normal_enemy_room(room, available_positions)
		RoomGrammar.RoomType.MINI_BOSS:
			_setup_mini_boss_room(room, available_positions)
		RoomGrammar.RoomType.ENTRANCE:
			_setup_normal_enemy_room(room, available_positions)
		RoomGrammar.RoomType.EXIT:
			_setup_normal_enemy_room(room, available_positions)
		
		_:
			# Default fallback
			_setup_normal_enemy_room(room, available_positions)

static func _setup_treasure_room(room: Branch, available_positions: Array):
	# 3 level 3 enemies + 1 chest
	var room_area = _get_room_area(room)
	
	# Base spawns
	var enemy_count = 1
	var chest_count = 1
	
	# Scale with room size
	if room_area > 20:
		enemy_count += 1  # Add one more enemy for larger rooms
	if room_area > 30:
		enemy_count += 1  # Add bonus chest for very large rooms
	if room_area > 40:
		enemy_count += 1  # Add bonus chest for very large rooms
	
	# Place chest first
	for i in range(min(chest_count, available_positions.size())):
		room.chest_positions.append(available_positions.pop_front())
	
	# Place enemies
	for i in range(min(enemy_count, available_positions.size())):
		room.enemy_positions.append({
			'position': available_positions.pop_front(),
			'level': 2
		})

static func _setup_super_treasure_room(room: Branch, available_positions: Array):
	# 3+ treasure chests, no enemies (it's a reward room!)
	var room_area = _get_room_area(room)
	
	var chest_count = 3
	
	# More chests for larger rooms
	if room_area > 30:
		chest_count += 1
	if room_area > 40:
		chest_count += 1
	
	# Place all chests
	for i in range(min(chest_count, available_positions.size())):
		room.chest_positions.append(available_positions.pop_front())

static func _setup_easy_enemy_room(room: Branch, available_positions: Array):
	var room_area = _get_room_area(room)
	var base_enemies = 1
	
	# Scale enemies with room size
	var enemy_count = base_enemies
	if room_area > 15:
		enemy_count += 1
	if room_area > 25:
		enemy_count += 1
	
	# Place enemies
	for i in range(min(enemy_count, available_positions.size())):
		if i == 0:
			room.enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': 1
			})
		elif i < 2:
			room.enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': randi_range(1,2)
			})
	
	pass

static func _setup_normal_enemy_room(room: Branch, available_positions: Array):
	var room_area = _get_room_area(room)
	var base_enemies = 2
	
	# Scale enemies with room size
	var enemy_count = base_enemies
	if room_area > 15:
		enemy_count += 1
	if room_area > 25:
		enemy_count += 1
	
	# Place enemies
	for i in range(min(enemy_count, available_positions.size())):
		if i == 0:
			room.enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': 1
			})
		elif i < 2:
			room.enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': randi_range(1,2)
			})
		else:
			room.enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': randi_range(2,3)
			})

static func _setup_hard_enemy_room(room: Branch, available_positions: Array):
	var room_area = _get_room_area(room)
	var base_enemies = 3
	
	# Scale enemies with room size
	var enemy_count = base_enemies
	if room_area > 20:
		enemy_count += 1
	if room_area > 30:
		enemy_count += 2
	if room_area > 40:
		enemy_count += 1
	
	# Place enemies
	for i in range(min(enemy_count, available_positions.size())):
		room.enemy_positions.append({
			'position': available_positions.pop_front(),
			'level': randi_range(2,3)
		})
	pass

static func _setup_mini_boss_room(room: Branch, available_positions: Array):
	# 1 high-level enemy + support enemies, guaranteed chest
	var room_area = _get_room_area(room)

	# Mini-boss (level 4/5 enemy)
	if available_positions.size() > 0:
		var boss_level = 4 
		room.enemy_positions.append({
			'position': room.get_room_center(),
			'level': boss_level
		})
	
	if available_positions.size() > 0:
		room.chest_positions.append(available_positions.pop_front())
	
	

static func _setup_entrance_room(room: Branch, available_positions: Array):
	print("entrance room setup!")
	pass

static func _setup_exit_room(room: Branch, available_positions: Array):
	print("exit room setup!")
	pass

#func _place_entrance_exit():
	#var leaves = root_node.get_leaves()
	#var rooms_with_space = []
	#
	## Only consider leaves that actually have rooms
	#for leaf in leaves:
		#if leaf.has_room:
			#rooms_with_space.append(leaf)
	#
	#if rooms_with_space.size() >= 2:
		#entrance_room = rooms_with_space[0]
		#entrance_pos = entrance_room.get_room_center()
		#tile_map_layer.set_cell(entrance_pos, 4, dungeon_config.entrance_tile)
		#
		#exit_room = rooms_with_space[-1]
		#exit_pos = exit_room.get_room_center()
		#tile_map_layer.set_cell(exit_pos, 4, dungeon_config.exit_tile)


static func _get_room_area(room: Branch) -> int:
	return (room.room_bottom_right.x - room.room_top_left.x) * (room.room_bottom_right.y - room.room_top_left.y)

#RoomTypeHandler.gd
#determines what spawns in what room 
class_name RoomTypeHandler extends Resource

static func apply_room_type(room: Branch, room_type: RoomGrammar.RoomTypes):
	#clear existing spawn data
	room.chest_positions.clear()
	room.enemy_positions.clear()
	room.statue_positions.clear()
	
	#return if does not have a room
	if not room.has_room:
		return
	
	#check all available positions
	var available_positions = room.get_all_valid_positions()
	available_positions.shuffle()
	
	#match room type with the appropriate setup function
	match room_type:
		RoomGrammar.RoomTypes.TREASURE:
			_setup_treasure_room(room, available_positions)
		RoomGrammar.RoomTypes.SUPER_TREASURE:
			_setup_super_treasure_room(room, available_positions)
		RoomGrammar.RoomTypes.EASY_ENEMY:
			_setup_easy_enemy_room(room, available_positions)
		RoomGrammar.RoomTypes.NORMAL_ENEMY:
			_setup_normal_enemy_room(room, available_positions)
		RoomGrammar.RoomTypes.HARD_ENEMY:
			_setup_hard_enemy_room(room, available_positions)
		RoomGrammar.RoomTypes.MINI_BOSS:
			_setup_mini_boss_room(room, available_positions)
		RoomGrammar.RoomTypes.ENTRANCE:
			_setup_entrance_room(room, available_positions)
		RoomGrammar.RoomTypes.EXIT:
			_setup_exit_room(room, available_positions)
		RoomGrammar.RoomTypes.EMPTY:
			_setup_empty_room(room, available_positions)
		_:
			#default fallback
			_setup_normal_enemy_room(room, available_positions)

static func _setup_treasure_room(room: Branch, available_positions: Array):
	var room_area = _get_room_area(room)
	
	#base spawns
	var enemy_count = 1
	var chest_count = 1
	
	#scale with room size
	if room_area > 20:
		enemy_count += 1
	if room_area > 30:
		enemy_count += 1
	if room_area > 40:
		enemy_count += 1
	
	#place chest first
	for i in range(min(chest_count, available_positions.size())):
		room.chest_positions.append(available_positions.pop_front())
	
	#place level 2 enemies
	for i in range(min(enemy_count, available_positions.size())):
		room.enemy_positions.append({
			'position': available_positions.pop_front(),
			'level': 2
		})

static func _setup_super_treasure_room(room: Branch, available_positions: Array):
	var room_area = _get_room_area(room)
	
	var chest_count = 3
	
	#more chests for larger rooms
	if room_area > 30:
		chest_count += 1
	if room_area > 40:
		chest_count += 1
	
	#place all chests
	for i in range(min(chest_count, available_positions.size())):
		room.chest_positions.append(available_positions.pop_front())

static func _setup_easy_enemy_room(room: Branch, available_positions: Array):
	var room_area = _get_room_area(room)
	var base_enemies = 1
	
	var enemy_count = base_enemies
	#increase enemy count based on size
	if room_area > 15:
		enemy_count += 1
	if room_area > 30:
		enemy_count += 1
	if room_area > 40:
		enemy_count += 1
	
	#when enemy count is below 3, spawn level 1 enemies, else either spawn level 1 or 2 enemies	
	for i in range(min(enemy_count, available_positions.size())):
		if i < 3:
			room.enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': 1
			})
		else:
			room.enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': randi_range(1,2)
			})

static func _setup_normal_enemy_room(room: Branch, available_positions: Array):
	var room_area = _get_room_area(room)
	var base_enemies = 2
	
	var enemy_count = base_enemies

	if room_area > 40:
		enemy_count += 1
	if room_area > 60:
		enemy_count += 1
	if room_area > 80:
		enemy_count += 1
	
	#spawn 2 level 1 enemies then level 2 and 3 enemies
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
	
	#10% chance of having a chest
	if available_positions.size() > 0 && randi_range(1,10) > 9:
		room.chest_positions.append(available_positions.pop_front())

static func _setup_hard_enemy_room(room: Branch, available_positions: Array):
	var room_area = _get_room_area(room)
	var base_enemies = 3
	
	var enemy_count = base_enemies
	if room_area > 50:
		enemy_count += 2
	if room_area > 70:
		enemy_count += 2
	if room_area > 90:
		enemy_count += 2
	
	#spawn exclusively level 2 and 3 enemies
	for i in range(min(enemy_count, available_positions.size())):
		room.enemy_positions.append({
			'position': available_positions.pop_front(),
			'level': randi_range(2,3)
		})
	
	#20% of having a chest
	if available_positions.size() > 0 && randi_range(1,10) > 8:
		room.chest_positions.append(available_positions.pop_front())

static func _setup_mini_boss_room(room: Branch, available_positions: Array):
	var room_area = _get_room_area(room)

	#spawns a mini boss enemy
	if available_positions.size() > 0: 
		room.enemy_positions.append({
			'position': room.get_room_center(),
			'level': 4
		})
	
	if available_positions.size() > 0:
		room.statue_positions.append(available_positions.pop_front())

static func _setup_entrance_room(room: Branch, available_positions: Array):
	#entrance rooms are typically safe
	pass

static func _setup_exit_room(room: Branch, available_positions: Array):
	var room_area = _get_room_area(room)
	var base_enemies = 0
	
	var enemy_count = base_enemies
	#increase enemy count based on size
	if room_area > 30:
		enemy_count += 1
	if room_area > 50:
		enemy_count += 2
	if room_area > 70:
		enemy_count += 1
	if room_area > 90:
		enemy_count += 2
	
	#increase enemy count and level together, above 3 enemies switch between levels 2 and 3
	for i in range(min(enemy_count, available_positions.size())):
		if i == 1:
			room.enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': 1
			})
		elif i == 2:
			room.enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': 2
			})
		elif i == 3:
			room.enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': 3
			})
		else:
			room.enemy_positions.append({
				'position': available_positions.pop_front(),
				'level': randi_range(2,3)
			})
	
	#20% of having a chest when exit room is big enough
	if room_area > 40:
		if available_positions.size() > 0 && randi_range(1,10) > 8:
			room.chest_positions.append(available_positions.pop_front())
	pass

static func _setup_empty_room(room: Branch, available_positions: Array):
	pass

#get room area function
static func _get_room_area(room: Branch) -> int:
	return (room.room_bottom_right.x - room.room_top_left.x) * (room.room_bottom_right.y - room.room_top_left.y)

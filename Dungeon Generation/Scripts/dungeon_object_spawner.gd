class_name ObjectSpawner extends Node

var parent_node: Node2D
var config: DungeonConfig
var spawned_enemies: Array = []
var spawned_chests:Array = []
var spawned_statues:Array = []
var chest_scene = preload("res://Interactables/Chests/treasure_chest.tscn")
var statue_scene = preload("res://Interactables/Blessing Statue/blessing_statue.tscn")

func setup(parent: Node2D, dungeon_config: DungeonConfig):
	parent_node = parent
	config = dungeon_config

#function to clear all spawns from the dungeon
func _clear_previous_spawns():
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()
	
	for chest in spawned_chests:
		if is_instance_valid(chest):
			chest.queue_free()
	spawned_chests.clear()
	
	for statue in spawned_statues:
		if is_instance_valid(statue):
			statue.queue_free()
	spawned_statues.clear()
	
#function to place all entities in the dungeon
func _place_objects(root_node:Branch, entrance_room:Branch):
	_clear_previous_spawns()
	var leaves = root_node.get_leaves()
	
	#iterate through the root node
	for i in range(0, leaves.size()):
		var leaf:Branch = leaves[i]
		
		if not leaf.has_room:
			continue
		
		#call set object spawn positions for each
		leaf.set_object_spawn_positions()
		
		#places chest based on chest positions in node
		for chest_pos in leaf.chest_positions:
			var chest_instance = chest_scene.instantiate()
			chest_instance.position = Vector2(
				chest_pos.x * config.tile_size + config.tile_size/2,
				chest_pos.y * config.tile_size + config.tile_size/2,
			)
			parent_node.add_child(chest_instance)
			spawned_chests.append(chest_instance)
		
		#places statue based on statue positions in node
		for statue_pos in leaf.statue_positions:
			var statue_instance = statue_scene.instantiate()
			statue_instance.position = Vector2(
				statue_pos.x * config.tile_size + config.tile_size/2,
				statue_pos.y * config.tile_size + config.tile_size/2,
			)
			parent_node.add_child(statue_instance)
			spawned_statues.append(statue_instance)
		
		#places enemies based on enemy positions in node
		for enemy_data in leaf.enemy_positions:
			var enemy_level = enemy_data['level']
			var enemy_pos = enemy_data['position']
			
			var random_index:int = 0
			var enemy_instance:Enemy
			
			#switches between an enchanced pool of enemies and a normal pool of enemies
			#based on if it is the harder floors or the easier floors
			if PlayerManager.current_floor > 4:
				random_index = randi_range(0, config.ench_enemy_scenes[enemy_level].size()-1)
				enemy_instance = config.ench_enemy_scenes[enemy_level][random_index].instantiate()
			else:
				random_index = randi_range(0, config.enemy_scenes[enemy_level].size()-1)
				enemy_instance = config.enemy_scenes[enemy_level][random_index].instantiate()
			
			enemy_instance.position = Vector2(
				enemy_pos.x * config.tile_size + config.tile_size/2,
				enemy_pos.y * config.tile_size + config.tile_size/2,
			)
			enemy_instance.level = enemy_level
			parent_node.add_child(enemy_instance)
			spawned_enemies.append(enemy_instance)
	
	#set items in the chest
	_set_chest_items()

#function to set what items are put in the chest
func _set_chest_items():
	#iterate through all spawned chests
	for chest in spawned_chests:
		var chest_item:ItemData = null
		
		#based on the current floor, switch between a smaller and larger pool of items
		if PlayerManager.current_floor > 4:
			chest_item = config.enhanced_chest_items[randi_range(1,config.enhanced_chest_items.size() - 1)]
		else:
			chest_item = config.chest_items[randi_range(1,config.chest_items.size() - 1)]
		
		chest.item_data = chest_item
		
		#if chest item is a weapon set quantity to 1, player can only have 1 weapon at a time
		if chest_item.type == "Weapon":
			chest.quantity = 1
		else:
		#else randomize it from 1 to 3
			chest.quantity = randi_range(1, 3)
		
		print("DungeonObjectSpawner.gd::" + chest.item_data.name + " set in chest!")
	
	pass

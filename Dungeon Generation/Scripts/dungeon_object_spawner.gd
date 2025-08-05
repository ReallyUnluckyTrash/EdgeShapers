class_name ObjectSpawner extends Node

var parent_node: Node2D
var config: DungeonConfig
var spawned_enemies: Array = []
var spawned_chests:Array = []
var chest_scene = preload("res://Interactables/Chests/treasure_chest.tscn")

func setup(parent: Node2D, dungeon_config: DungeonConfig):
	parent_node = parent
	config = dungeon_config


func _clear_previous_spawns():
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()
	
	for chest in spawned_chests:
		if is_instance_valid(chest):
			chest.queue_free()
	spawned_chests.clear()
	

func _place_objects(root_node:Branch, entrance_room:Branch):
	_clear_previous_spawns()
	var leaves = root_node.get_leaves()
	for i in range(0, leaves.size()):
		var leaf = leaves[i]
		
		if leaf == entrance_room:
			print("skip the entrance room for object placement")
			continue
		
		if not leaf.has_room:
			continue
		
		leaf.set_object_spawn_positions()
		
		for chest_pos in leaf.chest_positions:
			var chest_instance = chest_scene.instantiate()
			chest_instance.position = Vector2(
				chest_pos.x * config.tile_size + config.tile_size/2,
				chest_pos.y * config.tile_size + config.tile_size/2,
			)
			parent_node.add_child(chest_instance)
			spawned_chests.append(chest_instance)
		
		for enemy_data in leaf.enemy_positions:
			var enemy_level = enemy_data['level']
			var enemy_pos = enemy_data['position']
			
			var enemy_instance = config.enemy_scenes[enemy_level].instantiate()
			enemy_instance.position = Vector2(
				enemy_pos.x * config.tile_size + config.tile_size/2,
				enemy_pos.y * config.tile_size + config.tile_size/2,
			)
			enemy_instance.level = enemy_level
			parent_node.add_child(enemy_instance)
			spawned_enemies.append(enemy_instance)
	
	_set_chest_items()

func _set_chest_items():
	for chest in spawned_chests:
		var chest_item = config.chest_items[randi_range(0,2)]
				
		chest.item_data = chest_item
		
		if chest_item.type == "Weapon":
			chest.quantity = 1
		else:
			chest.quantity = randi_range(1, 5)
		
		print(chest.item_data.name + " set in chest!")
	
	pass

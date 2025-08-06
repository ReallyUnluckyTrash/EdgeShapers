class_name Weapon extends Node

@export var weapon_name: String
@export var damage: int	= 1: set = set_damage
@export var ep_cost:float = 0.0

signal attack_finished
signal attack_interrupted

func _ready() -> void:
	pass

func attack():
	pass

func set_damage(new_damage:int):
		damage = new_damage

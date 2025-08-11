class_name Weapon extends Node

@export var weapon_name: String
@export var damage: int	= 1: set = set_damage
@export var ep_cost:float = 0.0
@export var attack_speed: float : set = set_attack_speed

signal attack_finished
signal attack_interrupted

func _ready() -> void:
	pass

func attack():
	pass

func set_damage(new_damage:int):
		damage = new_damage

func set_attack_speed(new_attack_speed:float):
	attack_speed = new_attack_speed

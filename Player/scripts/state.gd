class_name State extends Node

#Stores a reference to the player this state belongs to
static var player: Player

func enter() -> void:
	pass
	
func exit() -> void:
	pass
	
func process(_delta : float) -> State:
	return null
	
func physics(_delta : float) -> State:
	return null
	
func handle_input(_event: InputEvent) -> State:
	return null

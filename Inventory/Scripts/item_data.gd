class_name ItemData extends Resource

@export var name: String = ""
@export var type:String = ""
@export_multiline var description = ""
@export var texture: Texture2D
@export var price:int 

#for weapons
@export var scene:PackedScene

@export var effects:Array[ItemEffect]

func use()->bool:
	if effects.size() == 0:
		print("Item does nothing!")
		return false
	
	for effect in effects:
		effect.use()
	return true

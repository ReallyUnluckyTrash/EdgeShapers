class_name Upgrade extends Resource

enum Rarity{
	COMMON, 
	RARE,
	EPIC
}
 
@export var upgrade_name:String
@export var upgrade_description:String
@export var rarity:Rarity
@export var value:int

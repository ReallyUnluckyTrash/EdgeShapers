class_name UpgradeWeaponDamage extends UpgradeWeapon

@export var additional_damage:int = 1

func apply_upgrade(weapon:Weapon):
	weapon.damage += additional_damage
	pass

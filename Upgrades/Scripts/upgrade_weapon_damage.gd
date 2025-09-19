class_name UpgradeWeaponDamage extends UpgradeWeapon

@export var additional_damage:int = 1

func apply_upgrade(weapon:Weapon):
	weapon.damage += additional_damage
	PlayerManager.player.damage_boost += additional_damage
	print("UpgradeWeaponDamage:: " + str(weapon.damage))
	pass

class_name UpgradeWeaponAttackSpeed extends UpgradeWeapon

@export var additional_attack_speed:float = 0.1
@export var minimum_attack_speed:float = 0.1

func apply_upgrade(weapon:Weapon):
	weapon.attack_speed += additional_attack_speed
	PlayerManager.player.attack_speed += additional_attack_speed
	pass

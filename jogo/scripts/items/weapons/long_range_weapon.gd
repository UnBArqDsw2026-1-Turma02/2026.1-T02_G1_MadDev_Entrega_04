## Decorator Pattern — arma de longo alcance: projétil convencional em linha reta.
class_name LongRangeWeapon
extends WeaponItem

@export var data: WeaponData


func on_equip(player: Node) -> void:
	super.on_equip(player)
	if data:
		player.set("shoot_cooldown", data.shoot_cooldown)
		player.set("_weapon_type", &"long")


func on_unequip(player: Node) -> void:
	super.on_unequip(player)
	player.set("_weapon_type", &"")

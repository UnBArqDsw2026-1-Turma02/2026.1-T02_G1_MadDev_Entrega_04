## Decorator Pattern — arma de curto alcance: projétil que vai e volta.
class_name ShortRangeWeapon
extends WeaponItem

@export var data: WeaponData


func on_equip(player: Node) -> void:
	super.on_equip(player)
	if data:
		player.set("shoot_cooldown", data.shoot_cooldown)
		player.set("_weapon_type", &"short")


func on_unequip(player: Node) -> void:
	super.on_unequip(player)
	player.set("_weapon_type", &"")

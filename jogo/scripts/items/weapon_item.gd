## Decorator Pattern — arma equipável. Slot sempre HEAD (posição 0) por convenção de arma.
class_name WeaponItem
extends EquipmentItem

@export var weapon_data: WeaponData


func _init() -> void:
	slot = 0  # EquipSlot.HEAD usado como slot de arma

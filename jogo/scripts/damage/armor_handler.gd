@tool
class_name ArmorHandler
extends DamageHandler

func handle(damage: int, context: Dictionary) -> int:
	var target = context.get("target")
	var armor_value = 0
	
	if target and "defense" in target:
		armor_value = target.defense
	
	var reduced_damage = maxi(0, damage - armor_value)
	return super.handle(reduced_damage, context)

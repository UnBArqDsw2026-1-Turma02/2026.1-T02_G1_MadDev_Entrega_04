@tool
class_name ResistanceHandler
extends DamageHandler

func handle(damage: int, context: Dictionary) -> int:
	var target = context.get("target")
	var resistance_pct = 0.0
	
	if target and "resistance" in target:
		resistance_pct = target.resistance
		
	var final_damage = damage * (1.0 - resistance_pct)
	return super.handle(final_damage, context)

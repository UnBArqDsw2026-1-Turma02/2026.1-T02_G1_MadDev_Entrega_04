@tool
class_name DamageHandler
extends Resource

@export var next: DamageHandler

func handle(damage: int, context: Dictionary) -> int:
	if next != null:
		return next.handle(damage, context)
	return damage

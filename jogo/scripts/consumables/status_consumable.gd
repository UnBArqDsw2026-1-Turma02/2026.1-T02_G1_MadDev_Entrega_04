## Template Method — efeito concreto: aplica +1 em atributo e +1 XP ao coletar.
class_name StatusConsumable
extends ConsumableBase

@export var attribute: String = "damage"  # "damage", "max_health", "move_speed"
@export var value: float      = 1.0
@export var xp_amount: int    = 1


func _apply_effect(collector: Node) -> void:
	var s: PlayerStats = collector.get("stats")
	if s != null:
		s.apply_modifier(attribute, value)
	GameManager.add_xp(xp_amount)

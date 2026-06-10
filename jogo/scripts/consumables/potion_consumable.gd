## Template Method — efeito concreto: restaura vida ao coletar.
class_name PotionConsumable
extends ConsumableBase

@export var heal_amount: int = 30


func _apply_effect(collector: Node) -> void:
	if collector.has_method("heal"):
		collector.heal(heal_amount)

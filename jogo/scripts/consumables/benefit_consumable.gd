## Template Method — efeito concreto: equipa benefício passivo no slot único do player.
## Decorator Pattern — subclasses sobrescrevem activate/deactivate para definir o efeito.
class_name BenefitConsumable
extends ConsumableBase


func _apply_effect(collector: Node) -> void:
	if collector.has_method("equip_benefit"):
		collector.equip_benefit(self)


## Subclasses sobrescrevem para aplicar/reverter o efeito passivo.
func activate(_player: Node) -> void:
	pass


func deactivate(_player: Node) -> void:
	pass

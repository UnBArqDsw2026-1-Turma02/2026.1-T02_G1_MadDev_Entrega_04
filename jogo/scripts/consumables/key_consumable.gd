## Template Method — efeito concreto: emite key_used para portas/baús escutarem.
class_name KeyConsumable
extends ConsumableBase


func _apply_effect(_collector: Node) -> void:
	SignalBus.key_used.emit()

## Template Method Pattern — _on_pickup() define o algoritmo base; subclasses sobrescrevem _apply_effect().
## Conexão de "body_entered" deve ser feita via inspetor apontando para _on_body_entered().
extends Area2D

# ---------------------------------------------------------------------------
# Atributos exportados (configuráveis por subclasse ou inspetor)
# ---------------------------------------------------------------------------
@export var consumable_name: String = "Consumable"
@export var auto_pickup: bool = true


# ---------------------------------------------------------------------------
# Template Method — fluxo de coleta fixo, efeito variável
# ---------------------------------------------------------------------------
func _on_body_entered(body: Node) -> void:
	if not auto_pickup:
		return
	if body.is_in_group("player"):
		_on_pickup(body)


func _on_pickup(collector: Node) -> void:
	_apply_effect(collector)
	SignalBus.item_picked_up.emit({"name": consumable_name})
	queue_free()


## Sobrescreva em subclasses para definir o efeito concreto.
func _apply_effect(_collector: Node) -> void:
	pass

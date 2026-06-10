## Decorator Pattern — classe base abstrata dos decoradores.
## Envolve um ItemBase em `wrapped` e delega get_effect() / get_value().
## Subclasses sobrescrevem esses métodos chamando super.* para empilhar efeitos.
class_name ItemDecorator
extends ItemBase

# ---------------------------------------------------------------------------
# Referência ao item envolvido (pode ser outro decorador, permitindo empilhar)
# ---------------------------------------------------------------------------
@export var wrapped: ItemBase


# ---------------------------------------------------------------------------
# Delegação — repassa as chamadas para o item envolvido
# ---------------------------------------------------------------------------
func get_effect() -> String:
	if wrapped == null:
		push_warning("ItemDecorator: wrapped nulo — retornando string vazia.")
		return ""
	return wrapped.get_effect()


func get_value() -> int:
	if wrapped == null:
		push_warning("ItemDecorator: wrapped nulo — retornando 0.")
		return 0
	return wrapped.get_value()

## Decorator Pattern — dobra a quantidade/valor do item envolvido.
## Útil para itens que aumentam a taxa de drop ou recompensa.
class_name DoubleDropDecorator
extends ItemDecorator

# ---------------------------------------------------------------------------
# Atributos do decorador
# ---------------------------------------------------------------------------
@export var multiplier: int = 2


# ---------------------------------------------------------------------------
# Override — multiplica o valor e marca o efeito
# ---------------------------------------------------------------------------
func get_effect() -> String:
	return super.get_effect() + " ×%d" % multiplier


func get_value() -> int:
	return super.get_value() * multiplier

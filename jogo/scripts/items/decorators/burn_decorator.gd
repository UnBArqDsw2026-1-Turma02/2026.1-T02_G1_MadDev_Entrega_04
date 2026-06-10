## Decorator Pattern — adiciona dano de fogo ao item envolvido.
## Soma `burn_damage` ao valor e anexa marcador visual ao efeito.
class_name BurnDecorator
extends ItemDecorator

# ---------------------------------------------------------------------------
# Atributos do decorador
# ---------------------------------------------------------------------------
@export var burn_damage: int = 5


# ---------------------------------------------------------------------------
# Override — combina o resultado da cadeia com o efeito de fogo
# ---------------------------------------------------------------------------
func get_effect() -> String:
	return super.get_effect() + " 🔥(burn +%d)" % burn_damage


func get_value() -> int:
	return super.get_value() + burn_damage

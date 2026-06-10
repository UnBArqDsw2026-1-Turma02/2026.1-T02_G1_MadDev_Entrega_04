## Decorator Pattern — eleva a raridade do item envolvido.
## Soma um bônus fixo de raridade e prefixa o efeito com marcador visual.
class_name RareDecorator
extends ItemDecorator

# ---------------------------------------------------------------------------
# Atributos do decorador
# ---------------------------------------------------------------------------
@export var rarity_bonus: int = 20


# ---------------------------------------------------------------------------
# Override — prefixa efeito e adiciona bônus de raridade ao valor
# ---------------------------------------------------------------------------
func get_effect() -> String:
	return "✨RARE✨ " + super.get_effect()


func get_value() -> int:
	return super.get_value() + rarity_bonus

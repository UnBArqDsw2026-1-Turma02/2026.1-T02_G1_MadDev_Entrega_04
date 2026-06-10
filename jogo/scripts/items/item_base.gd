## Decorator Pattern — classe base de todos os itens; define a interface
## que decoradores envolvem para adicionar comportamento em runtime.
class_name ItemBase
extends Resource

# ---------------------------------------------------------------------------
# Atributos exportados (configuráveis pelo inspetor)
# ---------------------------------------------------------------------------
@export var item_name: String = "Item"
@export var base_value: int = 10
@export var item_type: StringName = &""


# ---------------------------------------------------------------------------
# Interface do Decorator — sobrescritível por decoradores e subclasses
# ---------------------------------------------------------------------------
## Retorna a descrição de efeito do item. Decoradores concatenam ao resultado.
func get_effect() -> String:
	return item_name


## Retorna o valor numérico do item (dano, raridade, drop). Decoradores ajustam.
func get_value() -> int:
	return base_value

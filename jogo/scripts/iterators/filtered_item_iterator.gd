## Iterator Pattern — itera um Array de itens filtrando por tipo.
## Implementa o protocolo nativo do GDScript (_iter_init/_iter_next/_iter_get).
## Uso: for item in FilteredItemIterator.new(inventory, &"weapon"):
class_name FilteredItemIterator
extends RefCounted

# ---------------------------------------------------------------------------
# Atributos do iterador
# ---------------------------------------------------------------------------
var items: Array
var filter_type: StringName
var _filtered: Array = []


# ---------------------------------------------------------------------------
# Construtor — recebe a coleção e o tipo de filtro
# ---------------------------------------------------------------------------
func _init(p_items: Array, p_filter_type: StringName) -> void:
	items = p_items
	filter_type = p_filter_type


# ---------------------------------------------------------------------------
# Protocolo de iteração do GDScript
# ---------------------------------------------------------------------------
func _iter_init(arg: Array) -> bool:
	_filtered = items.filter(func(item): return item.get("item_type") == filter_type)
	arg[0] = 0
	return _filtered.size() > 0


func _iter_next(arg: Array) -> bool:
	arg[0] += 1
	return arg[0] < _filtered.size()


func _iter_get(arg: Variant) -> Variant:
	return _filtered[arg]

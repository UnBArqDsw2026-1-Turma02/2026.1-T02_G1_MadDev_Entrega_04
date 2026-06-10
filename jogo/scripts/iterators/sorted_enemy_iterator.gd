## Iterator Pattern — itera um Array de inimigos ordenados por distância de um ponto.
## Implementa o protocolo nativo do GDScript (_iter_init/_iter_next/_iter_get).
## Uso: for enemy in SortedEnemyIterator.new(enemies, player.position):
class_name SortedEnemyIterator
extends RefCounted

# ---------------------------------------------------------------------------
# Atributos do iterador
# ---------------------------------------------------------------------------
var enemies: Array
var origin: Vector2
var _sorted: Array = []


# ---------------------------------------------------------------------------
# Construtor — recebe os inimigos e o ponto de referência
# ---------------------------------------------------------------------------
func _init(p_enemies: Array, p_origin: Vector2) -> void:
	enemies = p_enemies
	origin = p_origin


# ---------------------------------------------------------------------------
# Protocolo de iteração — ordena no init, retorna do mais próximo ao mais distante
# ---------------------------------------------------------------------------
func _iter_init(arg: Array) -> bool:
	_sorted = enemies.duplicate()
	_sorted.sort_custom(_compare_by_distance)
	arg[0] = 0
	return _sorted.size() > 0


func _iter_next(arg: Array) -> bool:
	arg[0] += 1
	return arg[0] < _sorted.size()


func _iter_get(arg: Variant) -> Variant:
	return _sorted[arg]


# ---------------------------------------------------------------------------
# Comparador — usado pelo sort_custom
# ---------------------------------------------------------------------------
func _compare_by_distance(a: Variant, b: Variant) -> bool:
	return a.position.distance_to(origin) < b.position.distance_to(origin)

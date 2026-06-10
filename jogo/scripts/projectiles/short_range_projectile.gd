## Object Pool — projétil de curto alcance que retorna ao ponto de origem.
## Estende ProjectileBase; sobrescreve _physics_process para lógica de retorno.
extends Node  # Será substituído por ProjectileBase quando a cena for criada

## Distância máxima antes de reverter direção (pixels).
@export var max_range: float = 120.0

var _start_position: Vector2 = Vector2.ZERO
var _direction: Vector2 = Vector2.ZERO
var _speed: float = 250.0
var _returning: bool = false
var _shooter: Node = null
var _pool: Node = null


func enable(pos: Vector2, dir: Vector2) -> void:
	_start_position = pos
	_direction = dir
	_returning = false
	global_position = pos
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = true


func set_shooter(node: Node) -> void:
	_shooter = node


func set_pool(pool: Node) -> void:
	_pool = pool


func _physics_process(delta: float) -> void:
	var travel := global_position.distance_to(_start_position)

	if not _returning and travel >= max_range:
		_returning = true
		_direction = -_direction

	if _returning:
		# Ao retornar até o ponto de origem, desativa (não causa dano ao shooter)
		if travel <= 8.0:
			_return_to_pool()
			return

	global_position += _direction * _speed * delta


func _return_to_pool() -> void:
	if _pool and _pool.has_method("return_projectile"):
		_pool.return_projectile(self)
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
		visible = false

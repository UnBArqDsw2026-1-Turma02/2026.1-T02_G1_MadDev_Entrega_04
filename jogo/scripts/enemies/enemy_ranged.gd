## Strategy Pattern — mantém distância do player e dispara projéteis via Object Pool.
class_name EnemyRanged
extends EnemyBase

@export var preferred_distance: float = 150.0
@export var max_shoot_range: float = 300.0

var _player: Node2D = null
var _pool: ProjectilePool = null


func _ready() -> void:
	super._ready()
	_player = get_tree().get_first_node_in_group("player") as Node2D
	var pools := get_tree().get_nodes_in_group("projectile_pool")
	if pools.size() > 0:
		_pool = pools[0] as ProjectilePool


## Strategy — mantém distância preferida do player
func _get_move_direction() -> Vector2:
	if _player == null:
		return Vector2.ZERO
	var dist: float = global_position.distance_to(_player.global_position)
	var to_player: Vector2 = global_position.direction_to(_player.global_position)
	if dist > preferred_distance:
		return to_player
	elif dist < preferred_distance * 0.7:
		return -to_player
	return Vector2.ZERO


## Hook — só ataca se o pool está disponível e o player está no alcance
func can_attack() -> bool:
	if _is_dead:
		return false
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _pool == null:
		var pools := get_tree().get_nodes_in_group("projectile_pool")
		if pools.size() > 0:
			_pool = pools[0] as ProjectilePool
	if _player == null or _pool == null:
		return false
	return global_position.distance_to(_player.global_position) <= max_shoot_range


## Primitive — dispara projétil via Object Pool
func execute_attack() -> void:
	var dir: Vector2 = global_position.direction_to(_player.global_position)
	_pool.get_projectile(global_position, dir, self)

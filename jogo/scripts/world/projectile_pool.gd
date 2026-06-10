## Object Pool Pattern
## Gerencia um pool de projéteis reutilizáveis
class_name ProjectilePool
extends Node

# ---------------------------------------------------------------------------
# Configuração exportada (ajustável no inspetor)
# ---------------------------------------------------------------------------
@export var projectile_scene: PackedScene = preload("res://scenes/projectiles/projectile.tscn")
@export var pool_size: int = 10
@export var auto_expand: bool = true

# ---------------------------------------------------------------------------
# Pool interno
# ---------------------------------------------------------------------------
var _pool: Array[Area2D] = []


# ---------------------------------------------------------------------------
# Inicialização
# ---------------------------------------------------------------------------
func _ready() -> void:
	add_to_group("projectile_pool")
	_preload_projectiles()


func _preload_projectiles() -> void:
	for i in range(pool_size):
		var projectile = _create_projectile()
		_pool.append(projectile)
		add_child(projectile)
	print("ProjectilePool: ", pool_size, " projéteis pré-criados")


func _create_projectile() -> Area2D:
	var projectile: Area2D = projectile_scene.instantiate()
	projectile.name = "Projectile_" + str(_pool.size())
	if projectile.has_method("set_pool"):
		projectile.set_pool(self)
	_disable_projectile(projectile)
	return projectile


# ---------------------------------------------------------------------------
# Desativa um projétil (sem queue_free)
# ---------------------------------------------------------------------------
func _disable_projectile(projectile: Area2D) -> void:
	projectile.process_mode = Node.PROCESS_MODE_DISABLED
	projectile.visible = false
	projectile.set_process(false)
	if projectile.has_method("set_monitoring"):
		projectile.set_monitoring(false)
		projectile.set_monitorable(false)


# ---------------------------------------------------------------------------
# Ativa um projétil
# ---------------------------------------------------------------------------
func _enable_projectile(projectile: Area2D, position: Vector2, direction: Vector2) -> void:
	projectile.process_mode = Node.PROCESS_MODE_INHERIT
	projectile.visible = true
	projectile.set_process(true)
	if projectile.has_method("set_monitoring"):
		projectile.set_monitoring(true)
		projectile.set_monitorable(true)
	if projectile.has_method("enable"):
		projectile.enable(position, direction)


# ---------------------------------------------------------------------------
# Método público: pega um projétil do pool
# ---------------------------------------------------------------------------
func get_projectile(position: Vector2, direction: Vector2, shooter: Node = null) -> Area2D:
	for projectile in _pool:
		if projectile.process_mode == Node.PROCESS_MODE_DISABLED:
			_enable_projectile(projectile, position, direction)
			if shooter != null and projectile.has_method("set_shooter"):
				projectile.set_shooter(shooter)
			return projectile

	if auto_expand:
		print("ProjectilePool: expandindo pool (", _pool.size() + 1, ")")
		var new_projectile = _create_projectile()
		_pool.append(new_projectile)
		add_child(new_projectile)
		_enable_projectile(new_projectile, position, direction)
		if shooter != null and new_projectile.has_method("set_shooter"):
			new_projectile.set_shooter(shooter)
		return new_projectile

	push_warning("ProjectilePool: sem projéteis disponíveis!")
	return null


# ---------------------------------------------------------------------------
# Devolve um projétil ao pool
# ---------------------------------------------------------------------------
func return_projectile(projectile: Area2D) -> void:
	if projectile in _pool:
		_disable_projectile(projectile)
	else:
		push_error("ProjectilePool: projétil não pertence a este pool!")


# ---------------------------------------------------------------------------
# Status do pool — contagem derivada do estado real dos projéteis
# ---------------------------------------------------------------------------
func get_pool_status() -> Dictionary:
	var active: int = 0
	for p in _pool:
		if p.process_mode != Node.PROCESS_MODE_DISABLED:
			active += 1
	return {
		"total": _pool.size(),
		"active": active,
		"available": _pool.size() - active
	}

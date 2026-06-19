## Object Pool — projétil de curto alcance que retorna ao ponto de origem (bumerangue).
## Estende ProjectileBase; sobrescreve o movimento para reverter ao atingir max_range.
class_name ShortRangeProjectile
extends "res://scripts/projectiles/projectile_base.gd"

## Distância máxima antes de reverter direção (pixels).
@export var max_range: float = 120.0

var _start_position: Vector2 = Vector2.ZERO
var _returning: bool = false


func enable(spawn_position: Vector2, spawn_direction: Vector2) -> void:
	super.enable(spawn_position, spawn_direction)
	_start_position = spawn_position
	_returning = false


func _process(delta: float) -> void:
	var travel: float = global_position.distance_to(_start_position)

	if not _returning and travel >= max_range:
		_returning = true
		direction = -direction

	if _returning and travel <= 8.0 and _elapsed > 0.05:
		# Retorna ao ponto de origem sem causar dano ao próprio atirador.
		call_deferred("disable")
		return

	position += direction * speed * delta
	_elapsed += delta
	if _elapsed >= lifetime:
		disable()


func apply_damage_to(target: Node) -> void:
	# No retorno, não causa dano ao atirador (cumpre a regra de Issue 14).
	if _returning and target == _shooter:
		return
	super.apply_damage_to(target)

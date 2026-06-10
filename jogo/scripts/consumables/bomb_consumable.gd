## Template Method — efeito concreto: dano em área + emite bomb_used.
class_name BombConsumable
extends ConsumableBase

@export var blast_radius: float = 80.0
@export var blast_damage: int   = 40


func _apply_effect(collector: Node) -> void:
	var origin: Vector2 = collector.global_position
	for enemy in collector.get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.distance_to(origin) <= blast_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(blast_damage)
	SignalBus.bomb_used.emit(origin)

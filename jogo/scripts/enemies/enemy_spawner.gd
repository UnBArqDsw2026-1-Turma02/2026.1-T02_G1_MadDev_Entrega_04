## Factory Method Pattern — Creator abstrato.
## Coloque um nó com este script (ou subclasse) na cena da sala,
## na posição onde o inimigo deve aparecer.
## A subclasse define qual inimigo é criado; este Creator define como ele é spawnado.
class_name EnemySpawner
extends Node2D

func _ready() -> void:
	spawn()
	queue_free()

func spawn() -> CharacterBody2D:
	var enemy := _create_enemy()
	if enemy == null:
		return null
	enemy.position = get_parent().to_local(global_position)
	enemy.add_to_group("enemies")
	get_parent().add_child.call_deferred(enemy)
	SignalBus.enemy_spawned.emit.call_deferred(enemy)
	return enemy

func _create_enemy() -> CharacterBody2D:
	push_error("EnemySpawner._create_enemy() deve ser sobrescrito pela subclasse.")
	return null

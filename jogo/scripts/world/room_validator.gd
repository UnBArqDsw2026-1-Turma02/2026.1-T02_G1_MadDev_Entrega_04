## Visitor Pattern — visita cada inimigo ativo e cada porta da sala para determinar
## se o estado da sala mudou (todos mortos → destrava portas).
## Coloque um nó com este script em cada sala de combate.
## Escuta os eventos de inimigo no SignalBus (nó instanciado em runtime).
extends Node

# IDs das portas que este validador controla (preencha via inspetor).
@export var managed_door_ids: Array[String] = []

var _total_enemies: int = 0
var _enemies_killed: int = 0


func _ready() -> void:
	SignalBus.enemy_spawned.connect(_on_enemy_spawned)
	SignalBus.enemy_died.connect(_on_enemy_died)


func _exit_tree() -> void:
	if SignalBus.enemy_spawned.is_connected(_on_enemy_spawned):
		SignalBus.enemy_spawned.disconnect(_on_enemy_spawned)
	if SignalBus.enemy_died.is_connected(_on_enemy_died):
		SignalBus.enemy_died.disconnect(_on_enemy_died)


# ---------------------------------------------------------------------------
# Visitor — visita um inimigo (consulta, não modifica)
# ---------------------------------------------------------------------------
func visit_enemy(enemy: Node) -> void:
	if not enemy.has_method("take_damage"):
		return
	# Ponto de extensão: inspecionar atributos sem acoplar ao tipo concreto.
	_total_enemies = maxi(_total_enemies, 1)


# ---------------------------------------------------------------------------
# Visitor — visita uma porta e a destranca se a sala foi liberada
# ---------------------------------------------------------------------------
func visit_door(door: Node) -> void:
	if not door.has_method("unlock"):
		return
	if _is_room_cleared():
		door.unlock()


# ---------------------------------------------------------------------------
# Receptores do SignalBus
# ---------------------------------------------------------------------------
func _on_enemy_spawned(enemy: Node) -> void:
	if enemy != null:
		_total_enemies += 1
		visit_enemy(enemy)


func _on_enemy_died(_enemy: Node) -> void:
	_enemies_killed += 1
	_validate()


# ---------------------------------------------------------------------------
# Lógica central de validação
# ---------------------------------------------------------------------------
func _validate() -> void:
	if not _is_room_cleared():
		return

	# Visita todas as portas gerenciadas na árvore de cena.
	for door_id in managed_door_ids:
		var doors: Array[Node] = get_tree().get_nodes_in_group("doors")
		for door in doors:
			if door.get("door_id") == door_id:
				visit_door(door)

	SignalBus.room_cleared.emit()


func _is_room_cleared() -> bool:
	return _total_enemies > 0 and _enemies_killed >= _total_enemies

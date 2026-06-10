## Observer Pattern — escuta key_used e bomb_used do SignalBus para abrir/explodir.
## Strategy Pattern — loot padrão vs. loot alternativo são comportamentos intercambiáveis.
class_name Chest
extends StaticBody2D

@export var interaction_radius: float = 48.0

var _opened: bool = false


func _ready() -> void:
	SignalBus.key_used.connect(_on_key_used)
	SignalBus.bomb_used.connect(_on_bomb_used)


func _exit_tree() -> void:
	if SignalBus.key_used.is_connected(_on_key_used):
		SignalBus.key_used.disconnect(_on_key_used)
	if SignalBus.bomb_used.is_connected(_on_bomb_used):
		SignalBus.bomb_used.disconnect(_on_bomb_used)


# ---------------------------------------------------------------------------
# Abertura padrão (chave)
# ---------------------------------------------------------------------------
func _on_key_used() -> void:
	if _opened or not _player_nearby():
		return
	_opened = true
	_drop_standard_loot()
	queue_free()


# ---------------------------------------------------------------------------
# Explosão (bomba) — loot alternativo
# ---------------------------------------------------------------------------
func _on_bomb_used(origin: Vector2) -> void:
	if _opened:
		return
	if global_position.distance_to(origin) > 120.0:
		return
	_opened = true
	_drop_bomb_loot()
	queue_free()


func _player_nearby() -> bool:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		return false
	return global_position.distance_to(player.global_position) <= interaction_radius


func _drop_standard_loot() -> void:
	# Ponto de extensão: no futuro, sortear de ItemData via RoomRewardConfig.
	# Por ora emite o sinal de item coletado como placeholder.
	SignalBus.item_picked_up.emit({"name": "Baú aberto", "type": "weapon"})


func _drop_bomb_loot() -> void:
	var loot: StringName = RoomRewardConfig.random_bomb_loot()
	match loot:
		&"currency":
			GameManager.add_currency(randi_range(5, 15))
		&"bomb":
			SignalBus.item_picked_up.emit({"name": "Bomba Extra", "type": "bomb"})
		&"key":
			SignalBus.item_picked_up.emit({"name": "Chave Extra", "type": "key"})

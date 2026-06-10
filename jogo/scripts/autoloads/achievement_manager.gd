## Observer Pattern - observa eventos do SignalBus e desbloqueia conquistas.
## As regras ficam em Callables, evitando switch/if por conquista.
extends Node

var achievements: Array[Achievement] = []

var _stats: Dictionary = {
	"enemies_defeated": 0,
	"items_collected": 0,
	"rooms_cleared": 0,
	"score": 0,
	"player_health": 0,
	"player_max_health": 0,
}


func _ready() -> void:
	_create_achievements()
	_connect_signal_bus()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if not event is InputEventKey or not event.pressed or event.echo:
		return

	match event.keycode:
		KEY_K:
			SignalBus.enemy_died.emit(self)
		KEY_I:
			SignalBus.item_picked_up.emit({"name": "Debug Item"})
		KEY_R:
			SignalBus.room_cleared.emit()
		KEY_P:
			GameManager.add_score(100)


func get_all_achievements() -> Array[Achievement]:
	return achievements.duplicate()


func get_unlocked_achievements() -> Array[Achievement]:
	var result: Array[Achievement] = []
	for achievement in achievements:
		if achievement.unlocked:
			result.append(achievement)
	return result


func reset_achievements() -> void:
	for achievement in achievements:
		achievement.unlocked = false
	_reset_stats()


func _connect_signal_bus() -> void:
	SignalBus.run_started.connect(_on_run_started)
	SignalBus.enemy_died.connect(_on_enemy_died)
	SignalBus.item_picked_up.connect(_on_item_picked_up)
	SignalBus.room_cleared.connect(_on_room_cleared)
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.score_changed.connect(_on_score_changed)


func _create_achievements() -> void:
	achievements = [
		Achievement.new().setup(
			&"first_blood",
			"Primeiro Sangue",
			"Derrote o primeiro inimigo.",
			&"enemy_died",
			Callable(self, "_has_defeated_first_enemy")
		),
		Achievement.new().setup(
			&"enemy_hunter",
			"Cacador de Bugs",
			"Derrote 5 inimigos em uma run.",
			&"enemy_died",
			Callable(self, "_has_defeated_five_enemies")
		),
		Achievement.new().setup(
			&"collector",
			"Colecionador",
			"Colete 3 itens em uma run.",
			&"item_picked_up",
			Callable(self, "_has_collected_three_items")
		),
		Achievement.new().setup(
			&"first_room",
			"Sala Dominada",
			"Complete a primeira sala.",
			&"room_cleared",
			Callable(self, "_has_cleared_first_room")
		),
		Achievement.new().setup(
			&"survivor",
			"Sobrevivente",
			"Complete uma sala ainda com vida.",
			&"room_cleared",
			Callable(self, "_has_cleared_room_alive")
		),
		Achievement.new().setup(
			&"high_score",
			"Nota Maxima",
			"Alcance 100 pontos em uma run.",
			&"score_changed",
			Callable(self, "_has_reached_high_score")
		),
	]


func _reset_stats() -> void:
	_stats = {
		"enemies_defeated": 0,
		"items_collected": 0,
		"rooms_cleared": 0,
		"score": 0,
		"player_health": 0,
		"player_max_health": 0,
	}


func _evaluate_achievements_for_event(event: StringName) -> void:
	for achievement in achievements:
		if achievement.event == event and achievement.can_unlock(_stats):
			achievement.unlocked = true
			SignalBus.achievement_unlocked.emit(achievement)


func _on_run_started() -> void:
	reset_achievements()


func _on_enemy_died(_enemy: Node) -> void:
	_stats["enemies_defeated"] += 1
	_evaluate_achievements_for_event(&"enemy_died")


func _on_item_picked_up(_item_data: Dictionary) -> void:
	_stats["items_collected"] += 1
	_evaluate_achievements_for_event(&"item_picked_up")


func _on_room_cleared() -> void:
	_stats["rooms_cleared"] += 1
	_evaluate_achievements_for_event(&"room_cleared")


func _on_player_health_changed(new_health: int, max_health: int) -> void:
	_stats["player_health"] = new_health
	_stats["player_max_health"] = max_health


func _on_score_changed(new_score: int) -> void:
	_stats["score"] = new_score
	_evaluate_achievements_for_event(&"score_changed")


func _has_defeated_first_enemy(data: Dictionary) -> bool:
	return data["enemies_defeated"] >= 1


func _has_defeated_five_enemies(data: Dictionary) -> bool:
	return data["enemies_defeated"] >= 5


func _has_collected_three_items(data: Dictionary) -> bool:
	return data["items_collected"] >= 3


func _has_cleared_first_room(data: Dictionary) -> bool:
	return data["rooms_cleared"] >= 1


func _has_cleared_room_alive(data: Dictionary) -> bool:
	return data["rooms_cleared"] >= 1 and data["player_health"] > 0


func _has_reached_high_score(data: Dictionary) -> bool:
	return data["score"] >= 100

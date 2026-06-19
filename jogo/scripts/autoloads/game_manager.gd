## Singleton Pattern — instância global única que guarda o estado da run.
## Conexões de sinais devem ser feitas via inspetor, não via código.
extends Node

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER, VICTORY }

# ---------------------------------------------------------------------------
# Estado da run corrente
# ---------------------------------------------------------------------------
var current_state: GameState = GameState.MENU
var current_room_index: int = 0
var run_score: int = 0
var currency: int = 0

var player_level: int = 1
var player_xp: int = 0
var xp_to_next_level: int = 10

## Perfil escolhido em character_select.tscn; lido por run.gd ao montar a run.
var selected_profile_name: String = "Calouro"

# ---------------------------------------------------------------------------
# Geração de salas usando Builder
# ---------------------------------------------------------------------------
var current_room: Node2D = null

## Sequência canônica de 12 salas (índice 0-11). run.gd consulta esta lista.
const ROOM_SEQUENCE: Array[String] = [
	"empty",   # sala 1  — vazia (introdução)
	"combat",  # sala 2
	"combat",  # sala 3
	"rest",    # sala 4
	"combat",  # sala 5
	"chest",   # sala 6
	"combat",  # sala 7
	"shop",    # sala 8
	"rest",    # sala 9
	"combat",  # sala 10
	"combat",  # sala 11 — pré-boss
	"boss",    # sala 12
]


# ---------------------------------------------------------------------------
# Facade — ponto único para iniciar/encerrar uma run
# ---------------------------------------------------------------------------
func start_run() -> void:
	reset_run()
	current_state = GameState.PLAYING
	SignalBus.run_started.emit()


## Reseta TODO o estado volátil da run (Permadeath).
## Outros sistemas devem ouvir SignalBus.run_ended via inspetor e limpar seu estado.
func reset_run() -> void:
	current_room_index = 0
	run_score = 0
	currency = 0
	player_level = 1
	player_xp = 0
	xp_to_next_level = 10


func end_run(victory: bool) -> void:
	current_state = GameState.VICTORY if victory else GameState.GAME_OVER
	SignalBus.run_ended.emit(victory)


func toggle_pause() -> void:
	var is_paused: bool = current_state != GameState.PAUSED
	current_state = GameState.PAUSED if is_paused else GameState.PLAYING
	get_tree().paused = is_paused
	SignalBus.game_paused.emit(is_paused)


func add_score(amount: int) -> void:
	run_score += amount
	SignalBus.score_changed.emit(run_score)


func add_currency(amount: int) -> void:
	currency += amount
	SignalBus.currency_changed.emit(currency)


func spend_currency(amount: int) -> bool:
	if currency < amount:
		return false
	currency -= amount
	SignalBus.currency_changed.emit(currency)
	return true


func add_xp(amount: int) -> void:
	player_xp += amount
	if player_xp >= xp_to_next_level:
		player_xp -= xp_to_next_level
		player_level += 1
		xp_to_next_level = 10 + player_level * 5
		SignalBus.level_up_ready.emit(player_level)


func load_room(room_type: String, difficulty: int = 1) -> void:
	if current_room != null:
		current_room.queue_free()

	var director := RoomDirector.new()
	director.set_builder(RoomBuilder.new())

	match room_type:
		"combat":
			current_room = director.build_combat_room(difficulty)
		"rest":
			current_room = director.build_rest_room()
		"boss":
			current_room = director.build_boss_room()
		_:
			current_room = director.build_empty_room()

	if current_room:
		var main_scene := get_tree().current_scene
		if main_scene:
			main_scene.add_child(current_room)
		else:
			add_child(current_room)

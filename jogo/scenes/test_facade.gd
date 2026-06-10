## Teste do Facade Pattern.
## Rode esta cena com F6. Resultados aparecem no painel Output.
## Valida que GameFacade delega corretamente para cada subsistema
## e que os sinais são publicados no SignalBus.
extends Node

# ---------------------------------------------------------------------------
# Contadores para validar que os sinais chegaram via Mediator
# ---------------------------------------------------------------------------
var _score_received: int = -1
var _player_died_count: int = 0
var _room_cleared_count: int = 0
var _paused_state: bool = false

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	# Conecta nos sinais do SignalBus para confirmar que chegam via Mediator
	SignalBus.score_changed.connect(_on_score_changed)
	SignalBus.player_died.connect(_on_player_died)
	SignalBus.room_cleared.connect(_on_room_cleared)
	SignalBus.game_paused.connect(_on_game_paused)

	print("")
	print("========================================")
	print("   TESTE: GameFacade")
	print("========================================")

	await get_tree().process_frame

	_test_start_run()
	_test_award_points()
	_test_toggle_pause()
	_test_emit_player_died()
	_test_emit_room_cleared()
	_test_end_run()

	print("----------------------------------------")
	print("  RESULTADO: %d passaram | %d falharam" % [_pass, _fail])
	print("========================================")
	print("")


# ---------------------------------------------------------------------------
# Testes individuais
# ---------------------------------------------------------------------------

func _test_start_run() -> void:
	print("\n[1] start_run()")
	GameFacade.start_run()
	_assert("GameManager.current_state == PLAYING",
		GameManager.current_state == GameManager.GameState.PLAYING)
	_assert("run_score resetado para 0",
		GameManager.run_score == 0)


func _test_award_points() -> void:
	print("\n[2] award_points() → sinal score_changed via Mediator")
	_score_received = -1
	GameFacade.award_points(42)
	_assert("run_score == 42",
		GameManager.run_score == 42)
	_assert("SignalBus.score_changed recebido (via Mediator)",
		_score_received == 42)


func _test_toggle_pause() -> void:
	print("\n[3] toggle_pause() → sinal game_paused via Mediator")
	GameFacade.start_run()  # garante estado PLAYING
	GameFacade.toggle_pause()
	_assert("GameManager.current_state == PAUSED",
		GameManager.current_state == GameManager.GameState.PAUSED)
	_assert("SignalBus.game_paused recebido com is_paused=true",
		_paused_state == true)
	_assert("get_tree().paused == true",
		get_tree().paused == true)

	# Despausa para não travar os testes seguintes
	GameFacade.toggle_pause()
	_assert("get_tree().paused == false após 2º toggle",
		get_tree().paused == false)


func _test_emit_player_died() -> void:
	print("\n[4] emit_player_died() → sinal player_died via Mediator")
	_player_died_count = 0
	GameFacade.emit_player_died()
	_assert("SignalBus.player_died recebido exatamente 1x (sem duplicata)",
		_player_died_count == 1)


func _test_emit_room_cleared() -> void:
	print("\n[5] emit_room_cleared() → sinal room_cleared via Mediator")
	_room_cleared_count = 0
	GameFacade.emit_room_cleared()
	_assert("SignalBus.room_cleared recebido exatamente 1x",
		_room_cleared_count == 1)


func _test_end_run() -> void:
	print("\n[6] end_run(false) → GameState == GAME_OVER")
	GameFacade.start_run()
	GameFacade.end_run(false)
	_assert("GameManager.current_state == GAME_OVER",
		GameManager.current_state == GameManager.GameState.GAME_OVER)

	print("\n[7] end_run(true) → GameState == VICTORY")
	GameFacade.start_run()
	GameFacade.end_run(true)
	_assert("GameManager.current_state == VICTORY",
		GameManager.current_state == GameManager.GameState.VICTORY)


# ---------------------------------------------------------------------------
# Callbacks dos sinais
# ---------------------------------------------------------------------------

func _on_score_changed(new_score: int) -> void:
	_score_received = new_score


func _on_player_died() -> void:
	_player_died_count += 1


func _on_room_cleared() -> void:
	_room_cleared_count += 1


func _on_game_paused(is_paused: bool) -> void:
	_paused_state = is_paused


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

func _assert(description: String, condition: bool) -> void:
	if condition:
		_pass += 1
		print("  ✅ ", description)
	else:
		_fail += 1
		print("  ❌ FALHOU: ", description)

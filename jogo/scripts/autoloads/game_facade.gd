## Facade Pattern
## Interface simplificada para os subsistemas do jogo (Audio, Game, Signals).
## Registrado como Autoload com nome "GameFacade" no project.godot.
## Todo código de gameplay deve usar GameFacade em vez de chamar autoloads diretamente.
extends Node

# ---------------------------------------------------------------------------
# Métodos de Áudio (AudioManager)
# ---------------------------------------------------------------------------

## Toca um efeito sonoro pelo nome do arquivo (sem extensão)
func play_sound(sfx_name: String) -> void:
	AudioManager.play_sfx_by_name(sfx_name)


## Toca música de fundo pelo nome do arquivo (sem extensão)
func play_music(music_name: String) -> void:
	AudioManager.play_music_by_name(music_name)


## Para a música atual
func stop_music() -> void:
	AudioManager.stop_music()


# ---------------------------------------------------------------------------
# Métodos do Jogo (GameManager)
# ---------------------------------------------------------------------------

## Inicia uma nova run (reseta estado + muda para PLAYING)
func start_run() -> void:
	GameManager.start_run()


## Reseta o estado volátil da run sem iniciar (útil antes de start_run em testes)
func reset_game_state() -> void:
	GameManager.reset_run()


## Finaliza a run atual
## @param is_victory: true se venceu, false se perdeu
func end_run(is_victory: bool) -> void:
	GameManager.end_run(is_victory)


## Pausa ou despausa o jogo
func toggle_pause() -> void:
	GameManager.toggle_pause()


## Adiciona pontos ao placar
## @param amount: Quantidade de pontos a adicionar
func award_points(amount: int) -> void:
	GameManager.add_score(amount)


# ---------------------------------------------------------------------------
# Métodos de Eventos (publicados no SignalBus)
# A Facade expõe verbos simples; o SignalBus é o hub de eventos do jogo.
# ---------------------------------------------------------------------------

## Notifica que o jogador morreu
func emit_player_died() -> void:
	SignalBus.player_died.emit()


## Notifica que um inimigo morreu
## @param enemy: Referência ao inimigo que morreu
func emit_enemy_died(enemy: Node) -> void:
	SignalBus.enemy_died.emit(enemy)


## Notifica que a sala foi limpa (todos os inimigos eliminados)
func emit_room_cleared() -> void:
	SignalBus.room_cleared.emit()


## Notifica mudança de pontuação
## @param new_score: Nova pontuação
func emit_score_changed(new_score: int) -> void:
	SignalBus.score_changed.emit(new_score)


## Notifica estado de pausa
## @param is_paused: true se pausado, false se despausado
func emit_game_paused(is_paused: bool) -> void:
	SignalBus.game_paused.emit(is_paused)


# ---------------------------------------------------------------------------
# Métodos Compostos (combinam múltiplos subsistemas)
# ---------------------------------------------------------------------------

## Mata o jogador: som de morte + evento player_died + encerra run como derrota
func kill_player() -> void:
	play_sound("death")
	emit_player_died()
	end_run(false)


## Vitória do jogador: música de vitória + encerra run como vitória
func victory() -> void:
	play_music("victory")
	end_run(true)


## Adiciona pontos com efeito sonoro
## O evento score_changed é emitido automaticamente por GameManager.add_score via Mediator
func award_points_with_sound(amount: int) -> void:
	award_points(amount)
	play_sound("point")

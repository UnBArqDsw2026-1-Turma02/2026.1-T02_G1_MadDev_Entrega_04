## Tela de fim de jogo (Game Over / Vitória).
## Observer — escuta SignalBus.run_ended (Mediator) e exibe o resultado.
## Mostra estatísticas da run: salas concluídas, inimigos mortos, tempo decorrido.
extends Control

@onready var _title:          Label = $Center/VBox/Title
@onready var _lbl_rooms:      Label = $Center/VBox/Stats/Rooms
@onready var _lbl_enemies:    Label = $Center/VBox/Stats/Enemies
@onready var _lbl_time:       Label = $Center/VBox/Stats/Time
@onready var _lbl_score:      Label = $Center/VBox/Stats/Score

var _start_time: float = 0.0
var _enemies_killed: int = 0


func _ready() -> void:
	hide()
	SignalBus.run_started.connect(_on_run_started)
	SignalBus.run_ended.connect(_on_run_ended)
	SignalBus.enemy_died.connect(_on_enemy_died)


func _on_run_started() -> void:
	_start_time = Time.get_ticks_msec() / 1000.0
	_enemies_killed = 0


func _on_enemy_died(_enemy: Node) -> void:
	_enemies_killed += 1


func _on_run_ended(victory: bool) -> void:
	_title.text = "VITÓRIA!" if victory else "VOCÊ MORREU"

	var elapsed: float = (Time.get_ticks_msec() / 1000.0) - _start_time
	var minutes: int   = int(elapsed) / 60
	var seconds: int   = int(elapsed) % 60

	_lbl_rooms.text   = "Salas concluídas: %d" % GameManager.current_room_index
	_lbl_enemies.text = "Inimigos mortos: %d"  % _enemies_killed
	_lbl_time.text    = "Tempo: %02d:%02d"      % [minutes, seconds]
	_lbl_score.text   = "Pontuação: %d"         % GameManager.run_score

	show()
	get_tree().paused = true


func _on_jogar_novamente_pressed() -> void:
	get_tree().paused = false
	GameFacade.start_run()
	get_tree().change_scene_to_file("res://scenes/ui/character_select.tscn")


func _on_voltar_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

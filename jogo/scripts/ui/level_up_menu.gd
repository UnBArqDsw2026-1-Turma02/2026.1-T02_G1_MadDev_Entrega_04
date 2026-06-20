## Observer — escuta SignalBus.level_up_ready e exibe as opções de upgrade.
## Pausa o jogo ao abrir e retoma ao confirmar.
extends Control

## Vida é em corações: +1 vida máx = +1 coração (não +20 pontos).
const _UPGRADES: Array[Dictionary] = [
	{"label": "+Dano",        "attribute": "damage",     "delta": 5.0},
	{"label": "+1 Coração",   "attribute": "max_health", "delta": 1.0},
	{"label": "+Velocidade",  "attribute": "move_speed", "delta": 20.0},
]

@onready var _btn_a: Button = $Center/VBox/BtnA
@onready var _btn_b: Button = $Center/VBox/BtnB
@onready var _btn_c: Button = $Center/VBox/BtnC
@onready var _title: Label  = $Center/VBox/Title

var _buttons: Array[Button] = []


func _ready() -> void:
	hide()
	_buttons = [_btn_a, _btn_b, _btn_c]
	for i in range(_buttons.size()):
		var idx := i
		_buttons[i].pressed.connect(func(): _on_choice(idx))
	SignalBus.level_up_ready.connect(_on_level_up_ready)


func _on_level_up_ready(new_level: int) -> void:
	_title.text = "Nível %d — Escolha um upgrade:" % new_level
	for i in range(_buttons.size()):
		_buttons[i].text = _UPGRADES[i]["label"]
	show()
	get_tree().paused = true


func _on_choice(index: int) -> void:
	var upgrade: Dictionary = _UPGRADES[index]
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and player.get("stats") != null:
		player.stats.apply_modifier(upgrade["attribute"], upgrade["delta"])
		# Ganhar um coração também o enche, e o HUD precisa do sinal para redesenhar.
		if upgrade["attribute"] == "max_health":
			player.stats.current_health = player.stats.max_health
		SignalBus.player_health_changed.emit(player.stats.current_health, player.stats.max_health)
	get_tree().paused = false
	hide()

## Bridge Pattern — Implementação concreta. Renderiza o HUD em nós visuais
## do Godot (ProgressBar, Label), recebidos via bind() pela HUDAbstraction.
extends UIRenderer
class_name CanvasRenderer


# ---------------------------------------------------------------------------
# Referências de nós injetadas via bind()
# ---------------------------------------------------------------------------
var _hp_bar: ProgressBar = null
var _hp_label: Label = null
var _score_label: Label = null
var _time_label: Label = null


func bind(targets: Dictionary) -> void:
	_hp_bar = targets.get("hp_bar")
	_hp_label = targets.get("hp_label")
	_score_label = targets.get("score_label")
	_time_label = targets.get("time_label")


# ---------------------------------------------------------------------------
# Operações de renderização
# ---------------------------------------------------------------------------
func render_hp(value: float, max_value: float) -> void:
	if _hp_bar != null:
		_hp_bar.max_value = max_value
		_hp_bar.value = value
	if _hp_label != null:
		_hp_label.text = "HP: %d / %d" % [int(value), int(max_value)]


func render_score(value: int) -> void:
	if _score_label != null:
		_score_label.text = "Score: %d" % value


func render_time(seconds: float) -> void:
	if _time_label != null:
		var minutes: int = int(seconds) / 60
		var secs: int = int(seconds) % 60
		_time_label.text = "Tempo: %02d:%02d" % [minutes, secs]

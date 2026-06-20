## Bridge Pattern — Abstração. Define O QUE o HUD exibe e delega O COMO de score/
## tempo a um UIRenderer intercambiável. Os indicadores de jogo (corações, dash,
## bombas, chaves, ouro, XP) são desenhados como ícones do icon.svg tingidos.
## Observer Pattern — recebe eventos do SignalBus para atualização automática.
extends Control
class_name HUDAbstraction

# ---------------------------------------------------------------------------
# Bridge — referência para a Implementação (atribuída pelo Inspector)
# ---------------------------------------------------------------------------
@export var renderer: UIRenderer

# Todo elemento visual deriva do icon.svg (referência de arte exigida).
const ICON: Texture2D = preload("res://icon.svg")

# Tintas dos indicadores.
const _HEART_FULL := Color(0.93, 0.26, 0.33)
const _HEART_EMPTY := Color(0.20, 0.20, 0.26)
const _DASH_READY := Color(0.36, 0.86, 0.97)
const _DASH_USED := Color(0.20, 0.28, 0.33)
const _BOMB_TINT := Color(0.58, 0.61, 0.74)
const _KEY_TINT := Color(0.96, 0.80, 0.26)
const _GOLD_TINT := Color(1.0, 0.90, 0.36)
const _XP_TINT := Color(0.45, 0.92, 0.55)

# ---------------------------------------------------------------------------
# Referências de nós da cena
# ---------------------------------------------------------------------------
@onready var _hearts_row: HBoxContainer = $Stats/HeartsRow
@onready var _dash_row: HBoxContainer = $Stats/DashRow
@onready var _resources_row: HBoxContainer = $Stats/ResourcesRow
@onready var _level_label: Label = $Stats/XPRow/LevelLabel
@onready var _xp_bar: ProgressBar = $Stats/XPRow/XPBar
@onready var _feed: VBoxContainer = $Feed
@onready var _achievement_label: Label = $AchievementLabel
@onready var _score_label: Label = $ScoreLabel
@onready var _time_label: Label = $TimeLabel

var _bomb_label: Label
var _key_label: Label
var _gold_label: Label

# ---------------------------------------------------------------------------
# Estado do cronômetro da run
# ---------------------------------------------------------------------------
var _elapsed_time: float = 0.0
var _run_active: bool = false
var _time_running: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_achievement_label.visible = false
	_build_resource_stats()
	_xp_bar.modulate = _XP_TINT
	if renderer != null:
		renderer.bind({"score_label": _score_label, "time_label": _time_label})

	# Observer — conexões por código (consistente com o resto do projeto).
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.dash_changed.connect(_on_dash_changed)
	SignalBus.bombs_changed.connect(_on_bombs_changed)
	SignalBus.keys_changed.connect(_on_keys_changed)
	SignalBus.currency_changed.connect(_on_currency_changed)
	SignalBus.xp_changed.connect(_on_xp_changed)
	SignalBus.score_changed.connect(_on_score_changed)
	SignalBus.run_started.connect(_on_run_started)
	SignalBus.run_ended.connect(_on_run_ended)
	SignalBus.game_paused.connect(_on_game_paused)
	SignalBus.achievement_unlocked.connect(_on_achievement_unlocked)
	SignalBus.item_picked_up.connect(_on_item_picked_up)
	SignalBus.player_damaged.connect(_on_player_damaged)


func _process(delta: float) -> void:
	if not _time_running:
		return
	_elapsed_time += delta
	if renderer != null:
		renderer.render_time(_elapsed_time)


# ---------------------------------------------------------------------------
# Construção de ícones (icon.svg tingido)
# ---------------------------------------------------------------------------
func _make_icon(size: float, tint: Color) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = ICON
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.custom_minimum_size = Vector2(size, size)
	tr.modulate = tint
	return tr


func _build_resource_stats() -> void:
	_bomb_label = _make_stat(_BOMB_TINT, "0")
	_key_label  = _make_stat(_KEY_TINT, "0")
	_gold_label = _make_stat(_GOLD_TINT, "0")


func _make_stat(tint: Color, initial: String) -> Label:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	box.add_child(_make_icon(14, tint))
	var lbl := Label.new()
	lbl.text = initial
	lbl.add_theme_font_size_override("font_size", 14)
	box.add_child(lbl)
	_resources_row.add_child(box)
	return lbl


# ---------------------------------------------------------------------------
# Observer — corações (vida)
# ---------------------------------------------------------------------------
func _on_player_health_changed(new_health: int, max_health: int) -> void:
	for child in _hearts_row.get_children():
		child.queue_free()
	for i in range(max_health):
		var full: bool = i < new_health
		_hearts_row.add_child(_make_icon(16, _HEART_FULL if full else _HEART_EMPTY))


## Pulso vermelho no painel de corações ao tomar dano.
func _on_player_damaged() -> void:
	var tw := create_tween()
	_hearts_row.modulate = Color(1.6, 1.2, 1.2)
	tw.tween_property(_hearts_row, "modulate", Color.WHITE, 0.25)


# ---------------------------------------------------------------------------
# Observer — dash (corações de dash)
# ---------------------------------------------------------------------------
func _on_dash_changed(current: int, maximum: int) -> void:
	for child in _dash_row.get_children():
		child.queue_free()
	for i in range(maximum):
		var ready_charge: bool = i < current
		_dash_row.add_child(_make_icon(13, _DASH_READY if ready_charge else _DASH_USED))


# ---------------------------------------------------------------------------
# Observer — recursos
# ---------------------------------------------------------------------------
func _on_bombs_changed(amount: int) -> void:
	if _bomb_label:
		_bomb_label.text = str(amount)


func _on_keys_changed(amount: int) -> void:
	if _key_label:
		_key_label.text = str(amount)


func _on_currency_changed(new_amount: int) -> void:
	if _gold_label:
		_gold_label.text = str(new_amount)


# ---------------------------------------------------------------------------
# Observer — XP / nível
# ---------------------------------------------------------------------------
func _on_xp_changed(current_xp: int, xp_to_next: int, level: int) -> void:
	_level_label.text = "Nv %d" % level
	_xp_bar.max_value = maxf(1.0, float(xp_to_next))
	_xp_bar.value = float(current_xp)


# ---------------------------------------------------------------------------
# Observer — score / tempo / run / conquistas
# ---------------------------------------------------------------------------
func _on_score_changed(new_score: int) -> void:
	if renderer != null:
		renderer.render_score(new_score)


func _on_run_started() -> void:
	_elapsed_time = 0.0
	_run_active = true
	_time_running = true


func _on_run_ended(_victory: bool) -> void:
	_run_active = false
	_time_running = false


func _on_game_paused(is_paused: bool) -> void:
	_time_running = _run_active and not is_paused


func _on_achievement_unlocked(achievement: Achievement) -> void:
	_achievement_label.text = "Conquista: %s" % achievement.name
	_achievement_label.visible = true
	await get_tree().create_timer(3.0).timeout
	_achievement_label.visible = false


# ---------------------------------------------------------------------------
# Feed transitório de coletas (confirmação visual de pickup/recompensa)
# ---------------------------------------------------------------------------
func _on_item_picked_up(item_data: Dictionary) -> void:
	var label := Label.new()
	label.text = "+ %s" % item_data.get("name", "Item")
	label.add_theme_font_size_override("font_size", 14)
	label.modulate = Color(1, 1, 0.7)
	_feed.add_child(label)
	var tw := create_tween()
	tw.tween_interval(1.0)
	tw.tween_property(label, "modulate:a", 0.0, 0.6)
	tw.tween_callback(func() -> void:
		if is_instance_valid(label):
			label.queue_free())

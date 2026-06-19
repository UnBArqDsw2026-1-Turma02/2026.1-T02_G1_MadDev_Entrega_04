## Bridge Pattern — Abstração. Define O QUE o HUD exibe (HP, score, tempo) e
## delega O COMO para um UIRenderer intercambiável (CanvasRenderer / DebugRenderer).
## Trocar o renderer no Inspector muda a renderização sem alterar esta classe.
## Observer Pattern — recebe eventos do SignalBus para atualização automática.
## Iterator Pattern — update_consumables() percorre os slots do inventário.
extends Control
class_name HUDAbstraction

# ---------------------------------------------------------------------------
# Bridge — referência para a Implementação (atribuída pelo Inspector)
# ---------------------------------------------------------------------------
@export var renderer: UIRenderer

# ---------------------------------------------------------------------------
# Referências aos nós da cena (lado visual)
# ---------------------------------------------------------------------------
@onready var _hp_bar: ProgressBar = $VBoxContainer/HealthRow/HealthBar
@onready var _hp_label: Label = $VBoxContainer/HealthRow/HealthLabel
@onready var _score_label: Label = $VBoxContainer/ScoreLabel
@onready var _time_label: Label = $VBoxContainer/TimeLabel
@onready var _consumable_bar: HBoxContainer = $VBoxContainer/ConsumableRow
@onready var _achievement_label: Label = $VBoxContainer/AchievementLabel
@onready var _currency_label: Label = $VBoxContainer/CurrencyLabel
@onready var _weapon_label: Label = $VBoxContainer/WeaponLabel
@onready var _benefit_label: Label = $VBoxContainer/BenefitLabel

# ---------------------------------------------------------------------------
# Estado do cronômetro da run
# ---------------------------------------------------------------------------
var _elapsed_time: float = 0.0
var _run_active: bool = false
var _time_running: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_achievement_label.visible = false
	if renderer != null:
		renderer.bind({
			"hp_bar": _hp_bar,
			"hp_label": _hp_label,
			"score_label": _score_label,
			"time_label": _time_label,
		})
	# Observer — conexões por código (consistente com pause_menu.gd)
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.score_changed.connect(_on_score_changed)
	SignalBus.run_started.connect(_on_run_started)
	SignalBus.run_ended.connect(_on_run_ended)
	SignalBus.game_paused.connect(_on_game_paused)
	SignalBus.achievement_unlocked.connect(_on_achievement_unlocked)
	SignalBus.currency_changed.connect(_on_currency_changed)
	SignalBus.equipment_changed.connect(_on_equipment_changed)
	SignalBus.benefit_changed.connect(_on_benefit_changed)
	SignalBus.item_picked_up.connect(_on_item_picked_up)


func _process(delta: float) -> void:
	if not _time_running:
		return
	_elapsed_time += delta
	if renderer != null:
		renderer.render_time(_elapsed_time)


# ---------------------------------------------------------------------------
# Bridge — métodos de alto nível que delegam ao renderer
# ---------------------------------------------------------------------------
func _render_hp(value: float, max_value: float) -> void:
	if renderer != null:
		renderer.render_hp(value, max_value)


func _render_score(value: int) -> void:
	if renderer != null:
		renderer.render_score(value)


# ---------------------------------------------------------------------------
# Observer — receptores de eventos do SignalBus
# ---------------------------------------------------------------------------
func _on_player_health_changed(new_health: int, max_health: int) -> void:
	_render_hp(float(new_health), float(max_health))


func _on_score_changed(new_score: int) -> void:
	_render_score(new_score)


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


func _on_currency_changed(new_amount: int) -> void:
	_currency_label.text = "Moeda: %d" % new_amount


## EquipSlot.HEAD (índice 0) é o slot reaproveitado por WeaponItem (ver weapon_item.gd).
func _on_equipment_changed(slot: int, item: Resource) -> void:
	if slot != 0:
		return
	if item != null and item.get("weapon_name") != null:
		_weapon_label.text = "Arma: %s" % item.weapon_name
	else:
		_weapon_label.text = "Arma: nenhuma"


func _on_benefit_changed(benefit: Resource) -> void:
	if benefit != null and benefit.get("consumable_name") != null:
		_benefit_label.text = "Benefício: %s" % benefit.consumable_name
	else:
		_benefit_label.text = "Benefício: nenhum"


# ---------------------------------------------------------------------------
# Iterator — itera sobre o feed transitório de coletas recentes
# ---------------------------------------------------------------------------
## Consumíveis têm efeito instantâneo ao coletar (sem inventário persistente);
## o feed mostra a última coleta por 1.5s como confirmação visual.
func _on_item_picked_up(item_data: Dictionary) -> void:
	for child in _consumable_bar.get_children():
		child.queue_free()
	var label := Label.new()
	label.text = "+ %s" % item_data.get("name", "Item")
	_consumable_bar.add_child(label)
	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(label):
		label.queue_free()

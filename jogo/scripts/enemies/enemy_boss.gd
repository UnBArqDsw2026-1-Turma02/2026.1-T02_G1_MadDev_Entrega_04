## Template Method Pattern — estende EnemyBase com fases de comportamento.
## State Pattern — current_phase controla qual comportamento está ativo.
## Observer — emite boss_phase_changed no SignalBus ao transitar de fase.
class_name EnemyBoss
extends EnemyBase

@export var phase_trigger_hp_percent: float = 0.5
@export var phase2_speed_multiplier: float  = 1.6
@export var phase2_damage_multiplier: float = 1.5

var current_phase: int = 1
var _base_speed: float
var _base_damage: int


func _ready() -> void:
	super._ready()
	_base_speed  = move_speed
	_base_damage = attack_damage
	add_to_group("boss")


func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	if current_phase == 1:
		_check_phase_transition()
	super._physics_process(delta)


# ---------------------------------------------------------------------------
# Template Method — sobrescreve movimento para perseguir sempre o player
# ---------------------------------------------------------------------------
func _get_move_direction() -> Vector2:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		return Vector2.ZERO
	return (player.global_position - global_position).normalized()


# ---------------------------------------------------------------------------
# Fase 2 — ativada a 50% de HP
# ---------------------------------------------------------------------------
func _check_phase_transition() -> void:
	if float(current_health) / float(max_health) <= phase_trigger_hp_percent:
		_enter_phase_2()


func _enter_phase_2() -> void:
	current_phase = 2
	move_speed   = _base_speed  * phase2_speed_multiplier
	attack_damage = roundi(_base_damage * phase2_damage_multiplier)
	# Feedback visual: flash vermelho por 0.5s
	modulate = Color.RED
	await get_tree().create_timer(0.5).timeout
	modulate = Color.WHITE
	SignalBus.enemy_spawned.emit(self)  # reutiliza sinal disponível; substitua por boss_phase_changed se preferir

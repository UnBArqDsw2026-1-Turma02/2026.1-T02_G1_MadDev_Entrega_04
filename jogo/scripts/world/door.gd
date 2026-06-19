## Visitor Pattern  — aceita um RoomValidator que verifica se pode ser destrancada.
## Observer Pattern — emite SignalBus.door_lock_changed; conexões via inspetor.
## Strategy Pattern — o critério de desbloqueio pode ser trocado sem mudar esta classe.
extends StaticBody2D

@export var door_id: String = "door_default"
@export var starts_locked: bool = false
@export var reward_type: StringName = &"none"

var is_locked: bool = false

const _ARM_DELAY: float = 0.3
var _armed: bool = false

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var _reward_label: Label = $RewardLabel


func _ready() -> void:
	add_to_group("doors")
	_reward_label.text = RoomRewardConfig.description_for(reward_type)
	_reward_label.visible = not _reward_label.text.is_empty()
	if starts_locked:
		lock()
	else:
		unlock()
	# Arma a passagem só após um instante: ignora o body_entered causado pelo
	# reposicionamento do player ao carregar a sala (transição falsa por spawn).
	await get_tree().create_timer(_ARM_DELAY).timeout
	_armed = true


# ---------------------------------------------------------------------------
# Interface pública de travamento
# ---------------------------------------------------------------------------
func lock() -> void:
	is_locked = true
	# set_deferred: lock/unlock pode ser chamado durante o passo de física
	# (ex: validator destrava ao matar o último inimigo numa colisão).
	collision.set_deferred("disabled", false)
	SignalBus.door_lock_changed.emit(door_id, true)


func unlock() -> void:
	is_locked = false
	collision.set_deferred("disabled", true)
	SignalBus.door_lock_changed.emit(door_id, false)


func toggle() -> void:
	if is_locked:
		unlock()
	else:
		lock()


# ---------------------------------------------------------------------------
# Visitor Pattern — aceita um visitante que decide se pode destravar
# ---------------------------------------------------------------------------
func accept(visitor: Object) -> void:
	if visitor.has_method("visit_door"):
		visitor.visit_door(self)


# ---------------------------------------------------------------------------
# Passagem — a PassageArea (nó da cena door.tscn) chama este método via conexão
# do inspetor quando um corpo entra. Porta destrancada + player → publica
# door_entered no SignalBus (Mediator).
# ---------------------------------------------------------------------------
func _on_passage_body_entered(body: Node) -> void:
	if is_locked or not _armed:
		return
	if body.is_in_group("player"):
		SignalBus.door_entered.emit(door_id)

## Command/Adapter Pattern — leitura de input separada da execução de movimento.
## Observer Pattern  — eventos publicados no SignalBus notificam sistemas interessados.
## Object Pool      — disparo de projéteis via ProjectilePool (sem instantiate/queue_free).
extends CharacterBody2D

# ---------------------------------------------------------------------------
# Ficha de atributos (fonte única de verdade — Issue 02)
# ---------------------------------------------------------------------------
@export var stats: PlayerStats

# ---------------------------------------------------------------------------
# Dash
# ---------------------------------------------------------------------------
@export var dash_speed: float   = 600.0
@export var dash_duration: float = 0.15
@export var dash_base_cooldown: float = 1.0

# ---------------------------------------------------------------------------
# Object Pool — pool de projéteis do player
# ---------------------------------------------------------------------------
@export var projectile_pool: ProjectilePool
@export var short_range_pool: ProjectilePool
@export var shoot_cooldown: float = 0.3

var _shoot_timer: float = 0.0
## Issue 14 — alterado por LongRangeWeapon/ShortRangeWeapon ao equipar; decide qual pool dispara.
var _weapon_type: StringName = &"long"

# ---------------------------------------------------------------------------
# Slots de equipamento (Decorator / Iterator)
# Cada slot guarda o Resource do item equipado, ou null se vazio.
# ---------------------------------------------------------------------------
enum EquipSlot { HEAD, TORSO, LEG, FOOT, ACCESSORY }

var equipment: Dictionary = {
	EquipSlot.HEAD:      null,
	EquipSlot.TORSO:     null,
	EquipSlot.LEG:       null,
	EquipSlot.FOOT:      null,
	EquipSlot.ACCESSORY: null,
}

# ---------------------------------------------------------------------------
# Benefício ativo (slot único — Issue 06)
# ---------------------------------------------------------------------------
var active_benefit: Resource = null

# ---------------------------------------------------------------------------
# Estado interno de movimento
# ---------------------------------------------------------------------------
var _move_direction: Vector2 = Vector2.ZERO
var _is_dashing: bool = false
var _can_dash: bool = true
var _is_dead: bool = false


# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------
func _ready() -> void:
	add_to_group("player")
	if stats == null:
		stats = PlayerStats.new()
	stats.current_health = stats.max_health
	SignalBus.player_health_changed.emit(stats.current_health, stats.max_health)
	SignalBus.run_ended.connect(_on_run_ended)


func _physics_process(delta: float) -> void:
	if _is_dashing:
		move_and_slide()
		return

	_move_direction = _read_move_input()
	velocity = _move_direction * stats.move_speed

	if _read_dash_input() and _can_dash:
		_execute_dash()

	if _shoot_timer > 0.0:
		_shoot_timer -= delta

	if _read_shoot_input() and _shoot_timer <= 0.0:
		_shoot()

	move_and_slide()


# ---------------------------------------------------------------------------
# Adapter — leitura de input isolada
# ---------------------------------------------------------------------------
func _read_move_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _read_dash_input() -> bool:
	return Input.is_action_just_pressed("dash")


func _read_shoot_input() -> bool:
	return Input.is_action_pressed("shoot")


# ---------------------------------------------------------------------------
# Command — execução do dash isolada da leitura de input
# ---------------------------------------------------------------------------
func _execute_dash() -> void:
	var dir: Vector2 = _move_direction if _move_direction != Vector2.ZERO else Vector2.RIGHT
	_is_dashing = true
	_can_dash = false
	velocity = dir * dash_speed
	await get_tree().create_timer(dash_duration).timeout
	_is_dashing = false
	var effective_cd := dash_base_cooldown * (1.0 - stats.dash_cd_reduction)
	await get_tree().create_timer(maxf(0.1, effective_cd)).timeout
	_can_dash = true


# ---------------------------------------------------------------------------
# Object Pool — disparo via pool de projéteis
# ---------------------------------------------------------------------------
func _shoot() -> void:
	## Issue 14 — arma curta usa o pool de bumerangue; demais tipos usam o pool padrão.
	var pool: ProjectilePool = short_range_pool if _weapon_type == &"short" and short_range_pool else projectile_pool
	if pool == null:
		return
	var dir: Vector2 = (get_global_mouse_position() - global_position).normalized()
	pool.get_projectile(global_position, dir, self)
	_shoot_timer = shoot_cooldown


# ---------------------------------------------------------------------------
# Vida (Observer via sinais)
# ---------------------------------------------------------------------------
@export var damage_chain: DamageHandler

func take_damage(amount: int) -> void:
	if _is_dead:
		return
	if not damage_chain:
		apply_final_damage(amount)
		return
	var context := {"target": self}
	damage_chain.handle(amount, context)


func apply_final_damage(final_damage: int) -> void:
	stats.current_health = maxi(0, stats.current_health - final_damage)
	SignalBus.player_health_changed.emit(stats.current_health, stats.max_health)
	if stats.current_health == 0:
		_die()


func heal(amount: int) -> void:
	stats.current_health = mini(stats.max_health, stats.current_health + amount)
	SignalBus.player_health_changed.emit(stats.current_health, stats.max_health)


func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	GameFacade.kill_player()


# ---------------------------------------------------------------------------
# Reset de run (RNF-07)
# ---------------------------------------------------------------------------
func _on_run_ended(_victory: bool) -> void:
	_is_dead = false
	_can_dash = true
	_is_dashing = false
	for slot in equipment.keys():
		unequip(slot)
	unequip_benefit()
	stats.reset_to_base()


# ---------------------------------------------------------------------------
# Equipamento
# ---------------------------------------------------------------------------
func equip(slot: EquipSlot, item: Resource) -> void:
	if equipment[slot] != null and equipment[slot].has_method("on_unequip"):
		equipment[slot].on_unequip(self)
	equipment[slot] = item
	if item != null and item.has_method("on_equip"):
		item.on_equip(self)
	SignalBus.equipment_changed.emit(slot, item)


func unequip(slot: EquipSlot) -> void:
	if equipment[slot] != null and equipment[slot].has_method("on_unequip"):
		equipment[slot].on_unequip(self)
	equipment[slot] = null
	SignalBus.equipment_changed.emit(slot, null)


func get_equipped(slot: EquipSlot) -> Resource:
	return equipment[slot]


# ---------------------------------------------------------------------------
# Benefício ativo (slot único)
# ---------------------------------------------------------------------------
func equip_benefit(benefit: Resource) -> void:
	if active_benefit != null and active_benefit.has_method("deactivate"):
		active_benefit.deactivate(self)
	active_benefit = benefit
	if benefit != null and benefit.has_method("activate"):
		benefit.activate(self)
	SignalBus.benefit_changed.emit(benefit)


func unequip_benefit() -> void:
	if active_benefit != null and active_benefit.has_method("deactivate"):
		active_benefit.deactivate(self)
	active_benefit = null
	SignalBus.benefit_changed.emit(null)

## Command/Adapter Pattern — leitura de input separada da execução de movimento.
## Observer Pattern  — eventos publicados no SignalBus notificam sistemas interessados.
## Object Pool      — disparo de projéteis via ProjectilePool (sem instantiate/queue_free).
extends CharacterBody2D

# ---------------------------------------------------------------------------
# Ficha de atributos (fonte única de verdade — Issue 02)
# ---------------------------------------------------------------------------
@export var stats: PlayerStats

# ---------------------------------------------------------------------------
# Dash — modelo de "corações de dash": 2 cargas que recarregam com o tempo.
# ---------------------------------------------------------------------------
@export var dash_speed: float    = 600.0
@export var dash_duration: float = 0.15
@export var dash_max_charges: int = 2
@export var dash_recharge_time: float = 1.6  # segundos por carga

var _dash_charges: int = 0
var _dash_recharge_accum: float = 0.0

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
# Bomba (recurso carregado) — área de dano ao detonar.
# ---------------------------------------------------------------------------
@export var bomb_blast_radius: float = 96.0
@export var bomb_blast_damage: int   = 60

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
# Bolso do inventário — 6 slots para itens NÃO consumíveis (pegar/dropar).
# Mesma estrutura exibida na lista 1-6 (HUD) e na matriz 2x3 (menu Tab).
# ---------------------------------------------------------------------------
const POCKET_SIZE: int = 6
const _WORLD_ITEM_SCENE: String = "res://scenes/world/world_item.tscn"
var pocket: Array = [null, null, null, null, null, null]

# ---------------------------------------------------------------------------
# Benefício ativo (slot único — Issue 06)
# ---------------------------------------------------------------------------
var active_benefit: Resource = null

# ---------------------------------------------------------------------------
# Estado interno de movimento / combate
# ---------------------------------------------------------------------------
var _move_direction: Vector2 = Vector2.ZERO
var _is_dashing: bool = false
var _is_dead: bool = false

# Game feel — invulnerabilidade temporária (i-frames), flash de dano e screen shake.
@export var iframe_time: float = 0.9
var _invuln_timer: float = 0.0
var _flash_timer: float = 0.0
var _shake_timer: float = 0.0
var _shake_strength: float = 0.0
var _facing: Vector2 = Vector2.RIGHT

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _camera: Camera2D = $Camera2D


# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------
func _ready() -> void:
	add_to_group("player")
	if stats == null:
		stats = PlayerStats.new()
	stats.current_health = stats.max_health
	_dash_charges = dash_max_charges
	SignalBus.run_ended.connect(_on_run_ended)
	# Player é o último filho de run.tscn → HUD já conectou seus sinais; seguro emitir o estado inicial.
	SignalBus.player_health_changed.emit(stats.current_health, stats.max_health)
	SignalBus.dash_changed.emit(_dash_charges, dash_max_charges)
	SignalBus.inventory_changed.emit(pocket)


func _physics_process(delta: float) -> void:
	_update_feedback(delta)

	if _is_dashing:
		move_and_slide()
		return

	_recharge_dash(delta)

	_move_direction = _read_move_input()
	if _move_direction != Vector2.ZERO:
		_facing = _move_direction
	velocity = _move_direction * stats.move_speed

	if _read_dash_input() and _dash_charges > 0:
		_execute_dash()

	if _shoot_timer > 0.0:
		_shoot_timer -= delta
	if _read_shoot_input() and _shoot_timer <= 0.0:
		_shoot()

	if Input.is_action_just_pressed("use_bomb"):
		_try_use_bomb()
	if Input.is_action_just_pressed("interact"):
		_try_interact()
	if Input.is_action_just_pressed("drop_item"):
		_drop_last_pocket_item()

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
# Dash — cargas que recarregam com o tempo (corações de dash)
# ---------------------------------------------------------------------------
func _recharge_dash(delta: float) -> void:
	if _dash_charges >= dash_max_charges:
		_dash_recharge_accum = 0.0
		return
	var rate := dash_recharge_time * (1.0 - stats.dash_cd_reduction)
	_dash_recharge_accum += delta
	if _dash_recharge_accum >= maxf(0.2, rate):
		_dash_recharge_accum = 0.0
		_dash_charges += 1
		SignalBus.dash_changed.emit(_dash_charges, dash_max_charges)


## Command — execução do dash isolada da leitura de input. Concede i-frames.
func _execute_dash() -> void:
	var dir: Vector2 = _move_direction if _move_direction != Vector2.ZERO else _facing
	_is_dashing = true
	_dash_charges -= 1
	SignalBus.dash_changed.emit(_dash_charges, dash_max_charges)
	# i-frames durante o dash (mínimo o tempo do dash) — esquiva é recompensada.
	_invuln_timer = maxf(_invuln_timer, dash_duration + 0.05)
	velocity = dir * dash_speed
	GameFacade.play_sound("dash")
	await get_tree().create_timer(dash_duration).timeout
	_is_dashing = false


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
# Vida — modelo de corações. Todo dano inimigo custa exatamente 1 coração.
# ---------------------------------------------------------------------------
@export var damage_chain: DamageHandler

## Recebe dano: ignora a magnitude (regra de design "todo dano = 1 coração"),
## respeita i-frames e dispara o feedback de game feel.
func take_damage(_amount: int) -> void:
	if _is_dead or _invuln_timer > 0.0 or _is_dashing:
		return
	apply_final_damage(1)


func apply_final_damage(final_damage: int) -> void:
	if _is_dead:
		return
	stats.current_health = maxi(0, stats.current_health - final_damage)
	SignalBus.player_health_changed.emit(stats.current_health, stats.max_health)
	SignalBus.player_damaged.emit()
	GameFacade.play_sound("hit")
	_invuln_timer = iframe_time
	_flash_timer = 0.18
	_apply_shake(5.0, 0.35)
	if stats.current_health == 0:
		_die()


func heal(amount: int) -> void:
	if _is_dead:
		return
	var before := stats.current_health
	stats.current_health = mini(stats.max_health, stats.current_health + amount)
	if stats.current_health != before:
		SignalBus.player_health_changed.emit(stats.current_health, stats.max_health)
		GameFacade.play_sound("heal")


func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	GameFacade.kill_player()


# ---------------------------------------------------------------------------
# Game feel — i-frames (piscar), flash de dano e screen shake
# ---------------------------------------------------------------------------
func _update_feedback(delta: float) -> void:
	if _invuln_timer > 0.0:
		_invuln_timer -= delta
	if _flash_timer > 0.0:
		_flash_timer -= delta

	if _sprite:
		var col := Color.WHITE
		if _flash_timer > 0.0:
			col = Color(1.0, 0.35, 0.35)
		var alpha := 1.0
		if _invuln_timer > 0.0:
			# pisca ~12x/s enquanto invulnerável
			alpha = 0.35 + 0.4 * (0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.075))
		_sprite.modulate = Color(col.r, col.g, col.b, alpha)

	if _camera:
		if _shake_timer > 0.0:
			_shake_timer -= delta
			var amt := _shake_strength * (_shake_timer / 0.35)
			_camera.offset = Vector2(randf_range(-amt, amt), randf_range(-amt, amt))
		else:
			_camera.offset = Vector2.ZERO


func _apply_shake(strength: float, duration: float) -> void:
	_shake_strength = strength
	_shake_timer = duration


# ---------------------------------------------------------------------------
# Bomba — detona em área ao redor do player (recurso carregado)
# ---------------------------------------------------------------------------
func _try_use_bomb() -> void:
	if not GameManager.use_bomb():
		return
	var origin: Vector2 = global_position
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and enemy.global_position.distance_to(origin) <= bomb_blast_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(bomb_blast_damage)
	SignalBus.bomb_used.emit(origin)
	GameFacade.play_sound("explosion")
	_apply_shake(9.0, 0.5)


# ---------------------------------------------------------------------------
# Interagir — abre baús próximos gastando uma chave
# ---------------------------------------------------------------------------
func _try_interact() -> void:
	var nearest: Node = null
	var nearest_dist: float = INF
	for chest in get_tree().get_nodes_in_group("chests"):
		if not is_instance_valid(chest):
			continue
		var d: float = chest.global_position.distance_to(global_position)
		var reach: float = float(chest.get("interaction_radius")) if chest.get("interaction_radius") != null else 48.0
		if d <= reach and d < nearest_dist:
			nearest = chest
			nearest_dist = d
	if nearest == null:
		return
	if GameManager.use_key() and nearest.has_method("force_open"):
		nearest.force_open(&"key")


# ---------------------------------------------------------------------------
# Bolso do inventário (itens não consumíveis) — pegar / dropar / equipar
# ---------------------------------------------------------------------------
## Adiciona um item ao primeiro slot livre do bolso. Retorna o índice ou -1 (cheio).
func add_to_pocket(item: Resource) -> int:
	for i in range(POCKET_SIZE):
		if pocket[i] == null:
			pocket[i] = item
			SignalBus.inventory_changed.emit(pocket)
			return i
	return -1


func pocket_is_full() -> bool:
	for slot in pocket:
		if slot == null:
			return false
	return true


func remove_from_pocket(index: int) -> Resource:
	if index < 0 or index >= POCKET_SIZE:
		return null
	var item: Resource = pocket[index]
	pocket[index] = null
	SignalBus.inventory_changed.emit(pocket)
	return item


## Solta o item do slot indicado de volta no mundo (perto do player).
func drop_pocket_item(index: int) -> void:
	var item: Resource = remove_from_pocket(index)
	if item == null:
		return
	_spawn_world_item(item)
	GameFacade.play_sound("drop")


func _drop_last_pocket_item() -> void:
	for i in range(POCKET_SIZE - 1, -1, -1):
		if pocket[i] != null:
			drop_pocket_item(i)
			return


func _spawn_world_item(item: Resource) -> void:
	var scene := load(_WORLD_ITEM_SCENE) as PackedScene
	if scene == null:
		return
	var node := scene.instantiate()
	node.set("item", item)
	node.global_position = global_position + _facing * 28.0
	var host: Node = _current_room()
	if host == null:
		host = get_parent()
	host.add_child(node)


func _current_room() -> Node:
	var run := get_tree().current_scene
	if run == null:
		return null
	var room_host := run.get_node_or_null("RoomHost")
	if room_host and room_host.get_child_count() > 0:
		return room_host.get_child(room_host.get_child_count() - 1)
	return null


## Equipa o item do bolso no seu slot. Troca com o item já equipado (vai pro bolso).
func equip_from_pocket(index: int) -> bool:
	if index < 0 or index >= POCKET_SIZE:
		return false
	var item: Resource = pocket[index]
	if item == null or item.get("slot") == null:
		return false
	var slot: int = int(item.slot)
	var previous: Resource = equipment.get(slot)
	pocket[index] = previous  # devolve o anterior ao mesmo slot do bolso (ou null)
	equip(slot, item)
	SignalBus.inventory_changed.emit(pocket)
	GameFacade.play_sound("equip")
	return true


## Desequipa um slot e devolve o item ao bolso (se houver espaço).
func unequip_to_pocket(slot: int) -> bool:
	var item: Resource = equipment.get(slot)
	if item == null:
		return false
	if pocket_is_full():
		return false
	unequip(slot)
	add_to_pocket(item)
	return true


# ---------------------------------------------------------------------------
# Reset de run (RNF-07)
# ---------------------------------------------------------------------------
func _on_run_ended(_victory: bool) -> void:
	_is_dead = false
	_is_dashing = false
	_dash_charges = dash_max_charges
	_invuln_timer = 0.0
	for slot in equipment.keys():
		unequip(slot)
	unequip_benefit()
	for i in range(POCKET_SIZE):
		pocket[i] = null
	stats.reset_to_base()
	SignalBus.inventory_changed.emit(pocket)
	SignalBus.dash_changed.emit(_dash_charges, dash_max_charges)
	SignalBus.player_health_changed.emit(stats.current_health, stats.max_health)


# ---------------------------------------------------------------------------
# Equipamento
# ---------------------------------------------------------------------------
func equip(slot: int, item: Resource) -> void:
	if equipment[slot] != null and equipment[slot].has_method("on_unequip"):
		equipment[slot].on_unequip(self)
	equipment[slot] = item
	if item != null and item.has_method("on_equip"):
		item.on_equip(self)
	SignalBus.equipment_changed.emit(slot, item)
	# Itens podem alterar max_health (corações); mantém o HUD sincronizado.
	SignalBus.player_health_changed.emit(stats.current_health, stats.max_health)


func unequip(slot: int) -> void:
	if equipment[slot] != null and equipment[slot].has_method("on_unequip"):
		equipment[slot].on_unequip(self)
	equipment[slot] = null
	SignalBus.equipment_changed.emit(slot, null)
	SignalBus.player_health_changed.emit(stats.current_health, stats.max_health)


func get_equipped(slot: int) -> Resource:
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

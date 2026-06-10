## Builder Pattern — ConcreteBuilder para salas de jogo.
## Constrói uma sala Node2D passo a passo com configurações personalizadas.
class_name RoomBuilder
extends RoomBuilderBase

const _ITEM_SCENE: String = "res://scenes/consumables/consumable.tscn"

# Tileset room.tres: source 0 = piso (sem colisão), source 1 = parede (colisão, layer 2).
const _FLOOR_SOURCE: int = 0
const _WALL_SOURCE: int = 1
const _TILE_ATLAS: Vector2i = Vector2i(0, 0)
# Limites da sala em tiles — folgados o bastante para conter todas as receitas
# do Director (portas e player_start ficam no piso; paredes só na borda externa).
const _ROOM_MIN: Vector2i = Vector2i(-5, -9)
const _ROOM_MAX: Vector2i = Vector2i(20, 17)

var _room_name: String = "Sala"
var _room_type: String = "combat"
var _enemy_list: Array[Dictionary] = []
var _item_list: Array[Dictionary] = []
var _door_positions: Array[Vector2] = []
var _tilemap_source: String = "res://art/tilesets/room.tres"
var _player_start_position: Vector2 = Vector2(152, 112)
var _has_safe_heal: bool = false

# ---------------------------------------------------------------------------
# Interface fluente (métodos encadeáveis)
# ---------------------------------------------------------------------------

func set_room_name(name: String) -> RoomBuilderBase:
	_room_name = name
	return self

func set_room_type(type: String) -> RoomBuilderBase:
	_room_type = type
	return self

func set_safe_heal(enabled: bool) -> RoomBuilderBase:
	_has_safe_heal = enabled
	return self

func add_enemy(enemy_type: StringName, position: Vector2) -> RoomBuilderBase:
	_enemy_list.append({"type": enemy_type, "pos": position})
	return self

func add_enemies(enemies: Array[Dictionary]) -> RoomBuilderBase:
	_enemy_list.append_array(enemies)
	return self

func set_enemy_count(count: int, enemy_type: StringName = &"basic") -> RoomBuilderBase:
	var positions: Array[Vector2] = [
		Vector2(100, 100),
		Vector2(200, 100),
		Vector2(150, 200),
		Vector2(50, 150),
		Vector2(250, 150),
	]
	for i in range(mini(count, positions.size())):
		add_enemy(enemy_type, positions[i])
	return self

func add_item(item_type: StringName, position: Vector2) -> RoomBuilderBase:
	_item_list.append({"type": item_type, "pos": position})
	return self

func set_exits(directions: Array[Vector2]) -> RoomBuilderBase:
	_door_positions = directions
	return self

func set_player_start(position: Vector2) -> RoomBuilderBase:
	_player_start_position = position
	return self

func set_tilemap(tilemap_path: String) -> RoomBuilderBase:
	_tilemap_source = tilemap_path
	return self

# ---------------------------------------------------------------------------
# Método principal: constrói e retorna a sala pronta
# ---------------------------------------------------------------------------
func build() -> Node2D:
	var room := Node2D.new()
	room.name = _room_name
	# A sala guarda só o ponto de entrada; o player é persistente e pertence ao
	# controlador de Run (decisão A2), que o reposiciona aqui a cada carga.
	room.set_meta("player_start", _player_start_position)

	# 1. Chão / paredes
	room.add_child(_create_tilemap())

	# 2. Portas com IDs únicos (trancadas se a sala tiver inimigos a derrotar)
	var has_enemies: bool = not _enemy_list.is_empty()
	var reward: StringName = RoomRewardConfig.reward_for(_room_type)
	var door_ids: Array[String] = []
	for i in range(_door_positions.size()):
		var door_id := "door_%d" % i
		# Anti-softblock: primeira porta nunca trancada por inimigos
		var locked := has_enemies and i > 0
		room.add_child(_create_door(_door_positions[i], door_id, locked, reward))
		door_ids.append(door_id)

	# 2b. Trigger de cura total para salas seguras
	if _has_safe_heal:
		room.add_child(_create_heal_trigger())

	# 3. Validator ciente das portas desta sala
	room.add_child(_create_room_validator(door_ids))

	# 4. Inimigos: guardados em meta; o controlador de Run os spawna APÓS posicionar
	# o player na sala (evita nascer cercado). As portas já trancam pela lista existir.
	room.set_meta("enemies", _enemy_list.duplicate())

	# 5. Itens consumíveis
	for item_data in _item_list:
		var item := _create_item(item_data["type"])
		if item:
			item.position = item_data["pos"]
			room.add_child(item)

	return room

# ---------------------------------------------------------------------------
# Métodos privados de criação
# ---------------------------------------------------------------------------

func _create_tilemap() -> TileMapLayer:
	var tilemap := TileMapLayer.new()
	tilemap.name = "TileMapLayer"
	var tileset = load(_tilemap_source)
	if tileset:
		tilemap.tile_set = tileset
		_paint_room(tilemap)
	return tilemap


## Pinta um piso retangular com uma borda de paredes (estas têm colisão via tileset).
func _paint_room(tilemap: TileMapLayer) -> void:
	for tx in range(_ROOM_MIN.x, _ROOM_MAX.x + 1):
		for ty in range(_ROOM_MIN.y, _ROOM_MAX.y + 1):
			var is_border: bool = (
				tx == _ROOM_MIN.x or tx == _ROOM_MAX.x
				or ty == _ROOM_MIN.y or ty == _ROOM_MAX.y
			)
			var source: int = _WALL_SOURCE if is_border else _FLOOR_SOURCE
			tilemap.set_cell(Vector2i(tx, ty), source, _TILE_ATLAS)


func _create_room_validator(door_ids: Array[String]) -> Node:
	var validator := Node.new()
	validator.name = "RoomValidator"
	validator.set_script(load("res://scripts/world/room_validator.gd"))
	validator.set("managed_door_ids", door_ids)
	return validator


func _create_door(position: Vector2, door_id: String, locked: bool, reward: StringName = &"none") -> StaticBody2D:
	var scene := load("res://scenes/world/door.tscn") as PackedScene
	var door: StaticBody2D = scene.instantiate()
	door.position = position
	door.name = "Door_" + door_id
	door.set("door_id", door_id)
	door.set("starts_locked", locked)
	door.set("reward_type", reward)
	return door


func _create_heal_trigger() -> Area2D:
	var area := Area2D.new()
	area.name = "HealTrigger"
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(240, 160)
	shape.shape = rect
	area.add_child(shape)
	area.body_entered.connect(func(body: Node) -> void:
		if body.is_in_group("player") and body.has_method("heal"):
			var s: PlayerStats = body.get("stats")
			if s:
				body.heal(s.max_health)
	)
	return area


func _create_item(type: StringName) -> Node:
	var scene := load(_ITEM_SCENE) as PackedScene
	if scene == null:
		return null
	var item := scene.instantiate()
	item.set("consumable_name", str(type))
	return item

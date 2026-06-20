## Observer Pattern — escuta bomb_used do SignalBus para abrir por explosão.
## Strategy Pattern — loot por chave vs. loot por bomba são comportamentos intercambiáveis.
## Aberto com chave via player._try_interact() (tecla E), que chama force_open(&"key").
class_name Chest
extends StaticBody2D

@export var interaction_radius: float = 42.0

var _opened: bool = false

@onready var _sprite: Sprite2D = $Sprite2D

## Catálogo de equipamentos que o baú pode soltar (itens NÃO consumíveis).
## Slots: 1=TORSO, 2=LEG, 3=FOOT, 4=ACESSÓRIO (0=HEAD é reservado para arma).
const _LOOT_TABLE: Array[Dictionary] = [
	{"name": "Jaqueta Reforçada", "slot": 1, "rarity": 1, "mods": {"max_health": 1}},
	{"name": "Calça Ágil",        "slot": 2, "rarity": 0, "mods": {"move_speed": 25.0}},
	{"name": "Botas Velozes",     "slot": 3, "rarity": 2, "mods": {"move_speed": 35.0}},
	{"name": "Anel do Poder",     "slot": 4, "rarity": 2, "mods": {"damage": 6}},
	{"name": "Amuleto Vital",     "slot": 4, "rarity": 3, "mods": {"max_health": 1, "damage": 3}},
]


func _ready() -> void:
	add_to_group("chests")
	SignalBus.bomb_used.connect(_on_bomb_used)
	_play_idle_anim()


func _exit_tree() -> void:
	if SignalBus.bomb_used.is_connected(_on_bomb_used):
		SignalBus.bomb_used.disconnect(_on_bomb_used)


func _play_idle_anim() -> void:
	if _sprite == null:
		return
	var base := _sprite.scale
	var tw := create_tween().set_loops()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_sprite, "scale", base * 1.06, 1.0)
	tw.tween_property(_sprite, "scale", base, 1.0)


# ---------------------------------------------------------------------------
# Explosão (bomba) — abre se a explosão for próxima o bastante. Loot alternativo.
# ---------------------------------------------------------------------------
func _on_bomb_used(origin: Vector2) -> void:
	if _opened:
		return
	if global_position.distance_to(origin) > 120.0:
		return
	force_open(&"bomb")


# ---------------------------------------------------------------------------
# Abertura pública — chamada pelo player (chave) ou por explosão (bomba)
# ---------------------------------------------------------------------------
func force_open(source: StringName) -> void:
	if _opened:
		return
	_opened = true
	GameFacade.play_sound("chest")
	if source == &"bomb":
		_drop_bomb_loot()
	else:
		_drop_standard_loot()
	# Some com um pequeno "pop" depois de cuspir o loot.
	set_deferred("collision_layer", 0)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(_sprite, "scale", Vector2.ZERO, 0.2)
	tw.tween_callback(queue_free)


# ---------------------------------------------------------------------------
# Loot
# ---------------------------------------------------------------------------
func _drop_standard_loot() -> void:
	_spawn_equipment_loot()
	_spawn_coins(randi_range(2, 4))


func _drop_bomb_loot() -> void:
	# Explodir o baú estraga parte do tesouro: só moedas + chance de recurso.
	_spawn_coins(randi_range(3, 6))
	var extra: StringName = RoomRewardConfig.random_bomb_loot()
	match extra:
		&"bomb": _spawn_resource(0, 1)  # Kind.BOMB
		&"key":  _spawn_resource(2, 1)  # Kind.KEY


func _spawn_equipment_loot() -> void:
	var entry: Dictionary = _LOOT_TABLE[randi() % _LOOT_TABLE.size()]
	var equip := EquipmentItem.new()
	equip.item_name = entry["name"]
	equip.slot      = entry["slot"]
	equip.rarity    = entry["rarity"]
	equip.modifiers = entry["mods"]

	var scene := load("res://scenes/world/world_item.tscn") as PackedScene
	if scene == null:
		return
	var node := scene.instantiate()
	node.set("item", equip)
	node.position = position + Vector2(0, -18)
	get_parent().add_child(node)


func _spawn_coins(count: int) -> void:
	for i in range(count):
		_spawn_resource(3, randi_range(3, 8))  # Kind.GOLD


## kind_index segue o enum Pickup.Kind: 0=HEART 1=BOMB 2=KEY 3=GOLD 4=XP.
func _spawn_resource(kind_index: int, amount: int) -> void:
	var scene := load("res://scenes/world/pickup.tscn") as PackedScene
	if scene == null:
		return
	var node := scene.instantiate()
	node.set("kind", kind_index)
	node.set("amount", amount)
	node.position = position + Vector2(randf_range(-22, 22), randf_range(-8, 22))
	get_parent().add_child(node)

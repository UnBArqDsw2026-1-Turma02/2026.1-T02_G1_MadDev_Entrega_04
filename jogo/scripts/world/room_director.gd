## Builder Pattern — Director.
## Mantém referência ao Builder e define receitas pré-definidas de salas.
## Troque o builder via set_builder() para obter representações diferentes
## com o mesmo conjunto de receitas.
class_name RoomDirector
extends RefCounted

var _builder: RoomBuilderBase


func set_builder(builder: RoomBuilderBase) -> void:
	_builder = builder


func build_combat_room(difficulty: int = 1) -> Node2D:
	_builder.set_room_name("Sala de Combate")
	_builder.set_room_type("combat")
	_builder.set_player_start(Vector2(152, 112))
	_builder.set_exits([Vector2(-44, -106), Vector2(300, -106)])

	match difficulty:
		1:
			_builder.add_enemy(&"melee", Vector2(100, 100))
			_builder.add_enemy(&"melee", Vector2(200, 100))
		2:
			_builder.add_enemy(&"melee", Vector2(80, 100))
			_builder.add_enemy(&"ranged", Vector2(220, 100))
			_builder.add_enemy(&"melee", Vector2(150, 200))
		3:
			_builder.add_enemy(&"ranged", Vector2(80, 80))
			_builder.add_enemy(&"melee", Vector2(200, 80))
			_builder.add_enemy(&"ranged", Vector2(140, 180))
			_builder.add_enemy(&"melee", Vector2(80, 200))

	if difficulty >= 2:
		_builder.add_item(&"health", Vector2(300, 150))

	return _builder.build()


func build_rest_room() -> Node2D:
	_builder.set_room_name("Sala de Descanso")
	_builder.set_room_type("rest")
	_builder.set_safe_heal(true)
	_builder.set_player_start(Vector2(152, 112))
	_builder.set_exits([Vector2(-44, -106), Vector2(300, -106)])
	# Sala de suprimentos: cura total (safe_heal) + recursos para as próximas salas.
	_builder.add_item(&"key", Vector2(100, 150))
	_builder.add_item(&"bomb", Vector2(200, 150))
	_builder.add_item(&"xp", Vector2(150, 80))
	return _builder.build()


func build_boss_room() -> Node2D:
	_builder.set_room_name("Sala do Chefão")
	_builder.set_room_type("boss")
	_builder.set_player_start(Vector2(152, 200))
	_builder.set_exits([Vector2(152, -100)])
	_builder.add_enemy(&"boss", Vector2(152, 80))
	return _builder.build()


func build_empty_room() -> Node2D:
	_builder.set_room_name("Sala Vazia")
	_builder.set_room_type("empty")
	_builder.set_player_start(Vector2(152, 112))
	_builder.set_exits([Vector2(-44, -106), Vector2(300, -106), Vector2(152, 250)])
	# Item inicial no chão: ensina a pegar/equipar/dropar (bolso do inventário).
	var starter := EquipmentItem.new()
	starter.item_name = "Anel do Foco"
	starter.slot      = 4   # ACESSÓRIO
	starter.rarity    = 1
	starter.modifiers = {"damage": 4}
	_builder.add_world_item(starter, Vector2(220, 150))
	return _builder.build()


func build_chest_room() -> Node2D:
	_builder.set_room_name("Sala do Baú")
	_builder.set_room_type("chest")
	_builder.set_player_start(Vector2(152, 150))
	_builder.set_exits([Vector2(-44, -106), Vector2(300, -106)])
	_builder.add_chest(Vector2(152, 90))
	# Garante uma chave na sala caso o jogador não tenha trazido uma.
	_builder.add_item(&"key", Vector2(70, 150))
	return _builder.build()


## Catálogo dos 4 vendedores. Cada um vende uma categoria fixa de item.
const _SHOP_CATALOG: Array[Dictionary] = [
	{"category": "Armeiro",   "item_name": "Espada Curta", "item_type": &"weapon",    "rarity": 1, "price": 25},
	{"category": "Equipador", "item_name": "Armadura de Couro", "item_type": &"armor", "rarity": 0, "price": 20},
	{"category": "Boticário", "item_name": "Poção Grande",  "item_type": &"potion",    "rarity": 1, "price": 15},
	{"category": "Mentor",    "item_name": "Tônico de XP",  "item_type": &"status",    "rarity": 2, "price": 30},
]
const _SHOP_NPC_POSITIONS: Array[Vector2] = [
	Vector2(70, 80), Vector2(230, 80), Vector2(70, 180), Vector2(230, 180),
]


func build_shop_room() -> Node2D:
	_builder.set_room_name("Sala da Loja")
	_builder.set_room_type("shop")
	_builder.set_player_start(Vector2(152, 150))
	_builder.set_exits([Vector2(-44, -106), Vector2(300, -106)])
	for i in range(_SHOP_CATALOG.size()):
		var entry: Dictionary = _SHOP_CATALOG[i]
		var item := ItemData.new()
		item.item_name   = entry["item_name"]
		item.item_type   = entry["item_type"]
		item.rarity      = entry["rarity"]
		item.price       = entry["price"]
		_builder.add_npc(entry["category"], item, _SHOP_NPC_POSITIONS[i])
	return _builder.build()

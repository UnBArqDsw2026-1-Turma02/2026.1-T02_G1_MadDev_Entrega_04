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
	_builder.add_item(&"health", Vector2(100, 150))
	_builder.add_item(&"health", Vector2(200, 150))
	_builder.add_item(&"mana", Vector2(150, 80))
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
	return _builder.build()


func build_chest_room() -> Node2D:
	_builder.set_room_name("Sala do Baú")
	_builder.set_room_type("chest")
	_builder.set_player_start(Vector2(152, 112))
	_builder.set_exits([Vector2(-44, -106), Vector2(300, -106)])
	return _builder.build()


func build_shop_room() -> Node2D:
	_builder.set_room_name("Sala da Loja")
	_builder.set_room_type("shop")
	_builder.set_player_start(Vector2(152, 150))
	_builder.set_exits([Vector2(-44, -106), Vector2(300, -106)])
	return _builder.build()

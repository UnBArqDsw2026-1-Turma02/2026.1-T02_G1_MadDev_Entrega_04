## Builder Pattern — interface abstrata do Builder.
## Estenda esta classe para criar builders concretos com representações distintas
## (ex: MinimapRoomBuilder, SerializedRoomBuilder).
class_name RoomBuilderBase
extends RefCounted

func set_room_name(_name: String) -> RoomBuilderBase:
	return self

func set_room_type(_type: String) -> RoomBuilderBase:
	return self

func set_safe_heal(_enabled: bool) -> RoomBuilderBase:
	return self

func add_enemy(_type: StringName, _pos: Vector2) -> RoomBuilderBase:
	return self

func add_enemies(_enemies: Array[Dictionary]) -> RoomBuilderBase:
	return self

func set_enemy_count(_count: int, _type: StringName = &"basic") -> RoomBuilderBase:
	return self

func add_item(_type: StringName, _pos: Vector2) -> RoomBuilderBase:
	return self

func add_npc(_category: String, _item: ItemData, _pos: Vector2) -> RoomBuilderBase:
	return self

func set_exits(_directions: Array[Vector2]) -> RoomBuilderBase:
	return self

func set_player_start(_position: Vector2) -> RoomBuilderBase:
	return self

func set_tilemap(_path: String) -> RoomBuilderBase:
	return self

func build() -> Node2D:
	return null

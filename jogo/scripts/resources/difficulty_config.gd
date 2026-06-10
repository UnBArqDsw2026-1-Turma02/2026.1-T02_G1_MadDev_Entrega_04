class_name DifficultyConfig
extends Resource

@export var enemy_hp_modifier: float = 1.0
@export var enemy_speed_modifier: float = 1.0
@export var item_drop_rate: float = 1.0

func _init() -> void:
	pass

func setup(hp: float, speed: float, drop: float) -> DifficultyConfig:
	enemy_hp_modifier = hp
	enemy_speed_modifier = speed
	item_drop_rate = drop
	return self

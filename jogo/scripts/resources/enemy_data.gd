## Flyweight Pattern — dados imutáveis de tipo de inimigo; uma instância por tipo.
## Fonte única de valores de balanceamento para EnemyBase e EnemyFactory.
class_name EnemyData
extends Resource

@export var enemy_type: StringName = &""
@export var max_health: int        = 30
@export var attack_damage: int     = 5
@export var move_speed: float      = 60.0
@export var defense: int           = 0
@export var resistance: float      = 0.0
@export var xp_reward: int         = 1
@export var spawn_count: int       = 2

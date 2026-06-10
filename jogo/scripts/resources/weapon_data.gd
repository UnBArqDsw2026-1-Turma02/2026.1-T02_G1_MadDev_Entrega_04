## Flyweight Pattern — dados imutáveis de tipo de arma.
class_name WeaponData
extends Resource

enum RangeType { LONG, SHORT }

@export var weapon_name: String     = "Arma"
@export var damage_modifier: int    = 0
@export var range_type: RangeType   = RangeType.LONG
@export var rarity: int             = 0  # índice em RarityConfig
@export var projectile_speed: float = 300.0
@export var shoot_cooldown: float   = 0.3

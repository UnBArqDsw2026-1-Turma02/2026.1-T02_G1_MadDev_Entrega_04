## Flyweight Pattern — dados imutáveis de item consumível ou equipável.
class_name ItemData
extends Resource

@export var item_name: String     = "Item"
@export var item_type: StringName = &""   # ex: &"health", &"mana", &"bomb", &"key"
@export var rarity: int           = 0    # índice em RarityConfig
@export var effect_value: float   = 0.0  # quantidade curada, dano, etc.
@export var price: int            = 10

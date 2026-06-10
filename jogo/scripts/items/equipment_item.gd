## Decorator Pattern — item equipável que modifica PlayerStats ao equipar/desequipar.
## Subclasses definem o slot e os modificadores concretos.
class_name EquipmentItem
extends Resource

@export var item_name: String       = "Equipável"
@export var slot: int               = 0  # player.EquipSlot
@export var rarity: int             = 0  # RarityConfig.Rarity
## Dicionário attribute → delta: {"damage": 5, "max_health": 10}
@export var modifiers: Dictionary   = {}


func on_equip(player: Node) -> void:
	var s: PlayerStats = player.get("stats")
	if s == null:
		return
	for attr in modifiers.keys():
		s.apply_modifier(attr, float(modifiers[attr]))


func on_unequip(player: Node) -> void:
	var s: PlayerStats = player.get("stats")
	if s == null:
		return
	for attr in modifiers.keys():
		s.apply_modifier(attr, -float(modifiers[attr]))

## Componente reutilizável que aplica a cor de raridade ao Sprite2D do nó pai.
## Adicione como filho de qualquer nó de item ou arma; chame apply() após instanciar.
class_name RarityVisual
extends Node

@export var rarity: int = 0  # RarityConfig.Rarity


func _ready() -> void:
	apply(rarity)


func apply(rarity_level: int) -> void:
	rarity = rarity_level
	var color: Color = RarityConfig.color_for(rarity_level)
	var sprite: Sprite2D = _find_sprite(get_parent())
	if sprite:
		sprite.modulate = color


func _find_sprite(node: Node) -> Sprite2D:
	if node is Sprite2D:
		return node as Sprite2D
	for child in node.get_children():
		var result := _find_sprite(child)
		if result:
			return result
	return null

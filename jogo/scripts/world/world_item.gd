## Item NÃO consumível largado no mundo (arma / armadura / acessório).
## Pegar = vai para o bolso do inventário (6 slots). Usa icon.svg tingido pela raridade.
## É a contraparte de player.drop_pocket_item(): pegar/dropar formam o ciclo da Issue 11.
extends Area2D

@export var item: Resource

var _taken: bool = false
var _armed: bool = false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _label: Label = $Label

const _ARM_DELAY: float = 0.4


func _ready() -> void:
	add_to_group("world_items")
	body_entered.connect(_on_body_entered)
	_apply_visual()
	_play_idle_anim()
	# Pequeno atraso: evita recoletar na hora o item recém-largado pelo próprio player.
	await get_tree().create_timer(_ARM_DELAY).timeout
	_armed = true


func _apply_visual() -> void:
	var rarity: int = int(item.get("rarity")) if item != null and item.get("rarity") != null else 0
	if _sprite:
		_sprite.modulate = RarityConfig.color_for(rarity)
	if _label:
		var iname: String = "Item"
		if item != null and item.get("item_name") != null:
			iname = str(item.item_name)
		_label.text = iname


func _play_idle_anim() -> void:
	if _sprite == null:
		return
	var base := _sprite.scale
	var tw := create_tween().set_loops()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_sprite, "scale", base * 1.12, 0.8)
	tw.tween_property(_sprite, "scale", base, 0.8)


func _on_body_entered(body: Node) -> void:
	if _taken or not _armed or not body.is_in_group("player"):
		return
	if not body.has_method("add_to_pocket"):
		return
	if body.has_method("pocket_is_full") and body.pocket_is_full():
		return  # bolso cheio — deixa o item no chão
	var idx: int = body.add_to_pocket(item)
	if idx < 0:
		return
	_taken = true
	SignalBus.item_picked_up.emit({"name": _label.text if _label else "Item"})
	GameFacade.play_sound("pickup")
	set_deferred("monitoring", false)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_sprite, "scale", _sprite.scale * 1.6, 0.15)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.15)
	tw.tween_callback(queue_free)

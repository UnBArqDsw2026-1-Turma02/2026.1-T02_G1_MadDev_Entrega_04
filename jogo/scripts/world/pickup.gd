## Pickup de recurso da run (coração / bomba / chave / ouro / XP).
## Usa o icon.svg como referência visual (tingido por tipo) — RNF de arte.
## Auto-coleta ao encostar no player, com feedback "juicy" (bob + pop).
extends Area2D

enum Kind { HEART, BOMB, KEY, GOLD, XP }

@export var kind: Kind = Kind.HEART
@export var amount: int = 1

var _taken: bool = false
@onready var _sprite: Sprite2D = $Sprite2D

const _TINTS: Dictionary = {
	Kind.HEART: Color(0.93, 0.26, 0.33),
	Kind.BOMB:  Color(0.40, 0.43, 0.55),
	Kind.KEY:   Color(0.96, 0.80, 0.26),
	Kind.GOLD:  Color(1.0, 0.93, 0.40),
	Kind.XP:    Color(0.42, 0.90, 0.52),
}
const _LABELS: Dictionary = {
	Kind.HEART: "Coração",
	Kind.BOMB:  "Bomba",
	Kind.KEY:   "Chave",
	Kind.GOLD:  "Ouro",
	Kind.XP:    "XP",
}


func _ready() -> void:
	add_to_group("pickups")
	if _sprite:
		_sprite.modulate = _TINTS.get(kind, Color.WHITE)
	body_entered.connect(_on_body_entered)
	_play_idle_anim()


## Bob suave + leve respiração de escala — chama atenção sem distrair.
func _play_idle_anim() -> void:
	var base_y := position.y
	var tw := create_tween().set_loops()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "position:y", base_y - 3.0, 0.7)
	tw.tween_property(self, "position:y", base_y, 0.7)


func _on_body_entered(body: Node) -> void:
	if _taken or not body.is_in_group("player"):
		return
	_taken = true
	_apply_to(body)
	SignalBus.item_picked_up.emit({"name": _LABELS.get(kind, "Item"), "kind": int(kind)})
	GameFacade.play_sound("pickup")
	_pop_and_free()


func _apply_to(player: Node) -> void:
	match kind:
		Kind.HEART:
			if player.has_method("heal"):
				player.heal(amount)
		Kind.BOMB:
			GameManager.add_bombs(amount)
		Kind.KEY:
			GameManager.add_keys(amount)
		Kind.GOLD:
			GameManager.add_currency(amount)
		Kind.XP:
			GameManager.add_xp(amount)


func _pop_and_free() -> void:
	set_deferred("monitoring", false)
	var tw := create_tween().set_parallel(true)
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_sprite, "scale", _sprite.scale * 1.8, 0.18)
	tw.tween_property(_sprite, "modulate:a", 0.0, 0.18)
	tw.chain().tween_callback(queue_free)

## Telegrafa onde um inimigo vai nascer ao entrar numa sala (game feel / leitura).
## Pulsa e expande usando o icon.svg tingido de vermelho até o inimigo aparecer.
extends Node2D

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _ring: Sprite2D = $Ring


func _ready() -> void:
	# Marcador central pulsando.
	var base := _sprite.scale
	var tw := create_tween().set_loops()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_sprite, "scale", base * 1.35, 0.35)
	tw.tween_property(_sprite, "scale", base, 0.35)

	# Anel expandindo e sumindo, repetidamente.
	var ring_base := _ring.scale
	var tw2 := create_tween().set_loops()
	tw2.tween_property(_ring, "scale", ring_base * 2.4, 0.6)
	tw2.parallel().tween_property(_ring, "modulate:a", 0.0, 0.6)
	tw2.tween_callback(func() -> void:
		_ring.scale = ring_base
		_ring.modulate.a = 0.5)


## Animação final de "estouro" antes de ser removido (o inimigo toma o lugar).
func burst() -> void:
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(_sprite, "scale", Vector2.ZERO, 0.12)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.12)
	tw.tween_callback(queue_free)

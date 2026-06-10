## Bridge Pattern — Implementação concreta. Renderiza o HUD como texto no
## console (print). Demonstra a troca de implementação sem alterar a abstração:
## basta trocar o renderer no Inspector para mudar como a UI é exibida.
extends UIRenderer
class_name DebugRenderer


func render_hp(value: float, max_value: float) -> void:
	print("[HUD] HP: %d / %d" % [int(value), int(max_value)])


func render_score(value: int) -> void:
	print("[HUD] Score: %d" % value)


func render_time(seconds: float) -> void:
	print("[HUD] Tempo: %.1fs" % seconds)

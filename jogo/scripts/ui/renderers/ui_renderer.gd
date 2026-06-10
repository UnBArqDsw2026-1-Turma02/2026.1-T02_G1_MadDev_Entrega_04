## Bridge Pattern — Implementação (Implementor). Interface abstrata de
## renderização do HUD; subclasses concretas definem COMO os dados são exibidos.
## A HUDAbstraction guarda uma referência para esta interface e delega a ela,
## permitindo trocar a renderização sem alterar a abstração.
extends Resource
class_name UIRenderer


# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
## Recebe as referências de nós da cena coletadas pela HUDAbstraction.
## Implementações que não usam nós (ex.: DebugRenderer) ignoram este método.
func bind(_targets: Dictionary) -> void:
	pass


# ---------------------------------------------------------------------------
# Operações de renderização (virtuais — sobrescritas pelas implementações)
# ---------------------------------------------------------------------------
func render_hp(_value: float, _max_value: float) -> void:
	pass


func render_score(_value: int) -> void:
	pass


func render_time(_seconds: float) -> void:
	pass

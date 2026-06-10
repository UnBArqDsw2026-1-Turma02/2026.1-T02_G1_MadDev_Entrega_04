## Prototype / Value-Object Pattern — ficha centralizada de atributos do jogador.
## Todo o código que lê ou altera Vida, Dano, Velocidade ou Cooldown de Dash deve
## passar por este Resource; nunca acesse os campos do player.gd diretamente.
class_name PlayerStats
extends Resource

signal stats_changed(attribute: String, new_value: float)

# ---------------------------------------------------------------------------
# Valores base (estado inicial, usados em reset_to_base)
# ---------------------------------------------------------------------------
@export var base_max_health: int    = 100
@export var base_damage: int        = 10
@export var base_move_speed: float  = 200.0
@export var base_dash_cd_reduction: float = 0.0  # 0.0..1.0

# ---------------------------------------------------------------------------
# Valores correntes (modificados por itens / level-up)
# ---------------------------------------------------------------------------
var max_health: int       = base_max_health
var damage: int           = base_damage
var move_speed: float     = base_move_speed
var dash_cd_reduction: float = base_dash_cd_reduction

var current_health: int   = base_max_health


# ---------------------------------------------------------------------------
# API pública
# ---------------------------------------------------------------------------

## Aplica um delta a um atributo pelo nome ("max_health", "damage",
## "move_speed", "dash_cd_reduction"). Emite stats_changed.
func apply_modifier(attribute: String, delta: float) -> void:
	match attribute:
		"max_health":
			max_health = maxi(1, max_health + int(delta))
			current_health = mini(current_health, max_health)
		"damage":
			damage = maxi(0, damage + int(delta))
		"move_speed":
			move_speed = maxf(10.0, move_speed + delta)
		"dash_cd_reduction":
			dash_cd_reduction = clampf(dash_cd_reduction + delta, 0.0, 1.0)
		_:
			push_warning("PlayerStats: atributo desconhecido '%s'" % attribute)
			return
	stats_changed.emit(attribute, _get_value(attribute))


## Restaura todos os atributos para os valores base (usado em reset de run).
func reset_to_base() -> void:
	max_health       = base_max_health
	damage           = base_damage
	move_speed       = base_move_speed
	dash_cd_reduction = base_dash_cd_reduction
	current_health   = base_max_health


# ---------------------------------------------------------------------------
# Auxiliar interno
# ---------------------------------------------------------------------------
func _get_value(attribute: String) -> float:
	match attribute:
		"max_health":       return float(max_health)
		"damage":           return float(damage)
		"move_speed":       return move_speed
		"dash_cd_reduction": return dash_cd_reduction
	return 0.0

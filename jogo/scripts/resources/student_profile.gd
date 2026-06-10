## Multiton Pattern — cada perfil é uma instância nomeada única deste Resource.
##                   O registry (StudentProfileRegistry) garante que só exista
##                   uma instância por profile_name em toda a aplicação.
## Decorator Pattern — os modificadores base são o ponto de entrada para que
##                     equipamentos e consumíveis "decorarem" os atributos do jogador.
@tool
extends Resource
class_name StudentProfile

# ---------------------------------------------------------------------------
# Identificação
# ---------------------------------------------------------------------------
@export var profile_name: String = ""

# ---------------------------------------------------------------------------
# Modificadores de atributo (multiplicadores sobre a base do jogador)
# ---------------------------------------------------------------------------
@export var base_hp_modifier: float = 1.0
@export var base_speed_modifier: float = 1.0
@export var base_damage_modifier: float = 1.0

# ---------------------------------------------------------------------------
# Equipamento inicial
# ---------------------------------------------------------------------------
## Caminho para o Resource da arma inicial (ex: "res://resources/weapons/caderno.tres").
## Deixe vazio para começar sem arma.
@export var starting_weapon: String = ""

# ---------------------------------------------------------------------------
# Utilitários
# ---------------------------------------------------------------------------
func apply_to(player: Node) -> void:
	var s: PlayerStats = player.get("stats")
	if s == null:
		push_warning("StudentProfile.apply_to: player sem PlayerStats")
		return
	var hp_delta := roundi(s.base_max_health * (base_hp_modifier - 1.0))
	var spd_delta := s.base_move_speed * (base_speed_modifier - 1.0)
	var dmg_delta := roundi(s.base_damage * (base_damage_modifier - 1.0))
	if hp_delta  != 0: s.apply_modifier("max_health",  float(hp_delta))
	if spd_delta != 0: s.apply_modifier("move_speed",  spd_delta)
	if dmg_delta != 0: s.apply_modifier("damage",      float(dmg_delta))
	s.current_health = s.max_health

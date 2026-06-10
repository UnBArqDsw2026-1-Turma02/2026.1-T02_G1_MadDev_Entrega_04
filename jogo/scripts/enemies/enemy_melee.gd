class_name EnemyMelee
extends EnemyBase

@export var melee_range: float = 40.0

var _player: Node2D = null


func _ready() -> void:
	super._ready()
	_player = get_tree().get_first_node_in_group("player") as Node2D


## Strategy — persegue o jogador diretamente
func _get_move_direction() -> Vector2:
	if _player == null:
		return Vector2.ZERO
	return global_position.direction_to(_player.global_position)


## Hook — só ataca quando o jogador está dentro do alcance corpo a corpo
func can_attack() -> bool:
	if _is_dead:
		return false
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null:
		return false
	return global_position.distance_to(_player.global_position) <= melee_range


## Hook — animação/som de preparação antes do golpe
func prepare_attack() -> void:
	print(name, " se prepara para atacar!")


## Primitive — golpe corpo a corpo com dano aumentado
func execute_attack() -> void:
	print(name, " ATACOU COM A FORÇA BRUTA!")
	_apply_damage_to_player(attack_damage * 2)

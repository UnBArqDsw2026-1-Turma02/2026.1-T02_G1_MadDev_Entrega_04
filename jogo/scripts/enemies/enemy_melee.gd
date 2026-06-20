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


## Hook — telegrafa o golpe com um leve "avanço" (lunge) na direção do player.
func prepare_attack() -> void:
	if _sprite == null or _player == null:
		return
	var lunge := global_position.direction_to(_player.global_position) * 4.0
	var tw := create_tween()
	tw.tween_property(_sprite, "position", lunge, 0.08)
	tw.tween_property(_sprite, "position", Vector2.ZERO, 0.12)


## Primitive — golpe corpo a corpo (todo dano inimigo custa 1 coração ao player).
func execute_attack() -> void:
	_apply_damage_to_player(attack_damage)

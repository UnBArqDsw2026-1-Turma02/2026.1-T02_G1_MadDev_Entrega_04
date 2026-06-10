## Object Pool Pattern — enable()/disable() permitem reusar instâncias sem queue_free().
## Bridge Pattern   — lógica de dano separada da representação visual (Sprite2D).
extends Area2D

# ---------------------------------------------------------------------------
# Atributos
# ---------------------------------------------------------------------------
@export var speed: float = 300.0
@export var damage: int = 10
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT
var _elapsed: float = 0.0
var _pool: Node = null
var _shooter: Node = null


# ---------------------------------------------------------------------------
# Object Pool — interface pública de ativação/desativação
# ---------------------------------------------------------------------------
func enable(spawn_position: Vector2, spawn_direction: Vector2) -> void:
	_shooter = null  # limpa referência ao reutilizar do pool
	global_position = spawn_position
	direction = spawn_direction.normalized()
	_elapsed = 0.0
	show()
	set_process(true)
	monitoring = true
	monitorable = true


func disable() -> void:
	# Evita double-call: pool já define process_mode = DISABLED ao desativar.
	# Isso também protege contra chamada dupla em colisão simultânea com timeout.
	if process_mode == Node.PROCESS_MODE_DISABLED:
		return
	hide()
	set_process(false)
	monitoring = false
	monitorable = false
	if _pool != null and _pool.has_method("return_projectile"):
		_pool.return_projectile(self)


func set_pool(pool: Node) -> void:
	_pool = pool


func set_shooter(shooter: Node) -> void:
	_shooter = shooter


# ---------------------------------------------------------------------------
# Movimento e lifetime
# ---------------------------------------------------------------------------
func _ready() -> void:
	# O pool desativa via process_mode antes de add_child, então o guard
	# em disable() retorna imediatamente sem chamar return_projectile.
	disable()


func _process(delta: float) -> void:
	position += direction * speed * delta
	_elapsed += delta
	if _elapsed >= lifetime:
		disable()


# ---------------------------------------------------------------------------
# Colisão — conecte body_entered ou area_entered via inspetor
# ---------------------------------------------------------------------------
func apply_damage_to(target: Node) -> void:
	# Sem atirador válido (ex: projétil perdido) → apenas some, sem dano.
	if _shooter == null or not is_instance_valid(_shooter):
		call_deferred("disable")
		return
	if target == _shooter:
		return
	var shooter_is_enemy: bool = _shooter.is_in_group("enemy")
	# Fogo amigo: passa direto pelo mesmo time, sem dano e sem sumir.
	if shooter_is_enemy and target.is_in_group("enemy"):
		return
	if not shooter_is_enemy and target.is_in_group("player"):
		return
	# Alvo válido (inimigo/player) ou parede → aplica dano se houver e some.
	if target.has_method("take_damage"):
		target.take_damage(damage)
	# disable adiado: sinais de colisão rodam no passo físico, que trava mudanças
	# de monitoring/process_mode.
	call_deferred("disable")

## Controlador da Run — orquestra o loop sobre nós já montados na cena run.tscn.
## Player, HUD, pausa, pool e tela de fim são FILHOS da cena (não criados em código);
## a sala é só ambiente, recarregada a cada transição. Comunicação via SignalBus.
extends Node2D

const _TOTAL_ROOMS := 12
const _BOSS_INDEX := 11  # Sala 12 (índice 11)
const _ENEMY_SPAWN_DELAY := 0.8  # atraso (s) para o player se situar antes dos inimigos

@onready var _room_host: Node2D = $RoomHost
@onready var _player: CharacterBody2D = $Player

var _current_index: int = 0
var _transitioning: bool = false
var _ended: bool = false


func _ready() -> void:
	SignalBus.door_entered.connect(_on_door_entered)
	SignalBus.room_cleared.connect(_on_room_cleared)
	SignalBus.run_ended.connect(_on_run_ended)
	_apply_selected_profile()
	_load_room(0)


## Issue 17 — aplica o perfil escolhido em character_select.tscn (Multiton via clone_profile).
func _apply_selected_profile() -> void:
	var profile: StudentProfile = StudentProfileRegistry.clone_profile(GameManager.selected_profile_name)
	if profile:
		profile.apply_to(_player)


# ---------------------------------------------------------------------------
# Carga de salas (a sala é gerada pelo Builder/Director; o player é reposicionado)
# ---------------------------------------------------------------------------
func _load_room(index: int) -> void:
	for child in _room_host.get_children():
		child.queue_free()

	var director := RoomDirector.new()
	director.set_builder(RoomBuilder.new())
	var room := _build_for_index(index, director)

	# Reposiciona o player ANTES de a sala entrar na árvore — assim as PassageAreas
	# das portas começam a monitorar com o player já no ponto de entrada (longe das
	# portas), evitando uma transição falsa por sobreposição no spawn.
	if room.has_meta("player_start"):
		_player.global_position = room.get_meta("player_start")
	_room_host.add_child(room)

	_current_index = index
	GameManager.current_room_index = index
	SignalBus.room_entered.emit(index)
	_transitioning = false

	_spawn_enemies_delayed(room)


## Spawna os inimigos da sala (guardados em meta pelo Builder) só depois do player
## já estar posicionado, com um pequeno atraso — assim ele não nasce cercado.
## Usa EnemyFactory (Factory Method), a fonte única de criação de inimigos.
func _spawn_enemies_delayed(room: Node2D) -> void:
	if not room.has_meta("enemies"):
		return
	var enemies: Array = room.get_meta("enemies")
	if enemies.is_empty():
		return

	await get_tree().create_timer(_ENEMY_SPAWN_DELAY).timeout
	# A sala pode ter sido descarregada nesse meio-tempo.
	if not is_instance_valid(room) or not room.is_inside_tree():
		return

	for data in enemies:
		var enemy := EnemyFactory.create(data["type"])
		if enemy == null:
			continue
		enemy.position = data["pos"]
		enemy.add_to_group("enemies")
		room.add_child(enemy)
		SignalBus.enemy_spawned.emit(enemy)


## Mapeia o índice (0..11) para a receita do Director usando GameManager.ROOM_SEQUENCE.
func _build_for_index(index: int, director: RoomDirector) -> Node2D:
	var room_type: String = GameManager.ROOM_SEQUENCE[clampi(index, 0, GameManager.ROOM_SEQUENCE.size() - 1)]
	match room_type:
		"boss":    return director.build_boss_room()
		"rest":    return director.build_rest_room()
		"chest":   return director.build_chest_room() if director.has_method("build_chest_room") else director.build_empty_room()
		"shop":    return director.build_shop_room()  if director.has_method("build_shop_room")  else director.build_empty_room()
		"empty":   return director.build_empty_room()
		_:
			var difficulty := (index - 1) % 3 + 1
			return director.build_combat_room(difficulty)


# ---------------------------------------------------------------------------
# Eventos (via SignalBus)
# ---------------------------------------------------------------------------
func _on_door_entered(_door_id: String) -> void:
	if _transitioning or _ended:
		return
	if _current_index >= _TOTAL_ROOMS - 1:
		return  # já na última sala; a vitória vem de limpar o chefe
	_transitioning = true
	# door_entered chega no passo de física; trocar a sala mexe em colisão/monitoring,
	# o que é proibido durante o flush de queries. Adia para depois do passo.
	_load_room.call_deferred(_current_index + 1)


func _on_room_cleared() -> void:
	# Limpar a sala do chefe encerra a run em vitória.
	if _current_index == _BOSS_INDEX and not _ended:
		GameFacade.victory()


func _on_run_ended(_victory: bool) -> void:
	# A tela de fim (game_over.tscn) cuida de exibir/pausar; aqui só travamos o loop.
	_ended = true

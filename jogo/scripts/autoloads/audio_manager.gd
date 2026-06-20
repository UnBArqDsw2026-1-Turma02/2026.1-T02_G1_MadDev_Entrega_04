## Singleton Pattern — interface global para reprodução de áudio.
## Os nós AudioStreamPlayer devem ser filhos deste autoload e nomeados no inspetor.
## Observer — escuta SignalBus.run_ended para trocar a trilha sonora conforme o resultado.
extends Node

# ---------------------------------------------------------------------------
# Referências aos players (atribua via inspetor ou via @onready se preferir)
# ---------------------------------------------------------------------------
@export var music_player: AudioStreamPlayer
@export var sfx_player: AudioStreamPlayer


func _ready() -> void:
	SignalBus.run_ended.connect(_on_run_ended)


func _on_run_ended(victory: bool) -> void:
	stop_music()
	if victory:
		play_music_by_name("victory")
	else:
		play_music_by_name("defeat")


# ---------------------------------------------------------------------------
# Música de fundo
# ---------------------------------------------------------------------------
func play_music(stream: AudioStream, fade_in: bool = false) -> void:
	if music_player == null:
		return
	music_player.stream = stream
	music_player.volume_db = -80.0 if fade_in else 0.0
	music_player.play()
	if fade_in:
		_fade_volume(music_player, 0.0, 1.5)


func stop_music() -> void:
	if music_player != null:
		music_player.stop()


# ---------------------------------------------------------------------------
# Efeitos sonoros
# ---------------------------------------------------------------------------
func play_sfx(stream: AudioStream) -> void:
	if sfx_player == null:
		return
	sfx_player.stream = stream
	sfx_player.play()


func play_sfx_by_name(sfx_name: String) -> void:
	# Áudio (Issues 19-22) ainda não foi produzido; ausência de arquivo é esperada
	# e silenciosa — não polui o console com erros de load a cada disparo/hit.
	var path := "res://art/sounds/" + sfx_name + ".wav"
	if not ResourceLoader.exists(path):
		return
	var stream := load(path) as AudioStream
	if stream:
		play_sfx(stream)


func play_music_by_name(music_name: String) -> void:
	var path := "res://art/music/" + music_name + ".wav"
	if not ResourceLoader.exists(path):
		return
	var stream := load(path) as AudioStream
	if stream:
		play_music(stream)


# ---------------------------------------------------------------------------
# Utilitário interno
# ---------------------------------------------------------------------------
func _fade_volume(player: AudioStreamPlayer, target_db: float, duration: float) -> void:
	var elapsed: float = 0.0
	var start_db: float = player.volume_db
	while elapsed < duration:
		elapsed += get_process_delta_time()
		player.volume_db = lerpf(start_db, target_db, elapsed / duration)
		await get_tree().process_frame
	player.volume_db = target_db

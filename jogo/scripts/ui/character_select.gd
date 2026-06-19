## Observer — exibe os 4 perfis de StudentProfile e emite profile_selected ao confirmar.
## Multiton Pattern — consulta StudentProfileRegistry para carregar os perfis cacheados.
class_name CharacterSelect
extends Control

## Emitido localmente; main_menu.gd escuta e começa a run com o perfil escolhido.
signal profile_confirmed(profile_name: String)

const _PROFILES: Array[String] = ["Calouro", "Veterano", "Jubilado", "Cara da Atletica"]

var _selected: String = ""

@onready var _grid: GridContainer     = $Center/VBox/Profiles
@onready var _desc: Label             = $Center/VBox/Description
@onready var _btn_confirm: Button     = $Center/VBox/BtnConfirm


func _ready() -> void:
	_btn_confirm.disabled = true
	_btn_confirm.pressed.connect(_on_confirm)
	_build_buttons()


func _build_buttons() -> void:
	for profile_name in _PROFILES:
		var profile: StudentProfile = StudentProfileRegistry.get_profile(profile_name)
		var btn := Button.new()
		btn.text = profile_name if profile == null else "%s\nHP ×%.1f  Dano ×%.1f" % [
			profile_name,
			profile.base_hp_modifier,
			profile.base_damage_modifier,
		]
		btn.toggle_mode = true
		btn.pressed.connect(_on_profile_btn_pressed.bind(profile_name, btn))
		_grid.add_child(btn)


func _on_profile_btn_pressed(profile_name: String, btn: Button) -> void:
	_selected = profile_name
	_btn_confirm.disabled = false

	# Desseleciona outros botões visualmente
	for child in _grid.get_children():
		if child is Button and child != btn:
			child.button_pressed = false

	var profile: StudentProfile = StudentProfileRegistry.get_profile(profile_name)
	if profile:
		_desc.text = profile.description if profile.get("description") != null else profile_name
	else:
		_desc.text = profile_name


func _on_confirm() -> void:
	if _selected.is_empty():
		return
	GameManager.selected_profile_name = _selected
	SignalBus.profile_selected.emit(_selected)
	profile_confirmed.emit(_selected)
	GameFacade.start_run()
	get_tree().change_scene_to_file("res://scenes/world/run.tscn")

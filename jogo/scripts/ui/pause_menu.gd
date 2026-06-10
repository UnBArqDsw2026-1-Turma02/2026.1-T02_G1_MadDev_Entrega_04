extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameFacade.toggle_pause()
		get_viewport().set_input_as_handled()


func _on_game_paused(is_paused: bool) -> void:
	visible = is_paused


func _on_resume_pressed() -> void:
	GameFacade.toggle_pause()


func _on_quit_pressed() -> void:
	GameFacade.end_run(false)
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

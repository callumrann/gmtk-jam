extends CanvasLayer

func _ready() -> void:
	AudioManager.play_music("menu_intro", -10)

func _on_continue_pressed() -> void:
	await AudioManager.play_sfx("click", -10, true, true) # click so i dont gotta wait 8 secs
	SceneManager.show_scene("res://scenes/levels/levels_loader.tscn", true)

func _on_level_select_pressed() -> void:
	SceneManager.show_scene("res://scenes/menus/level_select.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().quit()

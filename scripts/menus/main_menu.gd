extends CanvasLayer

func _ready() -> void:
	pass
	AudioManager.play_music("menu", -10)

func _on_continue_pressed() -> void:
	AudioManager.play_transition("stage_1_intro", -10)
	await get_tree().create_timer(4).timeout
	SceneManager.show_scene("res://scenes/levels/levels_loader.tscn")

func _on_level_select_pressed() -> void:
	SceneManager.show_scene("res://scenes/menus/level_select.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().quit()

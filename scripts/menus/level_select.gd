extends CanvasLayer

func _on_main_menu_pressed() -> void:
	SceneManager.show_scene("res://scenes/menus/main_menu.tscn")


func _on_level_1_pressed() -> void:
	_load_level(1)

func _on_level_2_pressed() -> void:
	_load_level(2)

func _on_level_3_pressed() -> void:
	_load_level(3)

func _load_level(level: int) -> void:
	var level_to_load: int = level * 2 - 1
	LevelManager.current_level = level_to_load
	SceneManager.show_scene("res://scenes/levels/levels_loader.tscn", true)

func _on_thanks_screen_pressed() -> void:
	SceneManager.show_scene("res://scenes/menus/game_finished.tscn")

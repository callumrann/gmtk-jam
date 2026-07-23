extends Node2D

func _ready() -> void:
	SceneManager.subviewport = $"SubViewportContainer/SubViewport"
	SceneManager.show_scene("res://scenes/menus/main_menu.tscn")

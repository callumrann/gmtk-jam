extends Node2D

@onready var cursor: AnimatedSprite2D = $"Cursor"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	SceneManager.subviewport = $"SubViewportContainer/SubViewport"
	SceneManager.show_scene("res://scenes/menus/main_menu.tscn")

func _process(delta: float) -> void:
	cursor.global_position = get_global_mouse_position()

extends Node2D

@onready var cursor: AnimatedSprite2D = $"CanvasLayer/Cursor"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	SceneManager.scene_spawn = $"SceneHolder"
	SceneManager.show_scene("res://scenes/menus/main_menu.tscn")

func _process(delta: float) -> void:
	cursor.global_position = get_viewport().get_mouse_position()

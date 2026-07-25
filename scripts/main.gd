extends Node2D

@onready var cursor: AnimatedSprite2D = $"CursorCanvas/Cursor"

@onready var black_screen: ColorRect = $"BlackScreen/ColorRect"
const k_fade_duration: float = 0.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	SceneManager.scene_spawn = $"SceneHolder"
	SceneManager.main_scene = self
	fade_from_black() # initial fade in
	SceneManager.show_scene("res://scenes/menus/main_menu.tscn")

func _process(delta: float) -> void:
	cursor.global_position = get_viewport().get_mouse_position()

func fade_from_black() -> void:
	black_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(black_screen, "modulate:a", 0, k_fade_duration)
	
	print("fade from")
	await tween.finished

func fade_to_black() -> void:
	black_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(black_screen, "modulate:a", 1, k_fade_duration)
	
	print("fade to")
	await tween.finished

extends Button

@onready var animation: AnimatedSprite2D = $"AnimatedSprite2D"

@export var want_pressed: bool = false
var is_pressed: bool = false

func _on_mouse_entered() -> void:
	if is_pressed:
		return
	animation.play("hover")

func _on_mouse_exited() -> void:
	if is_pressed:
		return
	animation.play("default")

func _on_button_down() -> void:
	if want_pressed:
		return
	animation.play("pressed")

func _on_button_up() -> void:
	if want_pressed:
		return
	animation.play("default")

func _on_pressed() -> void:
	if !want_pressed:
		return
	animation.play("pressed")
	is_pressed = true

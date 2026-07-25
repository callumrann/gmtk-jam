extends Button

@onready var animation: AnimatedSprite2D = $"AnimatedSprite2D"

func _on_mouse_entered() -> void:
	animation.play("hover")

func _on_mouse_exited() -> void:
	animation.play("default")

func _on_button_down() -> void:
	animation.play("pressed")

func _on_button_up() -> void:
	animation.play("default")

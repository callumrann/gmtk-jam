extends CharacterBody2D

@onready var camera: Camera2D = $"Camera2D"
const k_camera_percent_to_mouse: float = 0.3

const SPEED: float = 200

func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	camera.global_position = lerp(position, mouse_position, k_camera_percent_to_mouse)
	rotation = (mouse_position - position).angle()

func _physics_process(delta: float) -> void:
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = movement_vector * SPEED
	move_and_slide()

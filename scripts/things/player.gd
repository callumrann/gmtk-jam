extends CharacterBody2D

const SPEED: float = 200

func _physics_process(delta: float) -> void:
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = movement_vector * SPEED
	move_and_slide()

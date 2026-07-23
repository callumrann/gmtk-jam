extends Area2D

const k_speed: float = 200

var despawn_timer: float = 5.0 # only matters if shot outside

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.RIGHT.rotated(rotation)
	position += direction * k_speed * delta

	if despawn_timer <= 0.0:
		queue_free()
	despawn_timer -= delta

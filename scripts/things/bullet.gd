extends Area2D

@onready var shot_position: Vector2 = position

const k_speed: float = 200
var despawn_timer: float = 5.0 # only matters if shot outside

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.RIGHT.rotated(rotation)
	position += direction * k_speed * delta

	if despawn_timer <= 0.0:
		queue_free()
	despawn_timer -= delta

func _on_body_entered(body: Node2D) -> void:
	if body.get_class() == "TileMapLayer":
		queue_free()

func get_shot_position() -> Vector2:
	return shot_position

extends AnimatedSprite2D

const k_bob_amplitude: float = 5.0
const k_bob_speed: float = 4.0
var base_local_position: Vector2
var time_alive: float = 0.0

func _ready() -> void:
	base_local_position = position

func _process(delta: float) -> void:
	time_alive += delta
	var bob_offset = sin(time_alive * k_bob_speed) * k_bob_amplitude
	
	var bob_direction = Vector2.UP.rotated(rotation)
	position = base_local_position + bob_direction * bob_offset

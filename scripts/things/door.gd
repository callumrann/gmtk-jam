extends Area2D

const k_open_speed: float = 0.15
const k_return_speed: float = 1.0

@onready var start_rotation: float = rotation

var is_moving: bool = false
const k_max_open_angle: float = 110.0
const k_open_wait_time: float = 0.2

func  _process(delta: float) -> void:
	var overlapping_bodies: Array[Node2D] = get_overlapping_bodies()
	for body in overlapping_bodies:
		_slam_check(body)

func _slam_check(body: Node2D) -> void:
	if is_moving:
		return
	
	if body.is_in_group("Player") or body.is_in_group("Enemy"):
		var local_body_pos: Vector2 = to_local(body.global_position)
		var swing_direction: float = 1.0 if local_body_pos.x < 0 else -1.0
		slam_door(swing_direction)

func slam_door(direction: float) -> void:
	is_moving = true
	
	AudioManager.play_sfx("door")
	
	var target_angle: float = start_rotation + (deg_to_rad(k_max_open_angle) * direction)
	
	var tween: Tween = create_tween()

	tween.tween_property(self, "rotation", target_angle, k_open_speed)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_interval(k_open_wait_time) 
	
	tween.tween_property(self, "rotation", start_rotation, k_return_speed)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
		
	await tween.finished
	is_moving = false

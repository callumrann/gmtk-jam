extends CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $"Navigation/NavigationAgent2D"
@onready var player: Node2D = $"../../Player"

@onready var vision_cone: Area2D = $"VisionCone"
@onready var vision_ray: RayCast2D = $"VisionCone/RayCast2D"

const k_move_speed: float = 50.0
const k_turn_speed: float = 10.0

var health: int = 3

func _ready() -> void:
	await get_tree().physics_frame

func _physics_process(delta):
	_check_vision()
	
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var direction = Vector2.ZERO
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	var target_angle = (navigation_agent.target_position - global_position).angle()
	rotation = lerp_angle(rotation, target_angle, k_turn_speed * delta)
	
	velocity = direction * k_move_speed
	move_and_slide()

func _check_vision() -> void:
	var overlapping_areas: Array[Area2D] = vision_cone.get_overlapping_areas()
	for area in overlapping_areas:
		_wall_check(area)

func _wall_check(area: Area2D) -> void:
	vision_ray.target_position = area.global_position - global_position
	vision_ray.rotation = -rotation # kinda cheese
	vision_ray.force_raycast_update()
	
	if vision_ray.is_colliding(): # will collide with wall first if present
		var collider = vision_ray.get_collider()
		if collider == area:
			if area.has_method("get_shot_position"):
				navigation_agent.target_position = area.get_shot_position()
			else:
				navigation_agent.target_position = player.global_position

func on_gunshot_heard() -> void:
	navigation_agent.target_position = player.global_position

func _on_hurtbox_area_entered(area: Area2D) -> void:
	health -= 1
	navigation_agent.target_position = area.get_shot_position()
	if health <= 0:
		queue_free()

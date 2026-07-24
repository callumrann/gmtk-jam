extends CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $"Navigation/NavigationAgent2D"
@onready var player: Node2D = $"../../Player"

const k_vision_range: float = 300.0
const k_vision_angle_degrees: float = 60.0

const k_move_speed: float = 50.0
const k_turn_speed: float = 10.0

var health: int = 3

func _ready() -> void:
	await get_tree().physics_frame

func _physics_process(delta):
	if _check_vision():
		navigation_agent.target_position = player.global_position
	
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var direction = Vector2.ZERO
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	var target_angle = direction.angle()
	rotation = lerp_angle(rotation, target_angle, k_turn_speed * delta)
	
	velocity = direction * k_move_speed
	move_and_slide()

func _check_vision() -> bool:
	var to_player: Vector2 = player.global_position - global_position
	var distance: float = to_player.length()
	if distance > k_vision_range:
		return false
	
	var facing_dir: Vector2 = Vector2.RIGHT.rotated(rotation)
	var angle_to_player: float = rad_to_deg(facing_dir.angle_to(to_player.normalized()))
	
	if abs(angle_to_player) > k_vision_angle_degrees / 2.0:
		return false
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)
	
	if result and result.collider != player:
		return false
	
	return true

func _draw() -> void:
	var facing_dir: Vector2 = Vector2.RIGHT.rotated(rotation)
	var half_angle: float = deg_to_rad(k_vision_angle_degrees / 2.0)
	var points: PackedVector2Array = PackedVector2Array()
	points.append(Vector2.ZERO)
	
	var segments = 16
	for i in range(segments + 1):
		var angle = -half_angle + (half_angle * 2.0 * i / segments)
		var point = facing_dir.rotated(angle) * k_vision_range
		points.append(point)
	
	var color = Color(1, 0, 0, 0.2)
	draw_colored_polygon(points, color)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	health -= 1
	if health <= 0:
		queue_free()

extends CharacterBody2D

# Navigation
@onready var navigation_agent: NavigationAgent2D = $"Navigation/NavigationAgent2D"
@onready var player: Node2D = $"../../Player"

@onready var vision_cone: Area2D = $"VisionCone"
@onready var vision_ray: RayCast2D = $"VisionCone/RayCast2D"

# Bullet shooting
@onready var bullet_spawn_left: Marker2D = $"BulletSpawnerLeft"
@onready var bullet_spawn_right: Marker2D = $"BulletSpawnerRight"
const k_bulletScene: PackedScene = preload("res://scenes/things/enemy_bullet.tscn")

const k_bullet_cooldown: float = 0.1
var bullet_cooldown_remaining: float = 0.0

var player_in_vision: bool = false
var shoot_left: bool = true

const k_shot_variance: float = deg_to_rad(10.0)
const k_shots_per_sweep: int = 3
var shot_offset: int = 0

# Other
const k_move_speed: float = 100.0
const k_turn_speed: float = 20.0

var health: int = 3

func _ready() -> void:
	await get_tree().physics_frame

func _process(delta: float) -> void:
	# Bullet shooting
	if bullet_cooldown_remaining > 0:
		bullet_cooldown_remaining -= delta
	elif player_in_vision:
		# change spray pattern
		var bullet: Area2D = k_bulletScene.instantiate()
		
		if shoot_left:
			bullet.global_position = bullet_spawn_left.global_position
			shoot_left = false
		else:
			bullet.global_position = bullet_spawn_right.global_position
			shoot_left = true
			shot_offset += 1
		bullet.rotation = (player.global_position - bullet.position).angle()
		
		var cycle_index: int = shot_offset % (k_shots_per_sweep * 2 - 2)
		var max_index: int = k_shots_per_sweep - 1
		var ping_pong_index: int = max_index - abs(max_index - cycle_index)
		bullet.rotation += ping_pong_index * k_shot_variance - k_shot_variance
		
		LevelManager.spawn_bullet(bullet)
		bullet_cooldown_remaining = k_bullet_cooldown

func _physics_process(delta):
	# Navigation
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
	player_in_vision = false
	var overlapping_areas: Array[Area2D] = vision_cone.get_overlapping_areas()
	for area in overlapping_areas:
		_wall_check(area)

func _wall_check(area: Area2D) -> void:
	vision_ray.target_position = area.global_position - global_position
	vision_ray.rotation = -rotation # kinda cheese
	vision_ray.force_raycast_update()
	
	if vision_ray.is_colliding(): # wall collision
		return

	if area.has_method("get_shot_position"):
		navigation_agent.target_position = area.get_shot_position()
	else:
		navigation_agent.target_position = player.global_position
		player_in_vision = true

func on_gunshot_heard() -> void:
	navigation_agent.target_position = player.global_position

func _on_hurtbox_area_entered(area: Area2D) -> void:
	health -= 1
	navigation_agent.target_position = area.get_shot_position()
	if health <= 0:
		queue_free()

class_name BaseEnemy
extends CharacterBody2D

# Navigation
@onready var navigation_agent: NavigationAgent2D = $"Navigation/NavigationAgent2D"
@onready var player: Node2D = $"../../Spawn/Player"

@onready var vision_cone: Area2D = $"VisionCone"
@onready var vision_ray: RayCast2D = $"VisionCone/RayCast2D"

@export var patrol_points: Array[Marker2D]
var current_patrol_index: int = 0
var is_alerted: bool = false
const k_wait_before_repatrol: float = 2.0
var wait_timer: float = 0.0

# Bullet shooting
@onready var bullet_spawn_left: Marker2D = $"BulletSpawnerLeft"
@onready var bullet_spawn_right: Marker2D = $"BulletSpawnerRight"
const k_bullet_scene: PackedScene = preload("res://scenes/things/enemy_bullet.tscn")

const k_bullet_cooldown: float = 0.1
var bullet_cooldown_remaining: float = 0.0

var player_in_vision: bool = false
var shoot_left: bool = true

const k_shot_variance: float = deg_to_rad(10.0)
const k_shots_per_sweep: int = 3
var shot_offset: int = 0

# Animation
@onready var top_animation: AnimatedSprite2D = $"TopAnimation"
@onready var bottom_animation: AnimatedSprite2D = $"BottomAnimation"

const k_wind_up_time: float = 0.17
var wind_up_timer: float = 0.0
var wound_up: bool = false

# Other
const k_dead_scene: PackedScene = preload("res://scenes/things/dead_enemy.tscn")

const k_patrol_speed: float = 100.0
var alert_speed: float = 200.0 # not const for melee change (yes sus this way)
const k_turn_speed: float = 20.0
const k_slow_turn_speed: float = 5.0 # when not alerted

const k_starting_health: int = 1
var health: int = k_starting_health

const k_bullets_on_death: int = 2

func _ready() -> void:
	await get_tree().physics_frame # dont remember why this is here, but keep i guess
	if patrol_points:
		navigation_agent.target_position = patrol_points[0].position

func _process(delta: float) -> void:
	if wait_timer > 0:
		wait_timer -= delta
	
	# Bullet shooting
	if wind_up_timer > 0:
		wind_up_timer -= delta
	
	elif bullet_cooldown_remaining > 0:
		bullet_cooldown_remaining -= delta
	
	elif player_in_vision:
		if !wound_up:
			wound_up = true
			wind_up_timer = k_wind_up_time
			top_animation.play("windup")
			return
		
		top_animation.play("shoot")
		var bullet: Area2D = k_bullet_scene.instantiate()
		
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
	
	if not player_in_vision:
		if wound_up:
			wound_up = false
			top_animation.play("winddown")
			await top_animation.animation_finished
			top_animation.play("default")

func _physics_process(delta):	
	# Navigation
	_check_vision()
	
	if navigation_agent.is_navigation_finished():
		if is_alerted:
			is_alerted = false
			wait_timer = k_wait_before_repatrol
			velocity = Vector2.ZERO
			bottom_animation.play("default")
			move_and_slide()
			return
		
		elif patrol_points:
			if wait_timer > 0:
				velocity = Vector2.ZERO
				bottom_animation.play("default")
				move_and_slide()
				return
			current_patrol_index += 1
			navigation_agent.target_position = patrol_points[current_patrol_index % patrol_points.size()].position
		
		else:
			velocity = Vector2.ZERO
			bottom_animation.play("default")
			move_and_slide()
			return
	
	var direction = Vector2.ZERO
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	if is_alerted:
		var target_angle = (navigation_agent.target_position - global_position).angle()
		rotation = lerp_angle(rotation, target_angle, k_turn_speed * delta)
	else: # turn towards next position and turn slower
		var target_angle = (navigation_agent.get_next_path_position() - global_position).angle()
		rotation = lerp_angle(rotation, target_angle, k_slow_turn_speed * delta)
	
	if is_alerted:
		velocity = direction * alert_speed
	else:
		velocity = direction * k_patrol_speed
	
	bottom_animation.global_rotation = velocity.angle()
	bottom_animation.play("walking")
	
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
	
	is_alerted = true
	if area.has_method("get_shot_position"):
		navigation_agent.target_position = area.get_shot_position()
	else:
		navigation_agent.target_position = player.global_position
		player_in_vision = true

func on_gunshot_heard() -> void:
	navigation_agent.target_position = player.global_position

func _on_hurtbox_area_entered(area: Area2D) -> void:
	_take_damage()

func _take_damage() -> void:
	health -= 1
	#navigation_agent.target_position = area.get_shot_position()
	if health <= 0:
		LevelManager.enemy_dead()
		
		var dead_body: Area2D = k_dead_scene.instantiate()
		dead_body.global_position = global_position
		dead_body.rotation = rotation
		dead_body.set_bullet_count(k_bullets_on_death)
		
		get_parent().call_deferred("add_child", dead_body)
		queue_free()

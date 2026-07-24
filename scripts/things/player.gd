extends CharacterBody2D

# Camera control
@onready var camera: Camera2D = $"Camera2D"
const k_camera_percent_to_mouse: float = 0.3

# Bullet shooting
@onready var bullet_spawn_left: Marker2D = $"BulletSpawnerLeft"
@onready var bullet_spawn_right: Marker2D = $"BulletSpawnerRight"
const k_bullet_scene: PackedScene = preload("res://scenes/things/player_bullet.tscn")

const k_starting_bullets = 5
var left_bullets: int = k_starting_bullets
var right_bullets: int = k_starting_bullets

const k_bullet_cooldown: float = 0.3
var bullet_cooldown_remaining: float = 0.0

@onready var gun_noise: Area2D = $"GunNoise"

# Other
const k_move_speed: float = 400
var health: int = 7

func _process(delta: float) -> void:
	# Camera control
	var mouse_position = get_global_mouse_position()
	camera.global_position = lerp(position, mouse_position, k_camera_percent_to_mouse)
	rotation = (mouse_position - position).angle()
	
	# Bullet shooting
	if bullet_cooldown_remaining > 0:
		bullet_cooldown_remaining -= delta
	elif Input.is_action_just_pressed("shoot_left"):
		if left_bullets > 0:
			var bullet: Area2D = k_bullet_scene.instantiate()
			bullet.global_position = bullet_spawn_left.global_position
			bullet.rotation = (mouse_position - bullet.position).angle()
			
			LevelManager.spawn_bullet(bullet)
			LevelManager.update_bullet_ui("left")
			
			left_bullets -= 1
			bullet_cooldown_remaining = k_bullet_cooldown
			
			_alert_nearby_enemies(position)
		else:
			print("no more left bullets")
	
	elif Input.is_action_just_pressed("shoot_right"):
		if right_bullets > 0:
			var bullet: Area2D = k_bullet_scene.instantiate()
			bullet.global_position = bullet_spawn_right.global_position
			bullet.rotation = (mouse_position - bullet.position).angle()
			
			LevelManager.spawn_bullet(bullet)
			LevelManager.update_bullet_ui("right")

			right_bullets -= 1
			bullet_cooldown_remaining = k_bullet_cooldown
			
			_alert_nearby_enemies(position)
		else:
			print("no more right bullets")

func _alert_nearby_enemies(origin: Vector2) -> void:
	var overlapping_areas: Array[Area2D]  = gun_noise.get_overlapping_areas()
	for area in overlapping_areas:
		area.get_parent().on_gunshot_heard()

func _physics_process(delta: float) -> void:
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = movement_vector * k_move_speed
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	health -= 1
	LevelManager.reduce_player_health()
	if health <= 0:
		print("man i'm dead")

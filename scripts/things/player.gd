extends CharacterBody2D

# Camera control
@onready var camera: Camera2D = $"Camera2D"
const k_camera_percent_to_mouse: float = 0.3

# Bullet shooting
@onready var bullet_spawn_left: Marker2D = $"BulletSpawnerLeft"
@onready var bullet_spawn_right: Marker2D = $"BulletSpawnerRight"
const k_bulletScene: PackedScene = preload("res://scenes/things/bullet.tscn")

const k_starting_bullets = 5
var left_bullets: int = k_starting_bullets
var right_bullets: int = k_starting_bullets

const k_bullet_cooldown: float = 0.3
var bullet_cooldown_remaining: float = 0.0

const k_movement_speed: float = 200

func _process(delta: float) -> void:
	# Camera control
	var mouse_position = get_global_mouse_position()
	camera.global_position = lerp(position, mouse_position, k_camera_percent_to_mouse)
	rotation = (mouse_position - position).angle()
	
	# Bullet shooting
	if (bullet_cooldown_remaining > 0):
		bullet_cooldown_remaining -= delta
	elif Input.is_action_just_pressed("shoot_left"):
		if left_bullets > 0:
			var bullet: Area2D = k_bulletScene.instantiate()
			bullet.global_position = bullet_spawn_left.global_position
			bullet.rotation = (mouse_position - bullet.position).angle()
			LevelManager.spawn_bullet(bullet)

			left_bullets -= 1
			bullet_cooldown_remaining = k_bullet_cooldown
		else:
			print("no more left bullets")
	
	elif Input.is_action_just_pressed("shoot_right"):
		if right_bullets > 0:
			var bullet: Area2D = k_bulletScene.instantiate()
			bullet.global_position = bullet_spawn_right.global_position
			bullet.rotation = (mouse_position - bullet.position).angle()
			LevelManager.spawn_bullet(bullet)

			right_bullets -= 1
			bullet_cooldown_remaining = k_bullet_cooldown
		else:
			print("no more right bullets")

func _physics_process(delta: float) -> void:
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = movement_vector * k_movement_speed
	move_and_slide()

# make bullet damange enemies
# consider bullet inside player

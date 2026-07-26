extends CharacterBody2D

# Bullet shooting
@onready var bullet_spawn_left: Marker2D = $"BulletSpawnerLeft"
@onready var bullet_spawn_right: Marker2D = $"BulletSpawnerRight"
const k_bullet_scene: PackedScene = preload("res://scenes/things/player_bullet.tscn")

const k_max_ammo = 5
var left_bullets: int = k_max_ammo
var right_bullets: int = k_max_ammo

const k_bullet_delay: float = 0.0 # based on animation frame rate
const k_bullet_cooldown: float = 0.3
var bullet_cooldown_remaining: float = 0.0

@onready var gun_noise: Area2D = $"GunNoise"

# Other
@onready var top_animation: AnimatedSprite2D = $"TopAnimation"
@onready var bottom_animation: AnimatedSprite2D = $"BottomAnimation"

const k_move_speed: float = 400
var health: int = 7
var dead: bool = false

var level_complete: bool = false

func _ready() -> void:
	top_animation.animation_finished.connect(_top_animation_finished)

func _process(delta: float) -> void:
	if level_complete: return
	
	if dead:
		if Input.is_action_just_pressed("interact"):
			LevelManager.restart_level()
		return
	
	var mouse_position: Vector2 = get_global_mouse_position()
	rotation = (mouse_position - global_position).angle()
	
	# Bullet shooting
	if bullet_cooldown_remaining > 0:
		bullet_cooldown_remaining -= delta
	elif Input.is_action_just_pressed("shoot_left"):
		if left_bullets > 0:
			bullet_cooldown_remaining = k_bullet_cooldown
			_play_the_animation("shoot_left", true)
			await get_tree().create_timer(k_bullet_delay).timeout
			
			var bullet: Area2D = k_bullet_scene.instantiate()
			bullet.global_position = bullet_spawn_left.global_position
			bullet.rotation = (mouse_position - bullet.position).angle()
			
			LevelManager.spawn_bullet(bullet)
			LevelManager.update_bullet_ui("left")
			
			left_bullets -= 1
			_alert_nearby_enemies(position)
		else:
			print("no more left bullets")
	
	elif Input.is_action_just_pressed("shoot_right"):
		if right_bullets > 0:
			bullet_cooldown_remaining = k_bullet_cooldown
			_play_the_animation("shoot_right", true)
			await get_tree().create_timer(k_bullet_delay).timeout
			
			var bullet: Area2D = k_bullet_scene.instantiate()
			bullet.global_position = bullet_spawn_right.global_position
			bullet.rotation = (mouse_position - bullet.position).angle()
			
			LevelManager.spawn_bullet(bullet)
			LevelManager.update_bullet_ui("right")

			right_bullets -= 1
			_alert_nearby_enemies(position)
		else:
			print("no more right bullets")

func _alert_nearby_enemies(origin: Vector2) -> void:
	var overlapping_areas: Array[Area2D]  = gun_noise.get_overlapping_areas()
	for area in overlapping_areas:
		area.get_parent().on_gunshot_heard()

func _physics_process(delta: float) -> void:
	if dead or level_complete: return
	
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if movement_vector == Vector2.ZERO:
		bottom_animation.play("default")
	else:
		bottom_animation.global_rotation = movement_vector.angle()
		_play_the_animation("walking", false)
		
		var mouse_angle: float = (get_global_mouse_position() - global_position).angle()
		var walk_angle: float = movement_vector.angle()
		var angle_diff: float = angle_difference(walk_angle, mouse_angle)
		if abs(rad_to_deg(angle_diff)) >= 90:
			bottom_animation.global_rotation += deg_to_rad(180)
	
	velocity = movement_vector * k_move_speed
	move_and_slide()
	
	# Door maxing
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			collider.apply_central_impulse(collision.get_normal() * -100.0)

const k_fancy_text_scene: PackedScene = preload("res://scenes/things/fancy_text.tscn")

func add_bullets(count: int) -> void:
	var bullets_recieved: int = 0
	while count > 0 and (left_bullets < k_max_ammo or right_bullets < k_max_ammo):
		if right_bullets < left_bullets:
			right_bullets += 1
			count -= 1
			bullets_recieved += 1
		else:
			left_bullets += 1
			count -= 1
			bullets_recieved += 1
	LevelManager.update_bullet_ui("N/A", left_bullets, right_bullets)
	
	var text_instance = k_fancy_text_scene.instantiate()
	text_instance.global_position = global_position + Vector2(0, -40)
	get_tree().current_scene.add_child(text_instance)
	text_instance.setup("+ " + str(bullets_recieved) + " BULLETS", 12)

func level_finished() -> void:
	level_complete = true
	$"Hurtbox/CollisionShape2D".set_deferred("disabled", true)
	$"WallCollider".set_deferred("disabled", true)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var damage: int
	if area.name == "Hitbox":
		damage = 4
	else:
		damage = 1
	health -= damage
	LevelManager.reduce_player_health(damage)
	
	if health <= 0:
		die()

func die() -> void:
	LevelManager.player_dead()
		
	$"Hurtbox/CollisionShape2D".set_deferred("disabled", true)
	$"WallCollider".set_deferred("disabled", true)
	top_animation.modulate = Color(0, 1, 0) # replace with animation
	bottom_animation.play("default")
	dead = true

func _top_animation_finished() -> void:
	_play_the_animation("default", true)

func _play_the_animation(name: String, top: bool) -> void:
	if top:
		if health < 4:
			top_animation.play(name + "_damaged")
		else:
			top_animation.play(name)
	else:
		if health < 4:
			bottom_animation.play(name + "_damaged")
		else:
			bottom_animation.play(name)

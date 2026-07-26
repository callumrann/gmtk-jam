extends CanvasLayer

@onready var bulletsContainer: HBoxContainer = $"Control/BulletBackground/Bullets"

const k_max_ammo: int = 5
var left_bullets: int = k_max_ammo
var right_bullets: int = k_max_ammo

func consume_bullet(side_shot: String) -> void:
	shake_bulletbar()
	
	if side_shot == "left":
		if left_bullets <= 0:
			return
		
		for i in range(bulletsContainer.get_child_count()):
			var bullet: TextureRect = bulletsContainer.get_child(i)
			if bullet.modulate.a != 0:
				bullet.modulate.a = 0
				left_bullets -= 1
				break
	
	elif side_shot == "right":
		if right_bullets <= 0:
			return
		
		var bullet_count: int = bulletsContainer.get_child_count()
		for i in range(bullet_count):
			var bullet: TextureRect = bulletsContainer.get_child(bullet_count - 1 - i)
			if bullet.modulate.a != 0:
				bullet.modulate.a = 0
				right_bullets -= 1
				break

func add_bullets(left: int, right: int) -> void:
	left_bullets = left
	right_bullets = right
	
	var bullets_added: bool = false
	
	for i in range(left_bullets):
		var bullet: TextureRect = bulletsContainer.get_child(k_max_ammo - 1 - i)
		if bullet.modulate.a == 0:
			bullet.modulate.a = 1
			bullets_added = true
	
	for i in range(right_bullets):
		var bullet: TextureRect = bulletsContainer.get_child(k_max_ammo + i)
		if bullet.modulate.a == 0:
			bullet.modulate.a = 1
			bullets_added = true
	
	if bullets_added:
		shake_bulletbar()

@onready var segmentsContainer: HBoxContainer = $"Control/HealthBarBackground/HealthSegments"

func reduce_health(amount: int) -> void:
	shake_health()
	
	var segment_count: int = segmentsContainer.get_child_count()
	for i in range(segment_count):
		var segment: TextureRect = segmentsContainer.get_child(segment_count - 1 - i)
		if segment.modulate.a != 0:
			segment.modulate.a = 0
			amount -= 1
			if amount <= 0:
				break

@onready var player_dead_hud: PanelContainer = $"Control/PlayerDead"

func show_player_dead_popup() -> void:
	player_dead_hud.visible = true

func reset_hud() -> void:
	left_bullets = k_max_ammo
	right_bullets = k_max_ammo
	
	for i in range(bulletsContainer.get_child_count()):
		var bullet: TextureRect = bulletsContainer.get_child(i)
		bullet.modulate.a = 1
	
	for i in range(segmentsContainer.get_child_count()):
		var segment: TextureRect = segmentsContainer.get_child(i)
		segment.modulate.a = 1
	
	player_dead_hud.visible = false


'''
====== VFX ======
'''
@onready var healthbar: TextureRect = $"Control/HealthBarBackground"
var health_start_position: Vector2
var health_tween: Tween

const k_health_shake_duration: float = 0.4
const k_health_shake_strength: float = 8.0
const k_health_shake_count: int = 6

@onready var bulletbar: TextureRect = $"Control/BulletBackground"
var bulletbar_start_position: Vector2
var bulletbar_tween: Tween

const k_bulletbar_shake_duration: float = 0.4
const k_bulletbar_shake_strength: float = 8.0
const k_bulletbar_shake_count: int = 6

func _ready() -> void:
	health_start_position = healthbar.global_position
	bulletbar_start_position =  bulletbar.global_position

func shake_health() -> void:
	if health_tween and health_tween.is_valid():
		health_tween.kill()
	
	healthbar.position = health_start_position
	
	health_tween = create_tween()
	var step_time: float = k_health_shake_duration / k_health_shake_count
	
	for i in k_health_shake_count:
		 # decreasing amplitude
		var strength: float = k_health_shake_strength * (1.0 - float(i) / k_health_shake_count)
		var offset = strength if i % 2 == 0 else -strength
		health_tween.tween_property(healthbar, "position:y", health_start_position.y + offset, step_time)
	health_tween.tween_property(healthbar, "position", health_start_position, step_time)

func shake_bulletbar() -> void:
	if bulletbar_tween and bulletbar_tween.is_valid():
		bulletbar_tween.kill()
	
	bulletbar.position = bulletbar_start_position
	
	bulletbar_tween = create_tween()
	var step_time: float = k_bulletbar_shake_duration / k_bulletbar_shake_count
	
	for i in k_bulletbar_shake_count:
		 # decreasing amplitude
		var strength: float = k_bulletbar_shake_strength * (1.0 - float(i) / k_bulletbar_shake_count)
		var offset = strength if i % 2 == 0 else -strength
		bulletbar_tween.tween_property(bulletbar, "position:y", bulletbar_start_position.y + offset, step_time)
	bulletbar_tween.tween_property(bulletbar, "position", bulletbar_start_position, step_time)

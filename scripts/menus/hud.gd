extends CanvasLayer

@onready var bulletsContainer: HBoxContainer = $"Control/BulletBackground/Bullets"

const k_max_ammo: int = 5
var left_bullets: int = k_max_ammo
var right_bullets: int = k_max_ammo

func consume_bullet(side_shot: String) -> void:
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
	
	for i in range(left_bullets):
		var bullet: TextureRect = bulletsContainer.get_child(k_max_ammo - 1 - i)
		if bullet.modulate.a == 0:
			bullet.modulate.a = 1
	
	for i in range(right_bullets):
		var bullet: TextureRect = bulletsContainer.get_child(k_max_ammo + i)
		if bullet.modulate.a == 0:
			bullet.modulate.a = 1

@onready var segmentsContainer: HBoxContainer = $"Control/HealthBarBackground/HealthSegments"

func reduce_health(amount: int) -> void:
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

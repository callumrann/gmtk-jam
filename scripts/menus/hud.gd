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

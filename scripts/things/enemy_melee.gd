extends BaseEnemy

@onready var hitbox_collision: CollisionShape2D = $"Hitbox/CollisionShape2D"

const k_swing_distance: float = 100.0
var attacking: bool = false

func _ready() -> void:
	alert_speed = 300.0

func _process(delta: float) -> void:
	if wait_timer > 0:
		wait_timer -= delta
	
	if (player.global_position - global_position).length() < k_swing_distance:
		alert_speed = 300.0
		if player_in_vision and not attacking:
			attacking = true
			top_animation.play("windup")
			await top_animation.animation_finished
			top_animation.play("swing")
			AudioManager.play_sfx("enemy_shoot")
			hitbox_collision.set_deferred("disabled", false)
			await top_animation.animation_finished
			top_animation.play("winddown")
			hitbox_collision.set_deferred("disabled", true)
			await top_animation.animation_finished
			top_animation.play("default")
			attacking = false
	else:
		alert_speed = 500.0

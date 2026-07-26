extends Area2D

@onready var animation: AnimatedSprite2D = $"AnimatedSprite2D"
@onready var blood: AnimatedSprite2D = $"Blood"

var bullet_count: int
var bullets_collected: bool = false

func _process(delta: float) -> void:
	var overlapping_areas = get_overlapping_areas()
	if !bullets_collected and overlapping_areas and Input.is_action_just_pressed("interact"):
		LevelManager.update_bullet_count(bullet_count)
		bullets_collected = true
		animation.play("default")

func set_bullet_count(count: int) -> void:
	bullet_count = count

func _on_area_entered(area: Area2D) -> void:
	if bullets_collected == false:
		animation.play("glow")

func _on_area_exited(area: Area2D) -> void:
	animation.play("default")

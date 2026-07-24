extends Area2D

var bullet_count: int
var bullets_collected: bool = false

func _process(delta: float) -> void:
	var overlapping_areas = get_overlapping_areas()
	if !bullets_collected and overlapping_areas and Input.is_action_just_pressed("interact"):
		LevelManager.update_bullet_count(bullet_count)
		bullets_collected = true

func set_bullet_count(count: int) -> void:
	bullet_count = count

func _on_area_entered(area: Area2D) -> void:
	# apply glow effect
	pass

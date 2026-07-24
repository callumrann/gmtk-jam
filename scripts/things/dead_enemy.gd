extends Area2D

var bullet_count: int

func _process(delta: float) -> void:
	var overlapping_areas = get_overlapping_areas()
	if overlapping_areas and Input.is_action_just_pressed("interact"):
		LevelManager.update_bullet_ui("N/A", bullet_count)

func set_bullet_count(count: int) -> void:
	bullet_count = 20

func _on_area_entered(area: Area2D) -> void:
	# apply glow effect
	pass

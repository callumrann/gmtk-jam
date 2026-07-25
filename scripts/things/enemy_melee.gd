extends BaseEnemy

func _process(delta: float) -> void:
	if wait_timer > 0:
		wait_timer -= delta

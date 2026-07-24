extends Node2D

var levelsLoader: Node2D

var current_level: int = 1

func spawn_bullet(bullet: Node2D) -> void:
	levelsLoader.spawned_level.get_node("BulletContainer").add_child(bullet)

func update_bullet_ui(side_shot: String = "N/A", bullets_gained: int = 0) -> void:
	levelsLoader.update_bullet_ui(side_shot, bullets_gained)

func reduce_player_health() -> void:
	levelsLoader.reduce_player_health()

func reset_hud() -> void:
	levelsLoader.reset_hud()

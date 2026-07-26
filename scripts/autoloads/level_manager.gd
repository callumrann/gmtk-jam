extends Node2D

var levelsLoader: Node2D
var current_level: int = 1

func spawn_bullet(bullet: Node2D) -> void:
	levelsLoader.spawned_level.get_node("BulletContainer").add_child(bullet)

func update_bullet_count(count: int) -> void:
	levelsLoader.update_bullet_count(count)

func update_bullet_ui(side_shot: String = "N/A", left_bullets: int = 0, right_bullets: int = 0) -> void:
	levelsLoader.update_bullet_ui(side_shot, left_bullets, right_bullets)

func reduce_player_health(amount: int) -> void:
	levelsLoader.reduce_player_health(amount)

func player_dead() -> void:
	levelsLoader.player_dead()

func reset_hud() -> void:
	levelsLoader.reset_hud()

func load_next_level() -> void:
	current_level += 1
	levelsLoader.load_level(current_level)
	
func restart_level() -> void:
	levelsLoader.restart_level()

func enemy_dead() -> void:
	levelsLoader.enemy_dead()

func level_complete() -> void:
	levelsLoader.level_complete()

func toggle_bullet_ui() -> void: # for punchout
	levelsLoader.toggle_bullet_ui()

func toggle_health_ui() -> void:
	levelsLoader.toggle_health_ui()

extends Node2D

'''
====== Level Loading ======
'''

@onready var level_container: Node2D = $"LevelContainer"
var spawned_level: Node2D

func _ready() -> void:
	LevelManager.levelsLoader = self
	load_level(LevelManager.current_level)
	AudioManager.play_music("stage_1_intro", -10)

var levels: Array[String] = [
	"res://scenes/levels/level1.tscn","res://scenes/levels/level2.tscn",
	]

func load_level(level: int) -> void:
	await SceneManager.fade_to_black()
	call_deferred("_do_load_level", level)
	await SceneManager.fade_from_black()

func _do_load_level(level: int) -> void:
	if level > levels.size():
		SceneManager.show_scene("res://scenes/menus/game_finished.tscn")
		return
	
	for child in level_container.get_children():
		child.queue_free()
	
	var new_level = load(levels[level- 1]).instantiate()
	level_container.add_child(new_level)
	spawned_level = new_level

'''
====== Pause Screen ======
'''

@onready var pause_menu: CanvasLayer = $"UI/PauseMenu"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _toggle_pause():
	pause_menu.visible = !pause_menu.visible
	get_tree().paused = pause_menu.visible
	
	if pause_menu.visible:
		AudioManager.play_sfx("pause_in", -15)
	else:
		AudioManager.play_sfx("pause_out", -15)

func _on_resume_pressed() -> void:
	_toggle_pause()

func _on_restart_pressed() -> void:
	restart_level()
	_toggle_pause()

func restart_level() -> void:
	load_level(LevelManager.current_level)

func _on_next_level_pressed() -> void:
	LevelManager.current_level += 1
	load_level(LevelManager.current_level)
	_toggle_pause()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	SceneManager.show_scene("res://scenes/menus/main_menu.tscn", true)

'''
====== HUD ======
'''
@onready var hud: CanvasLayer = $"UI/HUD"

func update_bullet_count(count: int) -> void:
	spawned_level.give_player_bullets(count)

func update_bullet_ui(side_shot: String = "N/A", left_bullets: int = 0, right_bullets: int = 0) -> void:
	if side_shot != "N/A":
		hud.consume_bullet(side_shot)
	
	if (left_bullets + right_bullets) > 0:
		hud.add_bullets(left_bullets, right_bullets)

func reduce_player_health() -> void:
	hud.reduce_health()

func player_dead() -> void:
	hud.show_player_dead_popup()

func reset_hud() -> void:
	hud.reset_hud()

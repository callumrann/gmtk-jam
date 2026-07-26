extends Node2D

'''
====== Level Loading ======
'''

@onready var level_container: Node2D = $"LevelContainer"
var spawned_level: Node

const k_newspaper_mod: int = 1

var levels: Array[String] = [
	"res://scenes/newspapers/newspaper_1.tscn", "res://scenes/levels/level1.tscn", 
	"res://scenes/newspapers/newspaper_2.tscn", "res://scenes/levels/level2.tscn",
	]

func _ready() -> void:
	LevelManager.levelsLoader = self
	
	if LevelManager.current_level % 2 != k_newspaper_mod:
		LevelManager.current_level -= 1 # force start on newspaper
	load_level(LevelManager.current_level)

func load_level(level: int, reset: bool = false) -> void: # reset for death or restart
	if level % 2 != k_newspaper_mod:
		if !reset:
			AudioManager.play_music("battle_intro", 0)
			await get_tree().create_timer(2.0).timeout
			await SceneManager.fade_to_black()
		else:
			await SceneManager.fade_to_black()
	else:
		await SceneManager.fade_to_black()

	call_deferred("_do_load_level", level)
	
	if level == k_newspaper_mod and !reset: # so that it plays the newspaper scene only on the first newspaper
		AudioManager.play_music("newspaper_scene", 0)
	await SceneManager.fade_from_black()

func _do_load_level(level: int) -> void:
	if level > levels.size():
		SceneManager.show_scene("res://scenes/menus/game_finished.tscn")
		return
	
	for child in level_container.get_children():
		child.queue_free()
	
	if level % 2 != k_newspaper_mod:
		hud.visible = true
	else:
		hud.visible = false
	
	var new_level = load(levels[level- 1]).instantiate()
	level_container.add_child(new_level)
	spawned_level = new_level
	
	pause_menu.visible = false
	level_complete_menu.visible = false
	get_tree().paused = false

'''
====== Pause Screen ======
'''

@onready var pause_menu: CanvasLayer = $"UI/PauseMenu"

func _unhandled_input(event: InputEvent) -> void:
	# can't pause on newspaper
	if event.is_action_pressed("pause") and LevelManager.current_level % 2 != k_newspaper_mod:
		pause_menu.visible = !pause_menu.visible
		get_tree().paused = pause_menu.visible
		if pause_menu.visible:
			AudioManager.toggle_muffle()
			AudioManager.play_sfx("pause_in")
		else:
			AudioManager.toggle_muffle()
			AudioManager.play_sfx("pause_out")
		

func _on_resume_pressed() -> void:
	AudioManager.play_sfx("pause_out")
	get_tree().paused = false
	pause_menu.visible = false

func _on_restart_pressed() -> void:
	load_level(LevelManager.current_level, true)

func restart_level() -> void: # for level manager
	load_level(LevelManager.current_level, true)

func _on_next_level_pressed() -> void:
	LevelManager.current_level += 1
	load_level(LevelManager.current_level)

func _on_main_menu_pressed() -> void:
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

func reduce_player_health(amount: int) -> void:
	hud.reduce_health(amount)

func player_dead() -> void:
	hud.show_player_dead_popup()

func reset_hud() -> void:
	hud.reset_hud()


@onready var level_clear_text_holder: Control = $"UI/LevelClearTextHolder/Control"
const k_fancy_text_scene: PackedScene = preload("res://scenes/things/fancy_text.tscn")
func enemy_dead() -> void:
	spawned_level.enemy_count -= 1
	if spawned_level.enemy_count <= 0:
		spawned_level.enable_exit()
		AudioManager.play_sfx("level_clear")
		
		var text_instance = k_fancy_text_scene.instantiate()
		#text_instance.global_position = global_position + Vector2(0, -20)
		level_clear_text_holder.add_child(text_instance)
		text_instance.setup("LEVEL CLEAR!")

'''
====== Level Complete Menu ======
'''
@onready var level_complete_menu: CanvasLayer = $"UI/LevelCompleteMenu"

func level_complete() -> void:
	level_complete_menu.visible = true
	AudioManager.toggle_muffle()
	AudioManager.play_sfx("level_win")


# stuff
func toggle_bullet_ui() -> void:
	hud.toggle_bullet_ui()

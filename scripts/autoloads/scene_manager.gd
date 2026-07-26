extends Node

var scene_spawn: Marker2D
var main_scene: Node2D

var fade_duration: float # for other things to see fade duration

func show_scene(path: String, fade: bool = false, fade_time: float = 0.0) -> void:
	if fade:
		await fade_to_black(fade_time)
		call_deferred("_do_show_scene", path)
		await fade_from_black(fade_time)
	else:
		call_deferred("_do_show_scene", path)

func _do_show_scene(path: String) -> void:
	for child in scene_spawn.get_children():
		if child.name == "Cursor":
			continue
		child.queue_free()
	var new_scene = load(path).instantiate()
	scene_spawn.add_child(new_scene)
	AudioManager.update_button_sfx()
	get_tree().paused = false

func fade_to_black(fade: float = 0.0) -> void:
	if fade:
		await main_scene.fade_to_black(fade)
	else:
		await main_scene.fade_to_black()

func fade_from_black(fade_time: float = 0.0) -> void: # float == 0.0 might cause issues idk
	if fade_time:
		await main_scene.fade_from_black(fade_time)
	else:
		await main_scene.fade_from_black()

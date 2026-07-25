extends Node

var scene_spawn: Marker2D
var main_scene: Node2D

func show_scene(path: String, fade: bool = false) -> void:
	if fade:
		await fade_to_black()
		call_deferred("_do_show_scene", path)
		await fade_from_black()
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

func fade_to_black() -> void:
	await main_scene.fade_to_black()

func fade_from_black() -> void:
	await main_scene.fade_from_black()

extends Node

var scene_spawn: Marker2D

func show_scene(path: String) -> void:
	call_deferred("_do_show_scene", path)

func _do_show_scene(path: String) -> void:
	for child in scene_spawn.get_children():
		if child.name == "Cursor":
			continue
		child.queue_free()
	var new_scene = load(path).instantiate()
	scene_spawn.add_child(new_scene)
	AudioManager.update_button_sfx()

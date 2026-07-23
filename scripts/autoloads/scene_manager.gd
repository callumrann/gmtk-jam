extends Node

var subviewport: SubViewport

func show_scene(path: String) -> void:
	call_deferred("_do_show_scene", path)

func _do_show_scene(path: String) -> void:
	for child in subviewport.get_children():
		child.queue_free()
	var new_scene = load(path).instantiate()
	subviewport.add_child(new_scene)
	AudioManager.update_button_sfx()

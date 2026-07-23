extends Node2D

@onready var level_container: Node2D = $"LevelContainer"

func _ready() -> void:
	LevelManager.levelsLoader = self
	load_level(LevelManager.current_level)

var levels: Array[String] = [
	"res://scenes/levels/level1.tscn","res://scenes/levels/level2.tscn",
	]

func load_level(level: int) -> void:
	call_deferred("_do_load_level", level)

func _do_load_level(level: int) -> void:
	if level > levels.size():
		SceneManager.show_scene("res://scenes/menus/game_finished.tscn")
		return
	
	for child in level_container.get_children():
		child.queue_free()
	
	var new_level = load(levels[level- 1]).instantiate()
	level_container.add_child(new_level)

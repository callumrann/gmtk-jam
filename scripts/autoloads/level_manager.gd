extends Node2D

var levelsLoader: Node2D

var current_level: int = 1

func spawn_bullet(bullet: Node2D):
	levelsLoader.spawned_level.get_node("BulletContainer").add_child(bullet)

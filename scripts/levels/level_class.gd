extends Node2D

@onready var player: CharacterBody2D = $"Player"

func _ready() -> void:
	LevelManager.reset_hud()

func give_player_bullets(count: int) -> void:
	player.add_bullets(count)

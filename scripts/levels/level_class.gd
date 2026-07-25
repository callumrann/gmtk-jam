extends Node2D

@onready var player: CharacterBody2D = $"Player"

func _ready() -> void:
	LevelManager.reset_hud()
	AudioManager.play_music("stage_1_intro", -10)

func give_player_bullets(count: int) -> void:
	player.add_bullets(count)

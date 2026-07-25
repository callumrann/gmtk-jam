extends CanvasLayer

func _ready() -> void:
	AudioManager.bgm_player.volume_db = -20

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		AudioManager.bgm_player.volume_db = -10
		LevelManager.load_next_level()

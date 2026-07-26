extends CanvasLayer

var pressed: bool = false

func _ready() -> void:
	AudioManager.bgm_player.volume_db = 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and !pressed:
		pressed = true
		#AudioManager.bgm_player.volume_db = -10
		LevelManager.load_next_level()

extends Node

@onready var bgm_player: AudioStreamPlayer = AudioStreamPlayer.new()

const SFX := {
	"click": preload("res://assets/audio/click.wav"),
	"damage": preload("res://assets/audio/damage.wav"),
	"level_win": preload("res://assets/audio/level_win.wav"),
	"menu_move": preload("res://assets/audio/menu_move.wav"),
	"menu_select": preload("res://assets/audio/menu_select.wav"),
	"pause_in": preload("res://assets/audio/pause_in.wav"),
	"pause_out": preload("res://assets/audio/pause_out.wav"),
}

const MUSIC := {
	"menu": preload("res://assets/audio/menu_music.wav"),
	"stage_1": preload("res://assets/audio/stage_1_music.wav"),
}

func _ready() -> void:
	add_child(bgm_player)
	bgm_player.bus = "Music"
	play_music("menu", -10)

# So all buttons in all scenes play the same sfx
func update_button_sfx() -> void:
	var buttons: Array = get_tree().get_nodes_in_group("Button")
	for inst in buttons:
		if not inst.pressed.is_connected(_on_button_pressed):
			inst.pressed.connect(_on_button_pressed)
		if not inst.mouse_entered.is_connected(_on_button_hover):
			inst.mouse_entered.connect(_on_button_hover)

func _on_button_pressed() -> void:
	pass
	play_sfx("click", -10)

func _on_button_hover() -> void:
	pass
	play_sfx("menu_move", -15)

func play_music(track_name: String, volume: float = 0.0) -> void:	
	if not MUSIC.has(track_name):
		push_warning("Unknown music track: " + track_name)
		return
	
	var stream = MUSIC[track_name]
	if bgm_player.stream == stream and bgm_player.playing:
		return
	bgm_player.stream = stream
	bgm_player.volume_db = volume
	bgm_player.play()

func stop_music() -> void:
	bgm_player.stop()

func play_sfx(sfx_name: String, volume: float = 0.0) -> void:
	if not SFX.has(sfx_name):
		push_warning("Unknown SFX: " + sfx_name)
		return
	
	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = SFX[sfx_name]
	sfx_player.volume_db = volume
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)

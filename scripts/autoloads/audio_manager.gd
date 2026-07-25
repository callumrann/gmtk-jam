extends Node

@onready var bgm_player: AudioStreamPlayer = AudioStreamPlayer.new()

var current_music := ""

const SFX := {
	"click": preload("res://assets/audio/sfx/click.wav"),
	"damage": preload("res://assets/audio/sfx/damage.wav"),
	"level_win": preload("res://assets/audio/sfx/level_win.wav"),
	"menu_move": preload("res://assets/audio/sfx/menu_move.wav"),
	"menu_select": preload("res://assets/audio/sfx/menu_select.wav"),
	"pause_in": preload("res://assets/audio/sfx/pause_in.wav"),
	"pause_out": preload("res://assets/audio/sfx/pause_out.wav"),
	"transition": preload("res://assets/audio/music/stage_1_music_intro.wav"),
}

const MUSIC := {
	"menu_intro": preload("res://assets/audio/music/menu_music_intro.wav"),
	"menu_loop": preload("res://assets/audio/music/menu_music_loop.wav"),
	"stage_1_intro": preload("res://assets/audio/music/stage_1_music_intro.wav"),
	"stage_1_loop": preload("res://assets/audio/music/stage_1_music_loop.wav"),
}

func _ready() -> void:
	add_child(bgm_player)
	
	bgm_player.bus = "Music"
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	bgm_player.finished.connect(_on_music_finished)
	play_music("menu_intro", -5)

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

func play_music(track_name: String, volume: float = 0.0, transition: bool = false) -> void:
	if not MUSIC.has(track_name):
		push_warning("Unknown music track: " + track_name)
		return
	
	current_music = track_name
	
	var stream = MUSIC[track_name]
	if bgm_player.stream == stream and bgm_player.playing:
		return
	bgm_player.stream = stream
	bgm_player.volume_db = volume
	bgm_player.play()
	
	if transition:
		await bgm_player.finished

func play_sfx(sfx_name: String, volume: float = 0.0, transition: bool = false, fade_bgm: bool = false) -> void:
	if not SFX.has(sfx_name):
		push_warning("Unknown SFX: " + sfx_name)
		return
	
	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = SFX[sfx_name]
	sfx_player.volume_db = volume
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	
	sfx_player.finished.connect(sfx_player.queue_free)
	sfx_player.play()
	
	if transition:
		if fade_bgm:
			var tween = create_tween()
			tween.tween_property(bgm_player, "volume_db", -80.0, sfx_player.stream.get_length())
			tween.set_trans(Tween.TRANS_QUAD)
			tween.set_ease(Tween.EASE_OUT)
		await sfx_player.finished

func _on_music_finished() -> void:
	match current_music:
		"menu_intro":
			play_music("menu_loop", -5)
		"stage_1_intro":
			play_music("stage_1_loop", -10)

func stop_music() -> void:
	bgm_player.stop()

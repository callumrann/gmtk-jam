extends Node

@onready var bgm_player: AudioStreamPlayer = AudioStreamPlayer.new()

var current_music := ""

const SFX := {
	"player_damage": preload("res://assets/audio/sfx/player_damage.wav"),
	"player_shoot": preload("res://assets/audio/sfx/player_shoot.wav"),
	"player_die": preload("res://assets/audio/sfx/player_die.wav"),
	"player_shoot_no_ammo": preload("res://assets/audio/sfx/player_shoot_no_ammo.wav"),
	"player_footsteps": preload("res://assets/audio/sfx/nothing.wav"), # didnt implement yet... might not
	
	"enemy_damage": preload("res://assets/audio/sfx/enemy_damage.wav"),
	"enemy_shoot": preload("res://assets/audio/sfx/enemy_shoot.wav"),
	"enemy_swing": preload("res://assets/audio/sfx/enemy_swing.wav"),
	"enemy_die": preload("res://assets/audio/sfx/enemy_die.wav"),
	
	"door": preload("res://assets/audio/sfx/door.wav"),
	"ammo_pickup": preload("res://assets/audio/sfx/ammo_pickup.wav"),
	
	"level_clear": preload("res://assets/audio/sfx/level_win.wav"), # all enemies dead
	"level_win": preload("res://assets/audio/sfx/level_win.wav"), # leave building
	
	"player_punch": preload("res://assets/audio/sfx/player_punch.wav"),
	"dracula_damage": preload("res://assets/audio/sfx/dracula_damage.wav"),
	"dracula_down": preload("res://assets/audio/sfx/dracula_down.wav"), # fall down, count start after
	"dracula_revive": preload("res://assets/audio/sfx/dracula_revive.wav"),
	"knock_out": preload("res://assets/audio/sfx/knock_out.wav"),
	"player_dodge": preload("res://assets/audio/sfx/nothing.wav"),
	"dracula_whiff": preload("res://assets/audio/sfx/dracula_whiff.wav"), # miss dodging player
	"dracula_block": preload("res://assets/audio/sfx/dracula_block.wav"),
	"count_down": preload("res://assets/audio/sfx/count_down.wav"), # appearance of 3, 2, 1, each makes sound
	
	"menu_move": preload("res://assets/audio/sfx/menu_move.wav"),
	"menu_select": preload("res://assets/audio/sfx/menu_select.wav"),
	"pause_in": preload("res://assets/audio/sfx/pause_in.wav"),
	"pause_out": preload("res://assets/audio/sfx/pause_out.wav"),
	
	"transition": preload("res://assets/audio/sfx/transition.wav"),
}

const MUSIC := {
	"main_menu_loop": preload("res://assets/audio/music/main_menu_loop.wav"),
	
	"newspaper_scene": preload("res://assets/audio/music/newspaper_scene.wav"),
	"newspaper_waiting": preload("res://assets/audio/music/newspaper_waiting.wav"),
	
	"battle_intro": preload("res://assets/audio/music/battle_intro.wav"),
	"battle_loop": preload("res://assets/audio/music/battle_loop.wav"),
	"dracula_death": preload("res://assets/audio/music/dracula_death.wav")
}

func _ready() -> void:
	add_child(bgm_player)
	bgm_player.bus = "Music"
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	bgm_player.finished.connect(_on_music_finished)


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
	
	print("check")
	
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
			SceneManager.fade_to_black(sfx_player.stream.get_length())
			fade_music(sfx_player.stream.get_length() - 0.1, -80.0)
		await sfx_player.finished

func _on_music_finished() -> void:
	match current_music:
		"battle_intro":
			play_music("battle_loop", 0)
		"newspaper_scene":
			play_music("newspaper_waiting", 0)

func stop_music() -> void:
	bgm_player.stop()

func fade_music(duration: float, volume: float) -> void:
	var tween = create_tween()
	# - 0.1 cause .finished race condition stuff <- kinda cheese but whatevs
	tween.tween_property(bgm_player, "volume_db", volume, duration)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

func toggle_muffle(clearMuffle: bool = false):
	var bus_idx = AudioServer.get_bus_index(bgm_player.bus)
	if clearMuffle:
		AudioServer.set_bus_effect_enabled(bus_idx, 0, false)
	else:
		var is_currently_muffled = AudioServer.is_bus_effect_enabled(bus_idx, 0)
		AudioServer.set_bus_effect_enabled(bus_idx, 0, not is_currently_muffled)

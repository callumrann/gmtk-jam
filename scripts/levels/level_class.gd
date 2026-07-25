extends Node2D

@onready var player: CharacterBody2D = $"Spawn/Player"

@onready var camera: Camera2D = $"Spawn/Camera2D"
const k_camera_percent_to_mouse: float = 0.3

@onready var enemy_container: Node2D = $"Enemies"
var enemy_count: int

@onready var on_exit: Node2D = $"OnExit"
@onready var exit_collision: CollisionShape2D = $"OnExit/Exit/CollisionShape2D"

func _ready() -> void:
	LevelManager.reset_hud()
	enemy_count = enemy_container.get_child_count()

func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	camera.global_position = lerp(player.global_position, mouse_position, k_camera_percent_to_mouse)

func give_player_bullets(count: int) -> void:
	player.add_bullets(count)

func enable_exit() -> void:
	on_exit.visible = true
	exit_collision.set_deferred("disabled", false)

func _on_exit_area_entered(area: Area2D) -> void:
	player.level_finished()
	await SceneManager.fade_to_black()
	LevelManager.level_complete()
	player.visible = false
	await SceneManager.fade_from_black()

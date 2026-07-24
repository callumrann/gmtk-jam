extends CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $"Navigation/NavigationAgent2D"
@onready var player: Node2D = $"../../Player"

const k_speed: float = 50.0

func _ready() -> void:
	await get_tree().physics_frame

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = direction * k_speed
	move_and_slide()

func _on_timer_timeout() -> void:
	navigation_agent.target_position = player.global_position

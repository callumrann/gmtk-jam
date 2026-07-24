extends CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $"Navigation/NavigationAgent2D"
@onready var player: Node2D = $"../../Player"

const k_move_speed: float = 50.0
const k_turn_speed: float = 10.0

func _ready() -> void:
	await get_tree().physics_frame

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	navigation_agent.target_position = player.global_position
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	if direction != Vector2.ZERO:
		var target_angle = direction.angle()
		rotation = lerp_angle(rotation, target_angle, k_turn_speed * delta)
	
	velocity = direction * k_move_speed
	move_and_slide()

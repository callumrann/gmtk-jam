extends Area2D

@export var enabled: bool = false

@onready var fight_spawn_collision: CollisionShape2D = $"CollisionShape2D"
@onready var fight_visuals: CanvasLayer = $"Fight"

@onready var player_animation: AnimatedSprite2D = $"Fight/Player"
@onready var dracula_animation: AnimatedSprite2D = $"Fight/TheCount"

# player related
const k_player_punch_cooldown: float = 0.5
var player_punch_cooldown_timer: float = 0.0
const k_player_punch_damage_delay: float = 0.2 # when implementing anim with damage at end

var dodge_left: bool = false
var dodge_right: bool = false

var player: CharacterBody2D
var player_health: int

# dracula related
var dracula_health: int = 7

const k_dracula_punch_cooldown: float = 0 # average
const k_punch_cooldown_offset_max: float = 0 
var dracula_punch_cooldown_timer: float = randf_range(k_dracula_punch_cooldown - k_punch_cooldown_offset_max, k_dracula_punch_cooldown + k_punch_cooldown_offset_max)
const k_dracula_punch_damage_delay: float = 0.8 # when implementing anim with damage at end

var dracula_blocking: bool = false
var dracula_block_timer: float = 0.0
var high_block: bool = false

var blocks: int = 0 # stop too many consecutive blocks
var punches: int = 0

var dracula_punch_queue: int = 0
var dracula_currently_punching: bool = false

var first_down: bool = true

# other
var fight_spawned: bool = false
var pre_fight: bool = false
var fight: bool = false

@onready var info: Control = $"Fight/Control"
var player_position: Vector2
var dracula_position: Vector2

# Tween maxing - for blocks
var player_start_position: Vector2
var player_tween: Tween

var dracula_start_position: Vector2
var dracula_tween: Tween

const k_shake_duration: float = 0.4
const k_shake_strength: float = 8.0
const k_shake_count: int = 6

func _ready() -> void:
	player_animation.animation_finished.connect(_player_animation_finished)
	dracula_animation.animation_finished.connect(_dracula_animation_finished)
	
	player_start_position = player_animation.global_position
	dracula_start_position =  dracula_animation.global_position
	
	player_position = player_animation.global_position
	dracula_position = dracula_animation.global_position

func _process(delta: float) -> void:
	if !enabled:
		return
	
	if !fight_spawned and get_parent().visible:
		fight_spawned = true
		fight_spawn_collision.set_deferred("disabled", false)
	
	if dracula_health <= 0:
		dracula_animation.play("dead")
	
	if pre_fight:
		if Input.is_action_just_pressed("interact"):
			info.visible = false
			dracula_animation.play("intro")
			LevelManager.toggle_health_ui()
			LevelManager.drac_toggle_health_ui()
			
			var tween: Tween = create_tween()
			tween.set_parallel(true)
			tween.set_trans(Tween.TRANS_QUAD)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(player_animation, "global_position", player_position, 0.5)
			tween.tween_property(dracula_animation, "global_position", dracula_position, 0.5)
			
			await tween.finished
			
			var text_instance = k_fancy_text_scene.instantiate()
			fight_visuals.add_child(text_instance)
			text_instance.setup("BEGIN!", 50)
			text_instance.position = Vector2(480, 270)
			AudioManager.play_sfx("count_down")
			await get_tree().create_timer(text_instance.lifetime + 1.0).timeout
			
			fight = true
			pre_fight = false
	
	if !fight:
		return
	
	if Input.is_action_pressed("move_left"):
		player_animation.play("dodge_left")
		if !dodge_left:
			AudioManager.play_sfx("player_dodge")
		dodge_left = true
		dodge_right = false
	elif Input.is_action_pressed("move_right"):
		player_animation.play("dodge_right")
		if !dodge_right:
			AudioManager.play_sfx("player_dodge")
		dodge_left = false
		dodge_right = true
	else:
		dodge_left = false
		dodge_right = false
	
	if not dracula_currently_punching and not dracula_blocking:
		if dracula_punch_cooldown_timer > 0.0:
			dracula_punch_cooldown_timer -= delta
		else:
			dracula_punch_cooldown_timer = randf_range(k_dracula_punch_cooldown - k_punch_cooldown_offset_max, k_dracula_punch_cooldown + k_punch_cooldown_offset_max)
			_dracula_do_something()
	
	if player_punch_cooldown_timer > 0.0:
		player_punch_cooldown_timer -= delta
		return
	
	if Input.is_action_just_pressed("move_up"):
		player_animation.play("punch_high")
		player_punch_cooldown_timer = k_player_punch_cooldown
		await get_tree().create_timer(k_player_punch_damage_delay).timeout
		_hit_dracula("high")
	
	elif Input.is_action_just_pressed("move_down"):
		player_animation.play("punch_low")
		player_punch_cooldown_timer = k_player_punch_cooldown
		await get_tree().create_timer(k_player_punch_damage_delay).timeout
		_hit_dracula("low")

func _dracula_do_something() -> void:
	# hardcoding time...
	var number: int = randi_range(0, 1)
	if (number < 1 or punches >= 1) and blocks < 2:
		blocks += 1
		dracula_blocking = true
		number = randi_range(0, 1)
		if number == 0:
			high_block = true
			dracula_animation.play("high_block")
		else:
			high_block = false
			dracula_animation.play("low_block")
		dracula_block_timer = randf_range(1.0, 2.0) # magic...
		await get_tree().create_timer(dracula_block_timer).timeout
		dracula_blocking = false
		#dracula_animation.play("default")
	else:
		punches += 1
		blocks = 0
		dracula_punch_queue = randi_range(1, 2)
		_dracula_throw_next_punch()

func _dracula_throw_next_punch() -> void:
	if dracula_punch_queue <= 0:
		dracula_currently_punching = false
		#dracula_animation.play("default")
		return
	
	if !fight:
		return
	
	dracula_currently_punching = true
	var punch_anim = "punch_left" if dracula_punch_queue % 2 == 0 else "punch_right"
	dracula_animation.play(punch_anim)
	dracula_punch_queue -= 1
	
	await get_tree().create_timer(k_dracula_punch_damage_delay).timeout
	_hit_player(punch_anim)

func _player_animation_finished() -> void:
	if !dodge_left and !dodge_right:
		player_animation.play("default")

func _dracula_animation_finished() -> void:
	if dracula_health <= 0:
		dracula_animation.play("dead")
	
	elif dracula_currently_punching:
		_dracula_throw_next_punch()
	elif not dracula_blocking:
		pass
		dracula_animation.play("default")

const k_fancy_text_scene: PackedScene = preload("res://scenes/things/fancy_text.tscn")

func _hit_dracula(side: String) -> void:
	if !fight:
		return 
	
	if dracula_blocking:
		if high_block and side == "high":
			AudioManager.play_sfx("dracula_block")
			shake_dracula()
			return
		elif !high_block and side == "low":
			AudioManager.play_sfx("dracula_block")
			shake_dracula()
			return
	dracula_health -= 1
	LevelManager.drac_reduce_health(1)
	
	if dracula_health <= 0:
		fight = false
		dracula_animation.play("dead")
		AudioManager.play_sfx("dracula_down")
		if first_down:
			var text_instance = k_fancy_text_scene.instantiate()
			fight_visuals.add_child(text_instance)
			text_instance.setup("3", 50)
			text_instance.position = Vector2(480, 270)
			AudioManager.play_sfx("count_down")
			await get_tree().create_timer(text_instance.lifetime + 1.0).timeout
			text_instance = k_fancy_text_scene.instantiate()
			fight_visuals.add_child(text_instance)
			text_instance.setup("2", 50)
			AudioManager.play_sfx("count_down")
			text_instance.position = Vector2(480, 270)
			await get_tree().create_timer(text_instance.lifetime + 1.0).timeout
			dracula_health += 7
			dracula_currently_punching = false
			dracula_blocking = false
			dracula_punch_queue = 0
			blocks = 0
			punches = 0
			dracula_punch_cooldown_timer = randf_range(k_dracula_punch_cooldown - k_punch_cooldown_offset_max, k_dracula_punch_cooldown + k_punch_cooldown_offset_max)
			LevelManager.drac_reset_hud()
			#dracula_animation.play("default")
			AudioManager.play_sfx("dracula_revive")
			fight = true
			first_down = false
			return
		
		var text_instance = k_fancy_text_scene.instantiate()
		fight_visuals.add_child(text_instance)
		text_instance.setup("3", 50)
		AudioManager.play_sfx("count_down")
		text_instance.position = Vector2(480, 270)
		await get_tree().create_timer(text_instance.lifetime + 1.0).timeout
		text_instance = k_fancy_text_scene.instantiate()
		fight_visuals.add_child(text_instance)
		text_instance.setup("2", 50)
		AudioManager.play_sfx("count_down")
		text_instance.position = Vector2(480, 270)
		await get_tree().create_timer(text_instance.lifetime + 1.0).timeout
		text_instance = k_fancy_text_scene.instantiate()
		fight_visuals.add_child(text_instance)
		text_instance.setup("1", 50)
		AudioManager.play_sfx("count_down")
		text_instance.position = Vector2(480, 270)
		await get_tree().create_timer(text_instance.lifetime + 1.0).timeout
		text_instance = k_fancy_text_scene.instantiate()
		text_instance.lifetime += 1
		fight_visuals.add_child(text_instance)
		text_instance.setup("KNOCK OUT!", 50)
		AudioManager.play_sfx("knock_out")
		text_instance.position = Vector2(480, 270)
		await get_tree().create_timer(text_instance.lifetime).timeout
		text_instance = k_fancy_text_scene.instantiate()
		text_instance.lifetime += 3
		fight_visuals.add_child(text_instance)
		text_instance.setup("THE COUNT IS DOWN!", 50)
		text_instance.position = Vector2(480, 270)
		await get_tree().create_timer(text_instance.lifetime).timeout
		LevelManager.load_next_level()

	else:
		AudioManager.play_sfx("dracula_damage")

func _hit_player(side: String) -> void:
	if !fight: # stop chain punches after player death
		return
	
	if dodge_left and side == "punch_left":
		AudioManager.play_sfx("dracula_whiff")
		return
	if dodge_right and side == "punch_right":
		AudioManager.play_sfx("dracula_whiff")
		return
	
	player_health -= 1
	LevelManager.reduce_player_health(1)
	
	if player_health <= 0 and fight:
		player.die()
		_end_fight()
	else:
		AudioManager.play_sfx("player_damage")
	
func _on_area_entered(area: Area2D) -> void:
	player_animation.position -= Vector2(500, 0)
	dracula_animation.position += Vector2(500, 0)
	fight_visuals.visible = true
	LevelManager.toggle_bullet_ui()
	LevelManager.toggle_health_ui()
	for object in get_tree().get_nodes_in_group("Player"):
		if object.name == "Player":
			player = object
			break
	
	player.level_complete = true
	player_health = player.health
	pre_fight = true

func _end_fight() -> void:
	fight_spawn_collision.set_deferred("disabled", true)
	fight_visuals.visible = false
	LevelManager.toggle_bullet_ui()
	LevelManager.drac_toggle_health_ui()
	for object in get_tree().get_nodes_in_group("Player"):
		if object.name == "Player":
			player = object
			break
	
	player.level_complete = false
	fight = false

func shake_player() -> void:
	if player_tween and player_tween.is_valid():
		player_tween.kill()
	
	player_animation.position = player_start_position
	
	player_tween = create_tween()
	var step_time: float = k_shake_duration / k_shake_count
	
	for i in k_shake_count:
		var strength: float = k_shake_strength * (1.0 - float(i) / k_shake_count)
		var offset = strength if i % 2 == 0 else -strength
		player_tween.tween_property(player_animation, "position:y", player_start_position.y + offset, step_time)
	player_tween.tween_property(player_animation, "position", player_start_position, step_time)

func shake_dracula() -> void:
	if dracula_tween and dracula_tween.is_valid():
		dracula_tween.kill()
	
	dracula_animation.position = dracula_start_position
	
	dracula_tween = create_tween()
	var step_time: float = k_shake_duration / k_shake_count
	
	for i in k_shake_count:
		var strength: float = k_shake_strength * (1.0 - float(i) / k_shake_count)
		var offset = strength if i % 2 == 0 else -strength
		dracula_tween.tween_property(dracula_animation, "position:y", dracula_start_position.y + offset, step_time)
	dracula_tween.tween_property(dracula_animation, "position", dracula_start_position, step_time)

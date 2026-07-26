extends Node2D
@onready var rich_label: RichTextLabel = $RichTextLabel

@export var start_colour: Color = Color.WHITE
@export var flash_colour: Color = Color.PURPLE
@export var flash_speed: float = 8.0
@export var wave_amplitude: float = 80.0
@export var wave_frequency: float = 5.0
@export var lifetime: float = 1.0

func setup(text: String, font_size: int = 50, colour: Color = Color.WHITE) -> void:
	start_colour = colour
	rich_label.add_theme_font_size_override("normal_font_size", font_size)
	rich_label.bbcode_enabled = true
	rich_label.text = "[wave amp=%d freq=%d]%s[/wave]" % [wave_amplitude, wave_frequency, text]

func _ready() -> void:
	rich_label.modulate = start_colour
	_play_color_flash()
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _play_color_flash() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(rich_label, "modulate", flash_colour, 1.0 / flash_speed)
	tween.tween_property(rich_label, "modulate", start_colour, 1.0 / flash_speed)

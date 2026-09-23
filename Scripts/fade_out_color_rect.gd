class_name FadeOutColorRect
extends ColorRect

@export var ignore_time_scale: bool = true
@export var fade_out_duration: float = 0.5
@export var fade_out_delay: float = 0.5
@export_range(0, 1.0, 0.01) var transparency: float = 1

func _ready() -> void:
	var tween = create_tween()
	tween.set_ignore_time_scale(ignore_time_scale)
	tween.tween_property(self, "modulate:a", 0.0, fade_out_duration).from(transparency).set_delay(fade_out_delay)

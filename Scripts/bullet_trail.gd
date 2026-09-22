

extends Line2D

@export var trail_length: int = 30
@export var origin_object: Node2D

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

func _process(_delta: float) -> void:
	global_position = origin_object.global_position
	add_point(origin_object.global_position)
	if points.size() > trail_length:
		remove_point(0)

func _on_visibility_changed():
	if visible:
		clear_points()

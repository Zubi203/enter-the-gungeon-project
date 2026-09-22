class_name BulletParticles
extends CPUParticles2D


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		restart()

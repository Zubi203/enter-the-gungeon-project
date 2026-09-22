class_name OneShotCPUParticles2D
extends CPUParticles2D


func _ready() -> void:
	finished.connect(_emission_finished)

func setup(pos: Vector2) -> void:
	global_position = pos
	restart()

func _emission_finished():
	hide()

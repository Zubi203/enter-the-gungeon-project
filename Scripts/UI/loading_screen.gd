extends CanvasLayer

signal LoadingScreenReady

@export var animation_player: AnimationPlayer
@export var load_progress: Range

func _ready() -> void:
	await animation_player.animation_finished
	LoadingScreenReady.emit()

func _on_progress_changed(new_value: float):
	if load_progress:
		load_progress.value = new_value

func _on_load_finished():
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	queue_free()

extends Control


func _enter_tree() -> void:
	PauseManager.add_menu(self)


func _exit_tree() -> void:
	PauseManager.remove_menu(self)

 
func _fade_out():
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)


func _on_cancel_button_pressed() -> void:
	_fade_out()


func _on_reset_button_pressed() -> void:
	SceneTransition.transition(GlobalData.Scenes.MAIN_LEVEL, GlobalData.current_scene)

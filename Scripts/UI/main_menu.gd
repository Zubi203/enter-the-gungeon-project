extends Control

@export var settings_menu: PackedScene




func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	if settings_menu == null:
		return
	var menu = settings_menu.instantiate()
	add_child(menu)
	


func _on_testing_button_pressed() -> void:
	SceneTransition.transition(GlobalData.Scenes.TEST_LEVEL, GlobalData.Scenes.TITLE)


func _on_play_button_pressed() -> void:
	SceneTransition.transition(GlobalData.Scenes.MAIN_LEVEL, GlobalData.Scenes.TITLE)


func _on_continue_button_pressed() -> void:
	pass # Replace with function body.

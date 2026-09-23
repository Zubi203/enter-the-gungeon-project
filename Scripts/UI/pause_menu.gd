extends Control

@export var settings_menu: PackedScene
@export var reset_button: BaseButton
@export var reset_confirmation_menu: PackedScene

func _enter_tree() -> void:
	PauseManager.add_menu(self)

func _exit_tree() -> void:
	PauseManager.remove_menu(self)

func _ready() -> void:
	if not GlobalData.current_scene == GlobalData.Scenes.MAIN_LEVEL and not reset_button == null:
		reset_button.hide()

func _fade_out():
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)


func _on_resume_button_pressed() -> void:
	_fade_out()


func _on_settings_button_pressed() -> void:
	if settings_menu:
		var menu = settings_menu.instantiate()
		add_child(menu)


func _on_restart_button_pressed() -> void:
	if reset_confirmation_menu:
		var menu = reset_confirmation_menu.instantiate()
		add_child(menu)


func _on_main_menu_button_pressed() -> void:
	SceneTransition.transition(GlobalData.Scenes.TITLE, GlobalData.current_scene)

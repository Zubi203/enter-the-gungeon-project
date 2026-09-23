extends Control

enum State {
	MAIN,
	CONTROLS,
	AUDIO,
	VIDEO
}

var current_state: State = State.MAIN:
	set(value):
		current_state = value
		for key in menus.keys():
			if menus[key] == null:
				continue
			if key == current_state:
				menus[key].show()
			else:
				menus[key].hide()

@export var menus: Dictionary[State, Control] = {
	State.MAIN: null,
	State.CONTROLS: null,
	State.AUDIO: null,
	State.VIDEO: null
}

func _enter_tree() -> void:
	PauseManager.add_menu(self)

func _exit_tree() -> void:
	PauseManager.remove_menu(self)

func _ready() -> void:
	current_state = State.MAIN

func _fade_out():
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)


func _on_back_button_pressed() -> void:
	_fade_out()


# --------------------- Control Menu Signals ------------------------

func _on_control_button_pressed() -> void:
	current_state = State.CONTROLS

func _on_control_back_button_pressed() -> void:
	current_state = State.MAIN


# --------------------- Video Menu Signals ------------------------

func _on_video_button_pressed() -> void:
	current_state = State.VIDEO

func _on_video_back_button_pressed() -> void:
	current_state = State.MAIN



# --------------------- Audio Menu Signals ------------------------

func _on_audio_button_pressed() -> void:
	current_state = State.AUDIO

func _on_audio_back_button_pressed() -> void:
	current_state = State.MAIN

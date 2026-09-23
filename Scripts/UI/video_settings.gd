extends Control

@export var screen_shake_toggle: BaseButton
@export var custom_cursor_toggle: BaseButton


func _ready() -> void:
	if screen_shake_toggle:
		screen_shake_toggle.toggled.connect(_on_screen_shake_check_box_toggled)
		screen_shake_toggle.button_pressed = GlobalData.screen_shake_enabled
	if custom_cursor_toggle:
		custom_cursor_toggle.toggled.connect(_on_custom_cursor_check_box_toggled)
		custom_cursor_toggle.button_pressed = GlobalData.custom_cursor_enabled



func _on_screen_shake_check_box_toggled(toggled_on: bool) -> void:
	GlobalData.screen_shake_enabled = toggled_on


func _on_custom_cursor_check_box_toggled(toggled_on: bool) -> void:
	GlobalData.custom_cursor_enabled = toggled_on

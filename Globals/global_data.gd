extends Node

var dynamic_camera_aim: bool = true
var screen_shake_enabled: bool = true

var custom_cursor_texture: Texture2D = preload("uid://b0vmt2o667ccn")
var custom_cursor_enabled: bool = true:
	set(value):
		custom_cursor_enabled = value
		if custom_cursor_enabled:
			Input.set_custom_mouse_cursor(custom_cursor_texture, Input.CURSOR_ARROW, Vector2(20, 20))
		else:
			Input.set_custom_mouse_cursor(null)

func _enter_tree() -> void:
	custom_cursor_enabled = true

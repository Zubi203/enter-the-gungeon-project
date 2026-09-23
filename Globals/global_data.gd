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

enum Scenes{
	TITLE,
	MAIN_LEVEL,
	TEST_LEVEL,
	DEFEAT_SCREEN,
	VICTORY_SCREEN
}

const SCENE_PATHS: Dictionary[Scenes, String] = {
	Scenes.TITLE: "uid://5nvrwauton5y",
	Scenes.MAIN_LEVEL: "uid://dadonouguo0fx",
	Scenes.TEST_LEVEL: "",
	Scenes.DEFEAT_SCREEN: "",
	Scenes.VICTORY_SCREEN: "",
}

var current_scene: Scenes

func _enter_tree() -> void:
	custom_cursor_enabled = true

extends CanvasLayer

@export var pause_menu: PackedScene




func _on_pause_button_pressed() -> void:
	if pause_menu:
		var menu = pause_menu.instantiate()
		add_child(menu)

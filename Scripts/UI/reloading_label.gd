class_name ReloadingLabel
extends Label


var tween: Tween

func _ready() -> void:
	for child in owner.get_children():
		if child is PlayerController:
			child.AmmoDepleted.connect(_on_ammo_finished)
			child.Reload.connect(_on_reload_start)

func _on_reload_start():
	show()
	modulate.a = 1.0
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_loops(5)
	tween.tween_property(self, "text", "RELOADING...", 1.0).from("RELOADING")
	tween.tween_callback(hide)

func _on_ammo_finished():
	show()
	text = "( RELOAD )"
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_loops(10)
	tween.tween_property(self, "modulate:a", 1.0, 0.01)
	tween.tween_interval(0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.01)
	tween.tween_interval(0.3)

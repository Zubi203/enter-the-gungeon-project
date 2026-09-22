class_name PlayerUI
extends CanvasLayer

@export var damage_screen_effect: TextureRect
var damage_screen_tween: Tween

func _ready() -> void:
	setup.call_deferred()

func setup():
	for child in owner.get_children():
		if child is HealthComponent:
			child.DamageTaken.connect(_on_damage_taken)

func _on_damage_taken(_health: int):
	if damage_screen_effect == null:
		return
	
	if damage_screen_tween and damage_screen_tween.is_running():
		damage_screen_tween.kill()
	
	damage_screen_tween = create_tween()
	damage_screen_tween.tween_property(damage_screen_effect, "modulate:a", 1.0, 0.05)
	damage_screen_tween.tween_property(damage_screen_effect, "modulate:a", 0.0, 0.3)

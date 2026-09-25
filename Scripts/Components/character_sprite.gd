class_name CharacterSprite
extends Sprite2D

var color_tween : Tween

func damage_flash():
	if color_tween and color_tween.is_running():
		color_tween.kill()
	color_tween = create_tween()
	color_tween.tween_property(self, "material:shader_parameter/progress_white", 1.0, 0.1)
	color_tween.tween_property(self, "material:shader_parameter/progress_white", 0.0, 0.2)

func heal_flash():
	if color_tween and color_tween.is_running():
		color_tween.kill()
	color_tween = create_tween()
	color_tween.tween_property(self, "material:shader_parameter/progress_green", 1.0, 0.1)
	color_tween.tween_property(self, "material:shader_parameter/progress_green", 0.0, 0.2)

class_name Door
extends StaticBody2D

@export var collider: CollisionShape2D
@export var particles: CPUParticles2D
@export var sprite: Sprite2D

func close():
	if particles:
		particles.restart()
	if collider:
		collider.set_deferred("disabled", false)
	if sprite:
		sprite.show()

func open():
	if particles:
		particles.restart()
	if collider:
		collider.set_deferred("disabled", true)
	if sprite:
		sprite.hide()

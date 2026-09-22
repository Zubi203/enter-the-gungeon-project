class_name BulletDestroyStrategy
extends BulletStrategy

@export var destroy_effect: PackedScene

var particle_manager: ParticleManager:
	get: return ManagerRegistry.get_manager("particle_manager")

func apply_strategy(bullet: BaseBullet):
	if destroy_effect:
		particle_manager.spawn_particles(destroy_effect, bullet.global_position, 1)
	_destroy_behavior(bullet)

func _destroy_behavior(bullet: BaseBullet):
	pass

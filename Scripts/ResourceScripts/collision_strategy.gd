class_name CollisionStrategy
extends BulletStrategy

@export var collision_vfx: Array[PackedScene]
@export var destroy_on_collision: bool = true
@export var collision_sfx: AudioStream

var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")

var camera_controller: CameraController:
	get: return ManagerRegistry.get_manager("camera_controller")

var particle_manager: ParticleManager:
	get: return ManagerRegistry.get_manager("particle_manager")

func apply_strategy(bullet: BaseBullet):
	_on_collision(bullet)
	_collision_vfx(bullet)
	_collision_sfx()
	if destroy_on_collision:
		bullet.destroy()

func _on_collision(bullet: BaseBullet):
	pass

func _collision_vfx(bullet: BaseBullet):
	for effect in collision_vfx:
		particle_manager.spawn_particles(effect, bullet.global_position, 1)

func _collision_sfx():
	if audio_manager:
		audio_manager.play_random_pitch(collision_sfx)

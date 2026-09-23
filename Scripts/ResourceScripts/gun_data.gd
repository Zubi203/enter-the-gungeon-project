class_name GunData
extends Resource

enum GunType {
	TAP_TO_SHOOT,
	AUTO_FIRE,
	CHARGE
}

enum SpreadType {
	RANDOM,
	UNIFORM
}

enum SpreadFiringOrder {
	START_TO_END,
	END_TO_START,
	START_MIDDLE,
	END_MIDDLE
}

enum SoundEmissionType{
	PER_BULLET,
	PER_SHOT
}

@export var texture: Texture2D
@export var bullet: BulletData
@export var shoot_sfx: AudioStream
@export var sound_emission_type: SoundEmissionType
@export var shoot_sfx_volume: float = 0.0
@export var shoot_vfx: Array[PackedScene] = []
@export var type: GunType
@export var charge_time: float = 2.0
@export var bullets_per_shot: int = 1
@export var recoil_enabled: bool = true
@export var recoil: float = 7.0
@export_range(0.0, 1.0, 0.0001) var burst_explosiveness: float = 1.0
@export var accuracy_cone_angle: float = 30.0
@export var spread_type: SpreadType
@export var spread_firing_order: SpreadFiringOrder
@export var shoot_interval: float = 0.8
@export var reload_speed: float = 1.0
@export var magazine_size: int = 20
@export var name: String = ""
@export_multiline var description: String = ""

var bullet_manager: BulletManager:
	get: return ManagerRegistry.get_manager("bullet_manager")

var camera_controller: CameraController:
	get: return ManagerRegistry.get_manager("camera_controller")

var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")

var particle_manager: ParticleManager:
	get: return ManagerRegistry.get_manager("particle_manager")

func fire_burst(shooter: Node2D, aim_target: Vector2, group: String):
	
	var target_points: Array[Vector2] = get_target_points(shooter, aim_target)
	var delay_between_shots: float = 1.0 - burst_explosiveness
	
	if sound_emission_type == SoundEmissionType.PER_SHOT:
		audio_manager.play(shoot_sfx, shoot_sfx_volume)
		for effect in shoot_vfx:
			particle_manager.spawn_particles(effect, shooter.global_position, 2)
	
	if spread_firing_order == SpreadFiringOrder.START_TO_END or spread_firing_order == SpreadFiringOrder.END_TO_START:
		
		if spread_firing_order == SpreadFiringOrder.END_TO_START:
			target_points.reverse()
		
		for point in target_points:
			bullet_manager.shoot(bullet, shooter.global_position, point, group)
			if sound_emission_type == SoundEmissionType.PER_BULLET:
				audio_manager.play(shoot_sfx, shoot_sfx_volume)
				for effect in shoot_vfx:
					particle_manager.spawn_particles(effect, shooter.global_position, 2)
			
			if recoil_enabled:
				camera_controller.directional_shake(shooter.global_position.direction_to(point) * -1, recoil)
			
			if shooter is GunSprite:
				shooter.recoil(bullet.bullet_color)
				
			if delay_between_shots > 0.0:
				await shooter.get_tree().create_timer(delay_between_shots).timeout
	else:
		var center_targets: Array[Vector2] = []
		var left_targets: Array[Vector2] = []
		var right_targets: Array[Vector2] = []
		
		if bullets_per_shot % 2 == 0:
			var middle_index = int(float(bullets_per_shot) / 2.0)
			center_targets.append(target_points[middle_index])
			center_targets.append(target_points[middle_index + 1])
			
			for i in range(middle_index + 1, target_points.size()):
				right_targets.append(target_points[i])
			
			for i in range(0, middle_index - 1):
				left_targets.append(target_points[i])
			
		else:
			var middle_index = floori(float(bullets_per_shot) / 2.0)
			center_targets.append(target_points[middle_index])
			
			for i in range(middle_index + 1, target_points.size()):
				right_targets.append(target_points[i])
			
			for i in range(0, middle_index):
				left_targets.append(target_points[i])
			
		left_targets.reverse()
			
		if spread_firing_order == SpreadFiringOrder.END_MIDDLE:
			right_targets.reverse()
			left_targets.reverse()
		
		if spread_firing_order == SpreadFiringOrder.START_MIDDLE:
			for point in center_targets:
				bullet_manager.shoot(bullet, shooter.global_position, point, group)
				if sound_emission_type == SoundEmissionType.PER_BULLET:
					audio_manager.play(shoot_sfx)
					for effect in shoot_vfx:
						particle_manager.spawn_particles(effect, shooter.global_position, 2)
				if recoil_enabled:
					camera_controller.directional_shake(shooter.global_position.direction_to(point) * -1, recoil)
				
				if shooter is GunSprite:
					shooter.recoil(bullet.bullet_color)
			
			if delay_between_shots > 0.0:
				await shooter.get_tree().create_timer(delay_between_shots).timeout
			
		for i in range(right_targets.size()):
			bullet_manager.shoot(bullet, shooter.global_position, right_targets[i], group)
			bullet_manager.shoot(bullet, shooter.global_position, left_targets[i], group)
			if sound_emission_type == SoundEmissionType.PER_BULLET:
				audio_manager.play(shoot_sfx, shoot_sfx_volume)
				for effect in shoot_vfx:
					particle_manager.spawn_particles(effect, shooter.global_position, 2)
			
			if recoil_enabled:
				camera_controller.directional_shake(shooter.global_position.direction_to(aim_target) * -1, recoil)
			
			if shooter is GunSprite:
				shooter.recoil(bullet.bullet_color)
			
			if delay_between_shots > 0.0:
				await shooter.get_tree().create_timer(delay_between_shots).timeout
		
		if spread_firing_order == SpreadFiringOrder.END_MIDDLE:
			for point in center_targets:
				bullet_manager.shoot(bullet, shooter.global_position, point, group)
				if sound_emission_type == SoundEmissionType.PER_BULLET:
					audio_manager.play(shoot_sfx, shoot_sfx_volume)
					for effect in shoot_vfx:
						particle_manager.spawn_particles(effect, shooter.global_position, 2)
				if recoil_enabled:
					camera_controller.directional_shake(shooter.global_position.direction_to(point) * -1, recoil)
				
				if shooter is GunSprite:
					shooter.recoil(bullet.bullet_color)
			
			if delay_between_shots > 0.0:
				await shooter.get_tree().create_timer(delay_between_shots).timeout
			
		

func get_target_points(shooter: Node2D, aim_target: Vector2) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var shooter_pos: Vector2 = shooter.global_position
	var vector_length: float = shooter_pos.distance_to(aim_target)
	var aim_dir: Vector2 = shooter_pos.direction_to(aim_target)
	match spread_type:
		SpreadType.RANDOM:
			for i in bullets_per_shot:
				var random_angle: float = randf_range(-accuracy_cone_angle / 2, accuracy_cone_angle / 2)
				var aim_vector: Vector2 = aim_dir.rotated(deg_to_rad(random_angle)) * vector_length
				result.append(shooter.global_position + aim_vector)
		SpreadType.UNIFORM:
			if bullets_per_shot <= 1:
				return [aim_target]
			
			var first_vector_angle: float = accuracy_cone_angle / 2
			var first_vector: Vector2 = aim_dir.rotated(deg_to_rad(first_vector_angle)) * vector_length
			var angle_between_shots: float = accuracy_cone_angle / (bullets_per_shot - 1)
			for i in bullets_per_shot:
				var aim_vector: Vector2 = first_vector.rotated(deg_to_rad(-angle_between_shots) * i)
				result.append(shooter.global_position + aim_vector)
	
	return result

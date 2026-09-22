class_name TrajectoryStrategy
extends BulletStrategy

@export var trajectory_curve: Curve
@export var trajectory_magnitude: float = 30
@export var seek_enemies: bool = false
@export var group_to_seek: String = "Enemy"
@export var seeking_intensity: float = 10.0
@export var seeking_range: float = 500

func apply_strategy(bullet: BaseBullet):
	if seek_enemies:
		var closest_dist: float = seeking_range
		var closest_target: CharacterBody2D = null
		for child in bullet.get_tree().get_nodes_in_group(group_to_seek):
			if child is CharacterBody2D:
				var distance_to_target: float = bullet.global_position.distance_to(child.global_position)
				if distance_to_target < closest_dist:
					closest_dist = distance_to_target
					closest_target = child
		
		if not closest_target == null:
			var target_dir: Vector2 = bullet.global_position.direction_to(closest_target.global_position)
			bullet.direction = bullet.direction.lerp(target_dir, bullet.delta_time * seeking_intensity)
	
	if trajectory_curve == null:
		return
	
	var dir_x_component: Vector2 = bullet.start_point.direction_to(bullet.target_point)
	var lifetime_elapsed: float = bullet.lifetime_countdown / bullet.bullet_data.lifetime
	var dir_y_component: Vector2 = trajectory_curve.sample(lifetime_elapsed) * trajectory_magnitude * dir_x_component.orthogonal()
	bullet.direction = dir_x_component + dir_y_component
	#curve based trajectory logic

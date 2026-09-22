class_name ChainingBulletStrategy
extends CollisionStrategy

@export var group_to_seek: String = "Enemy"
@export var seeking_range: float = 100.0

func _on_collision(bullet: BaseBullet):
	bullet.direction = bullet.global_position.direction_to(_get_closest_target(bullet))

func _get_closest_target(bullet: BaseBullet) -> Vector2:
	var closest_body: CharacterBody2D = null
	var closest_dist: float = seeking_range
	for node in bullet.get_tree().get_nodes_in_group(group_to_seek):
		if node is CharacterBody2D:
			var dist: float = bullet.global_position.distance_to(node.global_position)
			if dist < closest_dist:
				closest_body = node
				closest_dist = dist
	
	if closest_body == null:
		return bullet.global_position + Vector2(randf_range(-1, 1), randf_range(-1, 1))
	
	return closest_body.global_position

class_name BouncyBullet
extends CollisionStrategy

func _on_collision(bullet: BaseBullet):
	if bullet.direction_ray.is_colliding():
		var normal = bullet.direction_ray.get_collision_normal()
		if normal.length():
			bullet.direction = -1 * bullet.direction.reflect(normal)
		else:
			bullet.direction *= -1 
		
		bullet._set_direction_ray()

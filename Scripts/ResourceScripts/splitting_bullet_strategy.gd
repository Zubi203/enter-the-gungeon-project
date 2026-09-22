class_name SplittingBulletStrategy
extends BulletDestroyStrategy

@export var split_shot: GunData

func _destroy_behavior(bullet: BaseBullet):
	if split_shot:
		split_shot.fire_burst(bullet, Vector2.UP, bullet.owner_group)

class_name ExplodingBullet
extends BulletDestroyStrategy

@export var explosion_scene: PackedScene

var bullet_manager: BulletManager:
	get: return ManagerRegistry.get_manager("bullet_manager")

func _destroy_behavior(bullet: BaseBullet):
	bullet_manager.explode(explosion_scene, bullet.global_position, bullet.owner_group)

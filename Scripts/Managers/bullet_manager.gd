class_name BulletManager
extends Node2D


var bullet_pools: Dictionary[BulletData, NodePool] = {}
var explosion_pools: Dictionary[PackedScene, NodePool] = {}

func _enter_tree() -> void:
	ManagerRegistry.register("bullet_manager", self)

func _exit_tree() -> void:
	ManagerRegistry.unregister("bullet_manager")

func shoot(data: BulletData, spawn_point: Vector2, target_point: Vector2, group: String):
	
	if not bullet_pools.keys().has(data):
		var new_pool = NodePool.new(data.scene)
		add_child(new_pool)
		bullet_pools[data] = new_pool
		
	var node_pool: NodePool = bullet_pools[data]
	
	var bullet: BaseBullet = node_pool.spawn()
	bullet.setup(data, spawn_point, target_point, group)

func explode(explosion: PackedScene, spawn_point: Vector2, group: String):
	
	if not explosion_pools.keys().has(explosion):
		var new_pool = NodePool.new(explosion)
		add_child(new_pool)
		explosion_pools[explosion] = new_pool
		
	var node_pool: NodePool = explosion_pools[explosion]
	
	var new_explosion: Explosion = node_pool.spawn()
	new_explosion.setup(spawn_point, group)

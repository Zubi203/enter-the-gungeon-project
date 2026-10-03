class_name PickupManager
extends Node2D

var gun_pickup_pools: Dictionary[PackedScene, NodePool] = {}
var pickup_pools: Dictionary[PackedScene, NodePool] = {}

func _enter_tree() -> void:
	ManagerRegistry.register("pickup_manager", self)

func _exit_tree() -> void:
	ManagerRegistry.unregister("pickup_manager")

func spawn_pickup(pickup_scene: PackedScene, spawn_pos: Vector2, move_on_spawn: bool = true):
	if pickup_scene == null:
		return
	
	if not pickup_pools.keys().has(pickup_scene):
		var new_pool = NodePool.new(pickup_scene)
		add_child(new_pool)
		pickup_pools[pickup_scene] = new_pool
		
	var node_pool: NodePool = pickup_pools[pickup_scene]
	
	var pickup: Pickup = node_pool.spawn()
	pickup.global_position = spawn_pos
	pickup._on_spawn(move_on_spawn)

func spawn_gun_pickup(pickup_scene: PackedScene, data: GunData, spawn_pos: Vector2, move_on_spawn: bool = true):
	if pickup_scene == null:
		return
	
	if not pickup_pools.keys().has(pickup_scene):
		var new_pool = NodePool.new(pickup_scene)
		add_child(new_pool)
		pickup_pools[pickup_scene] = new_pool
		
	var node_pool: NodePool = pickup_pools[pickup_scene]
	
	var pickup: GunPickup = node_pool.spawn()
	pickup.global_position = spawn_pos
	pickup.setup(data)
	pickup._on_spawn(move_on_spawn)

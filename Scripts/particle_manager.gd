class_name ParticleManager
extends Node2D

var node_pools: Dictionary [PackedScene, NodePool] = {}

func _enter_tree() -> void:
	ManagerRegistry.register("particle_manager", self)

func _exit_tree() -> void:
	ManagerRegistry.unregister("particle_manager")

func spawn_particles(particle_scene: PackedScene, spawn_point: Vector2, particle_z_index: int = 0, particle_color: Color = Color.WHITE):
	if particle_scene == null:
		return
	
	if not node_pools.keys().has(particle_scene):
		var new_pool = NodePool.new(particle_scene)
		add_child(new_pool)
		node_pools[particle_scene] = new_pool
		
	var node_pool: NodePool = node_pools[particle_scene]
	
	var particles: OneShotCPUParticles2D = node_pool.spawn()
	particles.setup(spawn_point)
	particles.modulate = particle_color
	particles.z_index = particle_z_index

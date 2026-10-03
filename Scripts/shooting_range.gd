extends Node2D

@export var gun_spawn_points: Array[Marker2D] = []
@export var guns_to_spawn: Array[GunData] = []
@export var gun_pickup_scene: PackedScene

var pickup_manager: PickupManager:
	get: return ManagerRegistry.get_manager("pickup_manager")

func _ready() -> void:
	_spawn_gun_pickups.call_deferred()

func _spawn_gun_pickups():
	if gun_pickup_scene == null:
		return
	if gun_spawn_points.is_empty():
		return
	
	for i in range(gun_spawn_points.size()):
		if guns_to_spawn[i] == null:
			continue
		pickup_manager.spawn_gun_pickup(gun_pickup_scene, guns_to_spawn[i], gun_spawn_points[i].global_position, false)
		

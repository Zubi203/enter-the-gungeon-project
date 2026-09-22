class_name NodePool
extends Node

var scene_to_spawn: PackedScene = null
var cached_nodes: Array[Node2D] = []

func _init(scene: PackedScene) -> void:
	scene_to_spawn = scene

func _create_new() -> Node2D:
	if scene_to_spawn == null:
		return null
	
	var scene = scene_to_spawn.instantiate()
	add_child.call_deferred(scene)
	cached_nodes.append(scene)
	return scene

func spawn() -> Node2D:
	for node in cached_nodes:
		if not node.visible:
			node.visible = true
			return node
	
	return _create_new()

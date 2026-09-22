extends Node

var managers : Dictionary[String, Node]

func register(manager_name: String, instance: Node):
	managers[manager_name] = instance

func unregister(manager_name):
	managers.erase(manager_name)

func has_manager(manager_name: String) -> bool:
	return managers.has(manager_name)

func get_manager(manager_name: String) -> Node:
	if not has_manager(manager_name):
		printerr(manager_name + " has not been registered")
		return null
	
	return managers[manager_name]

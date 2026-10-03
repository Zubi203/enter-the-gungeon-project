class_name DungeonRoom
extends Node2D

const WALL_THICKNESS: int = 10

enum CardinalDirection{
	NORTH,
	SOUTH,
	EAST,
	WEST
}

@export var entrance_anchors: Dictionary[CardinalDirection, Marker2D] = {
	CardinalDirection.NORTH: null,
	CardinalDirection.SOUTH: null,
	CardinalDirection.EAST: null,
	CardinalDirection.WEST: null
}

@export var enemy_spawner_container: Node2D
@export var door_container: Node2D
@export var room_trigger_container: Node2D
@export var wall_tilemap: TileMapLayer

var active_enemies: int = 0

func _ready() -> void:
	if room_trigger_container.get_children().is_empty():
		return
	
	#connect trigger signals to begin_encounter func
	for child in room_trigger_container.get_children():
		if child is Area2D:
			child.area_entered.connect(begin_encounter)

func spawn_door(dir: CardinalDirection):
	pass

func spawn_wall(dir: CardinalDirection):
	pass

func begin_encounter():
	#disable all encounter triggers
	#lock doors
	#spawn enemies
	#change music to hype
	pass

func spawn_enemies():
	#get difficulty rating based on room distance from spawn room
	#get enemy pool based on difficulty rating
	#spawn enemies randomly at spawn points with small delay between each spawn
	#connect enemies' HealthDepleted signal to _on_enemy_defeated func
	pass

func lock_doors():
	pass

func unlock_doors():
	pass

func _on_enemy_defeated():
	active_enemies -= 1
	if active_enemies <= 0:
		_on_enemies_cleared()

func _on_enemies_cleared():
	#if room has waves left, spawn more enemies
	#otherwise clear room
	pass

func room_clear():
	#return music to calm
	#unlock doors
	#10% chance to spawn reward chest at center of room
	pass

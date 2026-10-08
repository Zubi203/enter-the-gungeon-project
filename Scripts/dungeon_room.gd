class_name DungeonRoom
extends Node2D

const WALL_THICKNESS: int = 14

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
@export var north_south_facing_door: PackedScene
@export var east_west_facing_door: PackedScene
@export var center_marker: Marker2D

var active_enemies: int = 0

@export var enemies_to_spawn: Array[PackedScene] = []

func _ready() -> void:
	spawn_door(CardinalDirection.NORTH)
	spawn_door(CardinalDirection.SOUTH)
	spawn_door(CardinalDirection.WEST)
	spawn_door(CardinalDirection.EAST)
	unlock_doors()
	if room_trigger_container.get_children().is_empty():
		return
	
	#connect trigger signals to begin_encounter func
	for child in room_trigger_container.get_children():
		if child is Area2D:
			child.body_entered.connect(begin_encounter)

func spawn_door(dir: CardinalDirection):
	if wall_tilemap == null:
		return
	if entrance_anchors[dir] == null:
		return
	if door_container == null:
		return
	
	var grid_coords: Vector2i = wall_tilemap.local_to_map(entrance_anchors[dir].global_position)
	var normalized_coords: Vector2 = wall_tilemap.map_to_local(grid_coords)
	
	match dir:
		CardinalDirection.NORTH, CardinalDirection.SOUTH:
			if north_south_facing_door:
				var door: Door = north_south_facing_door.instantiate()
				door_container.add_child(door)
				door.global_position = normalized_coords
		CardinalDirection.EAST, CardinalDirection.WEST:
			if east_west_facing_door:
				var door: Door = east_west_facing_door.instantiate()
				door_container.add_child(door)
				door.global_position = normalized_coords

func spawn_wall(dir: CardinalDirection):
	if wall_tilemap == null:
		return
	if entrance_anchors[dir] == null:
		return
	
	var starting_grid_coord: Vector2i = wall_tilemap.local_to_map(entrance_anchors[dir].global_position)
	var wall_grid_coords: Array[Vector2i] = []
	
	match dir:
		CardinalDirection.NORTH:
			for i in range(WALL_THICKNESS):
				wall_grid_coords.append(Vector2i(starting_grid_coord.x, (starting_grid_coord.y + 1) - i))
				wall_grid_coords.append(Vector2i(starting_grid_coord.x + 1, (starting_grid_coord.y + 1) - i))
		CardinalDirection.SOUTH:
			for i in range(WALL_THICKNESS):
				wall_grid_coords.append(Vector2i(starting_grid_coord.x, (starting_grid_coord.y - 1) + i))
				wall_grid_coords.append(Vector2i(starting_grid_coord.x + 1, (starting_grid_coord.y - 1) + i))
		CardinalDirection.EAST:
			for i in range(WALL_THICKNESS):
				wall_grid_coords.append(Vector2i((starting_grid_coord.x - 1) + i, starting_grid_coord.y))
				wall_grid_coords.append(Vector2i((starting_grid_coord.x - 1) + i, starting_grid_coord.y - 1))
		CardinalDirection.WEST:
			for i in range(WALL_THICKNESS):
				wall_grid_coords.append(Vector2i((starting_grid_coord.x + 1) - i, starting_grid_coord.y))
				wall_grid_coords.append(Vector2i((starting_grid_coord.x + 1) - i, starting_grid_coord.y - 1))
	
	wall_tilemap.set_cells_terrain_connect(wall_grid_coords, 0, 0)


func begin_encounter(_body: Node2D):
	#disable all encounter triggers
	for trigger: Area2D in room_trigger_container.get_children():
		for child in trigger.get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", true)
	
	print("encounter")
	lock_doors()
	spawn_enemies()
	#change music to hype
	pass

func spawn_enemies():
	if enemy_spawner_container.get_children().is_empty():
		return
	if enemies_to_spawn.is_empty():
		return
	
	#get difficulty rating based on room distance from spawn room and number of enemy spawners in room
	#set enemy pool based on difficulty rating
	
	#spawn enemies randomly at spawn points with small delay between each spawn
	var valid_spawns: Array[Vector2] = []
	for child: Node2D in enemy_spawner_container.get_children():
		valid_spawns.append(child.global_position)
	
	for enemy in enemies_to_spawn:
		var enemy_scene: PackedScene = enemies_to_spawn.pop_front()
		
		var random_spawn_idx: int = valid_spawns.find(valid_spawns.pick_random())
		var spawn_point: Vector2 = valid_spawns.pop_at(random_spawn_idx)
		
		var new_enemy = enemy_scene.instantiate()
		new_enemy.global_position = spawn_point
		add_child.call_deferred(new_enemy)
		active_enemies += 1
		
		#connect enemies' HealthDepleted signal to _on_enemy_defeated func
		for child in new_enemy.get_children():
			if child is HealthComponent:
				child.HealthDepleted.connect(_on_enemy_defeated)
		
		await get_tree().create_timer(randf_range(0.1, 0.3)).timeout

func lock_doors():
	for child in door_container.get_children():
		if child is Door:
			child.close()

func unlock_doors():
	for child in door_container.get_children():
		if child is Door:
			child.open()

func _on_enemy_defeated():
	active_enemies -= 1
	if active_enemies <= 0:
		_on_enemies_cleared()

func _on_enemies_cleared():
	#if room has waves left, spawn more enemies
	#otherwise clear room
	room_clear()

func room_clear():
	#return music to calm
	#unlock doors
	unlock_doors()
	#10% chance to spawn reward chest at center of room
	pass

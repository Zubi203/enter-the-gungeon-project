class_name EnemyAI
extends ControllerComponent

enum State{
	PATROL, #wander around randomly
	PURSUIT, #chase the player, if the player is in attack range and has line of sight, shoot
	TURRET #same as pursuit, but stops moving
}

@export var stop_when_attacking: bool = false
@export var dodge_roll_on_contact_damage: bool = true
@export var player_detection_range: float = 300
@export var shooting_range: float = 150
@export var turret_mode_range: float = 120
@export var attack_sequence: EnemyAttack
@export var attack_cooldown: float = 2.0
var attack_interval_timer: float = 0.0

@export var owner_group: String = "Enemy"
@export var group_to_target: String = "Player"
var target_body: CharacterBody2D = null

@onready var line_of_sight: RayCast2D = %LineOfSight
@onready var avoidance_ray: RayCast2D = %AvoidanceRay
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D

var move_dir: Vector2
var pathfinding_interval: float = 0.2
var pathfinding_interval_countdown: float
var muzzle: GunSprite
var attack_disabled_timer: float = 0.0
var left_bias: bool = false

var current_state: State

var patrol_direction: Vector2
var patrol_direction_reset_countdown: float
@export var telegraph_particles: PackedScene

@export var spawn_effect: PackedScene
@export var activation_delay: float = 1.0

var particle_manager: ParticleManager:
	get: return ManagerRegistry.get_manager("particle_manager")

func _ready() -> void:
	
	owner.hide()
	
	await get_tree().create_timer(1.0).timeout
	
	if spawn_effect:
		var effect: EnemySpawnEffect = spawn_effect.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = owner.global_position
		
		await effect.Reveal
	
	owner.show()
	
	await get_tree().create_timer(activation_delay).timeout
	
	_get_target_body.call_deferred()
	setup.call_deferred()
	
	if randf() < 0.5:
		left_bias = true

func setup():
	for child in owner.get_children():
		if child is GunSprite:
			muzzle = child
		if child is MovementComponent:
			child.DisableAttacking.connect(_disable_shooting)
		

func _process(delta: float) -> void:
	if target_body == null:
		return
	
	if attack_disabled_timer > 0.0:
		attack_disabled_timer -= delta

	
	if attack_interval_timer > 0.0:
		attack_interval_timer -= delta
	
	if pathfinding_interval_countdown > 0.0:
		pathfinding_interval_countdown -= delta
	
	_get_target_body()
	_set_move_target(target_body.global_position)
	if not navigation_agent.is_navigation_finished():
		_update_path()
	
	#update current state
	if not _has_line_of_sight(target_body) and not _check_distance(target_body) < player_detection_range:
		current_state = State.PATROL
	else:
		if _check_distance(target_body) < turret_mode_range and _has_line_of_sight(target_body):
			current_state = State.TURRET
		else:
			current_state = State.PURSUIT
	
	#execute logic based on state
	match current_state:
		State.TURRET:
			MoveInput.emit(Vector2.ZERO)
			muzzle.target = target_body.global_position
		State.PATROL:
			muzzle.target = Vector2.ZERO
			if patrol_direction_reset_countdown > 0.0:
				patrol_direction_reset_countdown -= delta
			else:
				patrol_direction = _get_new_patrol_direction()
				
			if _local_avoidance(patrol_direction).length():
				MoveInput.emit(_local_avoidance(patrol_direction))
			else:
				MoveInput.emit(patrol_direction)
		State.PURSUIT:
			
			muzzle.target = target_body.global_position
			
			var dir: Vector2 = move_dir
			
			if _local_avoidance(dir).length():
				MoveInput.emit(_local_avoidance(dir))
			else:
				MoveInput.emit(dir)
	
	if _has_line_of_sight(target_body) and _check_distance(target_body) < shooting_range:
		_try_shoot()

func _get_new_patrol_direction() -> Vector2:
	patrol_direction_reset_countdown = randf_range(0.5, 2.0)
	var new_dir: Vector2
	if patrol_direction.length():
		return Vector2.ZERO
	if randf() < 0.5:
		new_dir = Vector2.ZERO
	else:
		new_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
		new_dir = new_dir.normalized()
	
	return new_dir

func _try_shoot():
	if target_body == null:
		return
	if muzzle == null:
		return
	if attack_sequence == null:
		return
	if attack_interval_timer > 0.0:
		return
	if attack_disabled_timer > 0.0:
		return
	
	attack_interval_timer = attack_cooldown
	particle_manager.spawn_particles(telegraph_particles, muzzle.global_position, 1)
	attack_sequence.perform_attack(muzzle, target_body.global_position, "Enemy")

func _get_attack_duration(attack: EnemyAttack) -> float:
	var duration: float = 0
	for move in attack.attack_sequence:
		duration += (move.bullets_per_shot * (1.0 - move.burst_explosiveness)) + attack.delay_between_attacks
	
	return duration

func _check_distance(target: Node2D) -> float:
	var dist: float = owner.global_position.distance_to(target.global_position)
	return dist

func _has_line_of_sight(target: Node2D) -> bool:
	if target_body == null:
		return false
	if line_of_sight == null:
		return true
	
	line_of_sight.target_position = owner.to_local(target.global_position)
	
	if line_of_sight.is_colliding():
		return false
	
	return true

func _get_target_body():
	var closest_dist: float = 99999
	var closest_node: CharacterBody2D = null
	for node in get_tree().get_nodes_in_group(group_to_target):
		if node is CharacterBody2D:
			if owner.global_position.distance_to(node.global_position) < closest_dist:
				closest_dist = owner.global_position.distance_to(node.global_position)
				closest_node = node
	
	target_body = closest_node


func _local_avoidance(dir: Vector2, detection_range: float = 50) -> Vector2:
	if avoidance_ray == null:
		return Vector2.ZERO
	
	avoidance_ray.target_position = dir * detection_range
	
	if not avoidance_ray.is_colliding():
		return Vector2.ZERO
	
	
	var obstacle_point = avoidance_ray.get_collision_point()
	var obstacle_dir = global_position.direction_to(obstacle_point)
	
	if left_bias:
		Vector2(obstacle_dir.y, -obstacle_dir.x)
	
	return Vector2(-obstacle_dir.y, obstacle_dir.x)

func _disable_shooting(duration: float):
	attack_disabled_timer = duration

func _set_move_target(target_point: Vector2):
	if navigation_agent == null:
		return
	
	navigation_agent.target_position = target_point

func _update_path():
	if navigation_agent == null:
		return
	if pathfinding_interval_countdown > 0.0:
		return
	pathfinding_interval_countdown = pathfinding_interval
	move_dir = owner.global_position.direction_to(navigation_agent.get_next_path_position())
	

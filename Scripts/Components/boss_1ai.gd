class_name BossOneAI
extends ControllerComponent

signal IntroStart
signal IntroEnd

enum State {
	IDLE,
	INTRO,
	WALK,
	SNAKE_PATTERN,
	TRIPLE_SPLITTING_BULLET,
	RADIAL_BURST_WITH_STRAIGHT_SHOTS,
	CUBIC_ACCEL_SHOTS_ENDING_WITH_LARGE_BURST,
	SPLITTING_BULLET_WITH_CURVING_SUB_BULLETS
} 

@export var attacks: Dictionary[State, EnemyAttack] = {
	State.SNAKE_PATTERN: null,
	State.TRIPLE_SPLITTING_BULLET: null,
	State.RADIAL_BURST_WITH_STRAIGHT_SHOTS: null,
	State.CUBIC_ACCEL_SHOTS_ENDING_WITH_LARGE_BURST: null,
	State.SPLITTING_BULLET_WITH_CURVING_SUB_BULLETS: null,
	State.IDLE: null,
	State.INTRO: null,
	State.WALK: null
}
var current_state: State = State.IDLE
var min_state_duration: float = 1
var max_state_duration: float = 4
@export var intro_duration: float = 2.0
@export var owner_group: String = "Enemy"
@export var target_group: String = "Player"
var target_body: CharacterBody2D
var target_dir: Vector2
@export var muzzle: Marker2D
@export var windup_effect: PackedScene
@export var retreat_range: float = 100

var particle_manager: ParticleManager:
	get: return ManagerRegistry.get_manager("particle_manager")

var camera_controller: CameraController:
	get: return ManagerRegistry.get_manager("camera_controller")

func _ready() -> void:
	_activate_boss()

func _activate_boss():
	camera_controller.set_zoom_target(3.0)
	_get_target_body.call_deferred()
	_try_transition_state.call_deferred(State.INTRO)

func _try_transition_state(target_state: State):
	if current_state == target_state:
		return
	_exit_state()
	_enter_state(target_state)

func _enter_state(state: State):
	if target_body == null:
		current_state = State.IDLE
		return
	current_state = state
	
	if owner.global_position.distance_to(target_body.global_position) < retreat_range:
		target_dir = -1 * owner.global_position.direction_to(target_body.global_position)
	else:
		target_dir = owner.global_position.direction_to(target_body.global_position)
	
	var wait_time: float
	var target_point: Node2D
	if muzzle == null:
		target_point = owner
	else:
		target_point = muzzle
	
	if not attacks[current_state] == null:
		particle_manager.spawn_particles(windup_effect, target_point.global_position , 2)
		attacks[current_state].perform_attack(target_point, target_body.global_position, owner_group)
	
		if attacks[current_state].get_attack_duration() < min_state_duration:
			wait_time = min_state_duration
		elif attacks[current_state].get_attack_duration() > max_state_duration:
			wait_time = max_state_duration
		else:
			wait_time = attacks[current_state].get_attack_duration()
	else:
		wait_time = min_state_duration
	if current_state == State.IDLE:
		wait_time = randf_range(0.4, 0.8)
	
	if current_state == State.INTRO:
		camera_controller.override_camera_target(owner.global_position, intro_duration)
		wait_time = intro_duration
		IntroStart.emit()
	
	await get_tree().create_timer(wait_time).timeout
	_try_transition_state(_choose_next_state())

func _exit_state():
	if current_state == State.INTRO:
		IntroEnd.emit()

func _get_target_body():
	var closest_dist: float = 99999
	var closest_node: CharacterBody2D = null
	for node in get_tree().get_nodes_in_group(target_group):
		if node is CharacterBody2D:
			if owner.global_position.distance_to(node.global_position) < closest_dist:
				closest_dist = owner.global_position.distance_to(node.global_position)
				closest_node = node
	
	target_body = closest_node

func _choose_next_state() -> State:
	var next_states: Array[State] = []
	match current_state:
		State.IDLE:
			next_states.append(State.WALK)
		State.INTRO:
			next_states.append(State.WALK)
		State.WALK:
			next_states.append(State.TRIPLE_SPLITTING_BULLET)
			next_states.append(State.SNAKE_PATTERN)
			next_states.append(State.RADIAL_BURST_WITH_STRAIGHT_SHOTS)
			next_states.append(State.CUBIC_ACCEL_SHOTS_ENDING_WITH_LARGE_BURST)
			next_states.append(State.SPLITTING_BULLET_WITH_CURVING_SUB_BULLETS)
		_:
			next_states.append(State.IDLE)
		
	return next_states.pick_random()

func _process(_delta: float) -> void:
	if target_body == null:
		return
	match current_state:
		State.IDLE:
			MoveInput.emit(Vector2.ZERO)
		State.WALK:
			MoveInput.emit(target_dir)
		_:
			MoveInput.emit(Vector2.ZERO)

func _exit_tree() -> void:
	camera_controller.set_zoom_target(4.0)

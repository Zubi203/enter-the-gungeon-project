class_name Pickup
extends Area2D

enum PickupType {
	COLLISION,
	INTERACT
}

@export var type: PickupType = PickupType.INTERACT
@export var pickup_sound: AudioStream
@export var pickup_particles: PackedScene
@export var interactable_group: String = "Player"

@export var auto_move_to_target: bool = false
@export var auto_move_range: float = 100
@export var auto_move_speed: float = 150

@export var spawn_velocity: float = 300
var direction: Vector2 = Vector2.ZERO
var velocity: float = 0.0

@export var collider: CollisionShape2D

@export var sprite: Sprite2D
@export var bob_speed: float = 4
@export var bob_magnitude: float = 0.4

var pickup_target: Node2D = null

var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")

var particle_manager: ParticleManager:
	get: return ManagerRegistry.get_manager("particle_manager")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	visibility_changed.connect(_on_visibility_changed)

func _on_spawn(move_on_spawn: bool = true):
	if not move_on_spawn:
		return
	velocity = randf_range(0.5 * spawn_velocity, 1.5 * spawn_velocity)
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))

func _physics_process(delta: float) -> void:
	_try_seek_target(delta)

func _on_body_entered(body: Node2D):
	if not body.is_in_group(interactable_group):
		return
	
	pickup_target = body
	
	if type == PickupType.COLLISION:
		_try_pickup(pickup_target)

func _on_body_exited(body: Node2D):
	if not body.is_in_group(interactable_group):
		return
	
	pickup_target = null
	

func _try_pickup(target: Node2D):
	if target == null:
		return
	audio_manager.play(pickup_sound)
	particle_manager.spawn_particles(pickup_particles, target.global_position, 1)
	_on_pickup(target)
	hide()

func _on_pickup(target: Node2D):
	pass

func _try_seek_target(delta: float):
	if not type == PickupType.COLLISION:
		return
	
	var target: Node2D = get_tree().get_first_node_in_group(interactable_group)
	if target == null:
		return
	
	var dist: float = global_position.distance_to(target.global_position)
	if dist < auto_move_range:
		var dir: Vector2 = global_position.direction_to(target.global_position)
		translate(dir * auto_move_speed * delta)

func _on_visibility_changed():
	if visible:
		_enable_collider.call_deferred()
		set_process(true)
		set_physics_process(true)
		_on_spawn()
	else:
		_disable_collider.call_deferred()
		set_process(false)
		set_physics_process(false)
		global_position = Vector2(9999, 9999)

func _enable_collider():
	if collider == null:
		return
	if not collider.disabled:
		return
	collider.disabled = false

func _disable_collider():
	if collider == null:
		return
	if collider.disabled:
		return
	collider.disabled = true

func bob_animation():
	var time = Time.get_unix_time_from_system()
	if sprite:
		var offset = sin(time * bob_speed) * bob_magnitude
		sprite.offset.y -= offset

func _process(_delta: float) -> void:
	
	if velocity > 0.0 and direction:
		translate(direction * velocity * _delta)
		velocity = lerpf(velocity, 0.0, _delta * 10)
	
	if Input.is_action_just_pressed("interact") and pickup_target and type == PickupType.INTERACT:
		print("gun")
		_try_pickup(pickup_target)
	
	bob_animation()

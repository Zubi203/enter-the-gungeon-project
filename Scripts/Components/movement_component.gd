class_name MovementComponent
extends Node

signal DisableAttacking (duration: float)

var owner_body: CharacterBody2D = null
var direction: Vector2
var knockback_vector: Vector2
@export var speed: float = 80
@export var acceleration: float = 50
@export var braking: float = 70
@export var roll_speed: float = 200
@export var knockback_immune: bool = false

@export var roll_particles: CPUParticles2D

var dodge_direction: Vector2
var dodge_duration: float = 0.0
var dodge_countdown: float = 0.0

var knockback_tween: Tween

func _ready() -> void:
	setup.call_deferred()

func _physics_process(delta: float) -> void:
	if owner_body == null:
		return
	
	owner_body.velocity += knockback_vector
	
	if dodge_countdown > 0.0:
		_dodge_logic(delta)
		dodge_countdown -= delta
	else:
		_movement_logic(delta)
	
	owner_body.move_and_slide()

func _movement_logic(delta: float):
	if owner_body == null:
		return
	if direction:
		owner_body.velocity = owner_body.velocity.move_toward(direction * speed, delta * acceleration)
	else:
		owner_body.velocity = owner_body.velocity.move_toward(Vector2.ZERO, delta * braking)
	

func _dodge_logic(_delta: float):
	if owner_body == null:
		return
	
	var dodge_progress_percent: float = 1.0 - (dodge_countdown / dodge_duration)
	var current_dodge_speed: float = lerp(roll_speed, roll_speed * 0.1, dodge_progress_percent)
	owner_body.velocity = dodge_direction * current_dodge_speed

#connect control signal to movement if this component has a Controller sibling
func setup():
	for child in owner.get_children():
		if child is ControllerComponent:
			child.MoveInput.connect(set_move_velocity)
			child.DodgeRoll.connect(dodge_roll)
			child.ChangeSpeed.connect(set_speed)
	
	if owner is CharacterBody2D:
		owner_body = owner

#basic movement functionality
func set_move_velocity(dir: Vector2):
	direction = dir.normalized()

#knockback function
func knockback(dir: Vector2, intensity: float):
	if knockback_immune:
		return
	DisableAttacking.emit(0.7)
	var knockback_vec = dir.normalized() * intensity
	knockback_vector = Vector2.ZERO
	if knockback_tween and knockback_tween.is_running():
		knockback_tween.kill()
	knockback_tween = create_tween()
	knockback_tween.tween_property(self, "knockback_vector", Vector2.ZERO, 0.1).from(knockback_vec)

#dash/roll functionality, if has hurtbox sibling, activate iframes
func dodge_roll(dir: Vector2, duration: float):
	if owner_body == null:
		return
	if dodge_countdown > 0.0:
		return
	
	dodge_direction = dir.normalized()
	dodge_countdown = duration
	dodge_duration = duration
	
	if roll_particles:
		roll_particles.direction = -dodge_direction
		roll_particles.restart()
		
	
func set_speed(new_speed: float):
	speed = new_speed

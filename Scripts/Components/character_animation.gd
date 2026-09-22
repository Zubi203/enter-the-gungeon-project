class_name CharacterAnimation
extends AnimationPlayer

enum Follow {
	MOUSE,
	TARGET
}

@export var footstep_sounds: Array[AudioStream] = []
@export var footstep_interval: float = 0.3
var last_footstep_time: float
@export var roll_sound: AudioStream
@export var roll_land_sound: AudioStream
@export var walk_particles: CPUParticles2D
@export var roll_land_particles: CPUParticles2D
@export var follow_type: Follow

var owner_body: CharacterBody2D = null
var target_body: CharacterBody2D = null
@export var target_group: String = "Player"
var sprite: Sprite2D = null
var rolling: bool = false
var hit_anim: bool = false

var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")

func _ready() -> void:
	_setup.call_deferred()

func _setup():
	if owner is CharacterBody2D:
		owner_body = owner
	
	animation_finished.connect(_on_animation_finished)
	
	for child in owner.get_children():
		if child is CharacterSprite:
			sprite = child
		if child is ControllerComponent:
			child.DodgeRoll.connect(_play_dodge_roll_anim)
		if child is HealthComponent:
			child.HealthDepleted.connect(_on_death)
			child.DamageTaken.connect(_on_damage_taken)
	
	if follow_type == Follow.TARGET:
		_get_target_body()

func _process(_delta: float) -> void:
	if owner_body == null:
		return
	if sprite == null:
		return
	
	if rolling:
		return
	
	if hit_anim:
		return
	
	if follow_type == Follow.MOUSE:
		sprite.flip_h = owner_body.get_local_mouse_position().x < 0
	else:
		if target_body:
			sprite.flip_h = target_body.global_position.x < 0
		
	
	if owner_body.velocity.length():
		_play_footstep_sounds()
		play("run")
	else:
		play("idle")

func _play_dodge_roll_anim(dir: Vector2, _duration: float):
	if current_animation == "roll":
		return
	play("roll")
	rolling = true
	sprite.flip_h = dir.x < 0
	audio_manager.play(roll_sound)
	await get_tree().create_timer(0.35).timeout
	audio_manager.play(roll_land_sound)
	if roll_land_particles:
		roll_land_particles.restart()

func _on_animation_finished(anim_name: String):
	if anim_name == "roll":
		rolling = false
	if anim_name == "death":
		owner.queue_free()
	if anim_name == "hit":
		hit_anim = false

func _play_footstep_sounds():
	if footstep_sounds.is_empty():
		return
	var time = Time.get_unix_time_from_system()
	if time - last_footstep_time <footstep_interval:
		return
	last_footstep_time = time
	if walk_particles:
		walk_particles.restart()
	audio_manager.play_random_pitch(footstep_sounds.pick_random())

func _on_death():
	set_process(false)
	play("death")

func _get_target_body():
	var closest_dist: float = 99999
	var closest_node: CharacterBody2D = null
	for node in get_tree().get_nodes_in_group(target_group):
		if node is CharacterBody2D:
			if owner.global_position.distance_to(node.global_position) < closest_dist:
				closest_dist = owner.global_position.distance_to(node.global_position)
				closest_node = node
	
	target_body = closest_node

func _on_damage_taken(health: int):
	if health <= 0:
		return
	if current_animation == "roll":
		return
	hit_anim = true
	play("hit")

class_name HealthComponent
extends Node2D

signal HealthDepleted
signal HealthChanged (curr_health: int, max_health: int)
signal DamageTaken (curr_health: int)

var sprite: CharacterSprite
@export var max_health: int = 30:
	set(value):
		max_health = value
		health = max_health
var health: int:
	set(value):
		health = value
		HealthChanged.emit(health, max_health)
		if health <= 0:
			die()

@export var hit_effects: Array[PackedScene]

@export var death_effects: Array[PackedScene]
@export var hit_sound: AudioStream
@export var hit_sound_cooldown: float = 0.1
var hit_sound_countdown: float = 0.0
@export var death_sound: AudioStream

var particle_manager: ParticleManager:
	get: return ManagerRegistry.get_manager("particle_manager")

var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")

func _ready() -> void:
	setup.call_deferred()

func setup():
	health = max_health
	for child in owner.get_children():
		if child is CharacterSprite:
			sprite = child

func _process(delta: float) -> void:
	if hit_sound_countdown > 0.0:
		hit_sound_countdown -= delta

func take_damage(amount: int):
	health -= amount
	if sprite: 
		sprite.damage_flash()
	spawn_hit_effects()
	DamageTaken.emit(health)

func _try_play_hit_sound():
	if hit_sound_countdown > 0.0:
		return
	hit_sound_countdown = hit_sound_cooldown
	audio_manager.play_random_pitch(hit_sound)

func heal(amount: int):
	health += amount
	if sprite:
		sprite.heal_flash()

func die():
	HealthDepleted.emit()
	audio_manager.play_random_pitch(death_sound)
	for effect in death_effects:
		particle_manager.spawn_particles(effect, owner.global_position, -1)

func spawn_hit_effects():
	if hit_effects.is_empty():
		return
	for effect in hit_effects:
		particle_manager.spawn_particles(effect, owner.global_position, -1)

class_name EnemySpawnEffect
extends Sprite2D

signal Reveal

@onready var particles: CPUParticles2D = %CPUParticles2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	particles.one_shot = true
	particles.emitting = true
	particles.finished.connect(_on_particles_finished)


func _on_particles_finished():
	animation_player.play("spawn_effect")

func _reveal_enemy():
	Reveal.emit()

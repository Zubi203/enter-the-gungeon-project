class_name BulletData
extends Resource

@export var scene: PackedScene
@export var bullet_color: Color = Color.WHITE
@export var modulate_particles: bool = true
@export var modulate_light: bool = true
@export var damage: int = 1
@export var knockback: float = 400
@export var lifetime: float = 2
@export var size_multiplier = 1.0


@export var speed_over_lifetime: BulletStrategy
@export var target_collision_logic: BulletStrategy
@export var terrain_collision_logic: BulletStrategy
@export var on_destroy_logic: BulletStrategy
@export var bullet_trajectory: BulletStrategy

class_name BaseBullet
extends Area2D

var bullet_data: BulletData
var target_point: Vector2
var start_point: Vector2
var current_speed: float
var direction: Vector2
var delta_time: float

var owner_group: String

var lifetime_countdown: float = 0.0
@onready var collider: CollisionShape2D = %Collider
@export var direction_ray: RayCast2D
@export var bullet_light: PointLight2D
@export var particles: CPUParticles2D
@export var sprite: Sprite2D

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func setup(data: BulletData, pos: Vector2, target_pos: Vector2, group: String = "Player"):
	bullet_data = data
	global_position = pos
	start_point = pos
	target_point = target_pos
	owner_group = group
	
	sprite.modulate = bullet_data.bullet_color
	if bullet_light and bullet_data.modulate_light:
		bullet_light.color = bullet_data.bullet_color
	if particles and bullet_data.modulate_particles:
		particles.modulate = bullet_data.bullet_color
	scale = Vector2.ONE * bullet_data.size_multiplier
	
	lifetime_countdown = bullet_data.lifetime
	direction = start_point.direction_to(target_point)
	

func _physics_process(delta: float) -> void:
	
	delta_time = delta
	
	#count down lifetime
	if lifetime_countdown > 0.0:
		lifetime_countdown -= delta
	else:
		destroy()
	
	_set_direction_ray()
	
	#calculate trajectory
	_try_apply_strategy(bullet_data.bullet_trajectory)
	
	#calculate speed
	_try_apply_strategy(bullet_data.speed_over_lifetime)
	
	#move bullet
	translate(direction * current_speed * delta)
	rotation = direction.angle()

func _set_direction_ray():
	direction_ray.global_position = global_position
	direction_ray.target_position = direction * 40
		

#terrain collision logic
func _on_body_entered(body: Node2D):
	if body.is_in_group(owner_group):
		return
	_try_apply_strategy(bullet_data.terrain_collision_logic)

#player/enemy collision logic
func _on_area_entered(area: Area2D):
	if area.is_in_group(owner_group):
		return
	
	_try_apply_strategy(bullet_data.target_collision_logic)
	
	for child in area.owner.get_children():
		if child is HealthComponent:
			child.take_damage(bullet_data.damage)
		if child is MovementComponent:
			child.knockback(direction, bullet_data.knockback)

func destroy():
	_try_apply_strategy(bullet_data.on_destroy_logic)
	visible = false

func _on_visibility_changed():
	if visible:
		set_physics_process(true)
		set_process(true)
		_enable_collider.call_deferred()
	else:
		set_physics_process(false)
		set_process(false)
		global_position = Vector2(9999, 9999)
		_disable_collider.call_deferred()

func _disable_collider():
	if collider == null:
		return
	if collider.disabled:
		return
	collider.disabled = true

func _enable_collider():
	if collider == null:
		return
	if not collider.disabled:
		return
	collider.disabled = false

func _try_apply_strategy(strategy: BulletStrategy):
	if strategy == null:
		return
	
	strategy.apply_strategy(self)

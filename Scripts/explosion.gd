class_name Explosion
extends Area2D

@export var collider: CollisionShape2D
@export var owner_group: String
@export var damage: int = 10
@export var animation_player: AnimationPlayer

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	area_entered.connect(_on_area_entered)

func setup(pos: Vector2, group: String):
	owner_group = group
	global_position = pos
	if animation_player:
		animation_player.play("explode")
	_disable_collider()

func _enable_collider():
	if collider == null:
		return
	if not collider.disabled:
		return
	collider.set_deferred("disabled", false)

func _disable_collider():
	if collider == null:
		return
	if collider.disabled:
		return
	collider.set_deferred("disabled", true)

func _explosion_end():
	hide()

func _on_visibility_changed():
	if not visible:
		global_position = Vector2(99999, 99999)
		_disable_collider()

func _on_area_entered(area: Area2D):
	if area.is_in_group(owner_group):
		return
	
	for child in area.owner.get_children():
		if child is HealthComponent:
			child.take_damage(damage)

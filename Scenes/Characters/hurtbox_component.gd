class_name HurtboxComponent
extends Area2D

var collider: CollisionShape2D = null
var iframe_countdown: float 

var flashing_sprite_tween: Tween
var flashing_effect: bool = false

var sprite: CharacterSprite

func _ready() -> void:
	get_attached_collision_shape()
	setup.call_deferred()

func _process(delta: float) -> void:
	if iframe_countdown > 0.0:
		iframe_countdown -= delta
		_disable_hurtbox.call_deferred()
	else:
		end_flash()
		_enable_hurtbox.call_deferred()

func get_attached_collision_shape():
	for child in get_children():
		if child is CollisionShape2D:
			collider = child
			return

func setup():
	for child in owner.get_children():
		if child is ControllerComponent:
			child.DodgeRoll.connect(activate_immunity_frames)
			child.ActivateImmunityFrames.connect(damage_immunity_frames)
		if child is CharacterSprite:
			sprite = child

func activate_immunity_frames(_dir: Vector2 = Vector2.ZERO, duration: float = 0.5):
	iframe_countdown = duration / 2.0

func damage_immunity_frames(duration: float = 0.5):
	iframe_countdown = duration 
	flash_sprite()

func _disable_hurtbox():
	if collider == null:
		return
	if collider.disabled:
		return
	collider.disabled = true

func _enable_hurtbox():
	if collider == null:
		return
	if not collider.disabled:
		return
	collider.disabled = false

func flash_sprite():
	if sprite == null:
		return
	if flashing_effect:
		return
	flashing_effect = true
	if flashing_sprite_tween and flashing_sprite_tween.is_running():
		flashing_sprite_tween.kill()
	flashing_sprite_tween = create_tween()
	flashing_sprite_tween.set_loops()
	flashing_sprite_tween.tween_property(sprite, "modulate:a", 0.0, 0.05)
	flashing_sprite_tween.tween_property(sprite, "modulate:a", 1.0, 0.05)

func end_flash():
	flashing_effect = false
	sprite.modulate.a = 1.0
	if flashing_sprite_tween and flashing_sprite_tween.is_running():
		flashing_sprite_tween.kill()

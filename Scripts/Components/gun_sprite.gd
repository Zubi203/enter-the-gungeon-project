class_name GunSprite
extends Sprite2D

@export var gun_offset: float = 12
@export var origin_offset: Vector2
@export var gun_texture: Texture2D
@export var gun_flash: PointLight2D
@export var gun_flash_duration: float = 0.01
@export var shot_particles: CPUParticles2D
@export var charging_particles: CPUParticles2D
@export var charged_particles: CPUParticles2D
@export var charge_light: PointLight2D
var flash_tween: Tween
var target: Vector2
var recoil_offset: float = 3
var character_sprite_z_index: int


func _ready() -> void:
	setup.call_deferred()

func setup():
	if gun_texture:
		texture = gun_texture
	
	for child in owner.get_children():
		if child is CharacterSprite:
			character_sprite_z_index = child.z_index

func _process(_delta: float) -> void:
	if target:
		var origin_point = owner.global_position + origin_offset
		var direction: Vector2 = origin_point.direction_to(target)
		rotation = direction.angle()
		global_position = origin_point + direction * gun_offset + _get_recoil_offset(direction, _delta)
		flip_v = direction.x < 0
		
		z_index = character_sprite_z_index + 1  if direction.y > 0 else character_sprite_z_index - 1

func _get_recoil_offset(aim_dir: Vector2, delta: float) -> Vector2:
	if recoil_offset <= 0.0:
		return Vector2.ZERO
	
	recoil_offset = lerpf(recoil_offset, 0.0, delta * 20)
	return aim_dir * recoil_offset * -1

func recoil(amount: float = 10.0):
	recoil_offset = amount
	if shot_particles:
		shot_particles.restart()
	if gun_flash == null:
		return
	if flash_tween and flash_tween.is_running():
		flash_tween.kill()
	flash_tween = create_tween()
	flash_tween.tween_property(gun_flash, "energy", 0.0, gun_flash_duration).from(1.5)

func charging(charge_color: Color):
	if charging_particles == null:
		return
	if charging_particles.emitting:
		return
	if charge_light == null:
		return
	charge_light.color = charge_color
	charge_light.energy = 0.1
	if not charging_particles.visible:
		charging_particles.show()
	charging_particles.modulate = charge_color
	charging_particles.emitting = true

func charged(charge_color: Color):
	if charged_particles == null:
		return
	if charged_particles.emitting:
		return
	
	if charge_light == null:
		return
	
	charge_light.color = charge_color
	charge_light.energy = 0.8
	
	
	if not charged_particles.visible:
		charged_particles.show()
	charged_particles.modulate = charge_color
	charged_particles.emitting = true

func stop_charging():
	if charged_particles == null:
		return
	if charging_particles == null:
		return
	if charge_light == null:
		return
	
	charge_light.energy = 0.0
	charged_particles.hide()
	charging_particles.hide()
	charged_particles.restart()
	charged_particles.emitting = false
	charging_particles.restart()
	charging_particles.emitting = false
	

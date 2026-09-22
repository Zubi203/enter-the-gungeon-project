class_name CameraController
extends Camera2D

var target_pos: Vector2 = Vector2.ZERO

var override_target_pos: Vector2 = Vector2.ZERO
var override_target: bool = false

var target_zoom: Vector2

var shake_intensity: float
var directional_shake_vector: Vector2

func _enter_tree() -> void:
	ManagerRegistry.register("camera_controller", self)

func _exit_tree() -> void:
	ManagerRegistry.unregister("camera_controller")

func _ready() -> void:
	target_zoom = zoom

func _process(_delta: float) -> void:
	
	if override_target:
		if override_target_pos:
			global_position = override_target_pos
	else:
		if target_pos:
			global_position = target_pos
	
	if not target_zoom.x == zoom.x:
		zoom = zoom.lerp(target_zoom, _delta * 20)
	
	if directional_shake_vector.length():
		directional_shake_vector = lerp(directional_shake_vector, Vector2.ZERO, _delta * 30)
		offset = directional_shake_vector * randf_range(-1.0, 1.0)
	
	if shake_intensity > 0.0:
		shake_intensity = lerpf(shake_intensity, 0.0, _delta * 10)
		offset = Vector2(
			shake_intensity * randf_range(-1.0, 1.0),
			shake_intensity * randf_range(-1.0, 1.0)
		)

func shake(amount: float):
	if not GlobalData.screen_shake_enabled:
		return
	
	shake_intensity = amount

func directional_shake(dir: Vector2, amount: float):
	if not GlobalData.screen_shake_enabled:
		return
	directional_shake_vector = dir.normalized() * amount
	shake_intensity = 0.0

func set_zoom_target(zoom_factor: float):
	zoom = Vector2(zoom_factor, zoom_factor)

func override_camera_target(new_target: Vector2, duration: float):
	override_target_pos = new_target
	override_target = true
	await get_tree().create_timer(duration).timeout
	override_target = false

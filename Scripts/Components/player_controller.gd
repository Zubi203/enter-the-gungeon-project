class_name PlayerController
extends ControllerComponent

signal GunsUpdated(curr_gun: GunData, equipped_guns: Array[GunData])
signal AmmoUpdated(curr_gun: GunData, ammo: int)
signal AmmoDepleted
signal Reload

const MAX_GUNS: int = 3

@export var roll_buffer_timer: Timer
@export var shoot_buffer_timer: Timer
@export var roll_buffer_duration: float = 0.15
@export var shoot_buffer_duration: float = 0.15
@export var camera_aim_dead_zone: float = 25
@export_range(0.0, 1.0) var mouse_camera_pull_percent: float = 0.25
var gun_sprite: GunSprite

var shoot_interval_countdown: float
var charge_counter: float = 0.0

var control_disabled: bool = false

@export var weapons: Array[GunData] = []
@export var weapon_ammo: Dictionary[GunData, int] = {}:
	set(value):
		weapon_ammo = value
		AmmoUpdated.emit(current_weapon, weapon_ammo[current_weapon])
		GunsUpdated.emit(current_weapon, weapons)
var is_reloading: bool = false
@export var reload_sound: AudioStream
@export var pickup_scene: PackedScene

var current_weapon: GunData:
	set(value): 
		current_weapon = value
		if weapon_ammo.has(current_weapon):
			AmmoUpdated.emit(current_weapon, weapon_ammo[current_weapon])
		GunsUpdated.emit(current_weapon, weapons)
		if gun_sprite:
			gun_sprite.texture = current_weapon.texture

var camera_controller: CameraController:
	get: return ManagerRegistry.get_manager("camera_controller")

var bullet_manager: BulletManager:
	get: return ManagerRegistry.get_manager("bullet_manager")

var audio_manager: AudioManager:
	get: return ManagerRegistry.get_manager("audio_manager")

var pickup_manager: PickupManager:
	get: return ManagerRegistry.get_manager("pickup_manager")

func _ready() -> void:
	weapon_ammo.clear()
	for gun in weapons:
		weapon_ammo[gun] = gun.magazine_size
	if not weapons.is_empty():
		current_weapon = weapons[0]
	setup.call_deferred()

func setup():
	for child in owner.get_children():
		if child is GunSprite:
			gun_sprite = child
			if current_weapon:
				gun_sprite.texture = current_weapon.texture
		if child is HealthComponent:
			child.DamageTaken.connect(_on_damage_taken)
	
	await get_tree().create_timer(0.1).timeout
	
	AmmoUpdated.emit(current_weapon, weapon_ammo[current_weapon])
	GunsUpdated.emit(current_weapon, weapons)

func _process(_delta: float) -> void:
	
	camera_controller.target_pos = _set_camera_position()
	
	if control_disabled:
		return
	
	if roll_buffer_timer == null:
		return
	if shoot_buffer_timer == null:
		return
	
	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	MoveInput.emit(dir)
	
	if gun_sprite:
		gun_sprite.target = get_global_mouse_position()
	
	if dodge_roll_duration_countdown > 0.0:
		
		if gun_sprite:
			gun_sprite.modulate.a = 0.0
		dodge_roll_duration_countdown -= _delta
	else:
		
		if gun_sprite:
			gun_sprite.modulate.a = 1.0
			
		if roll_buffer_timer.time_left and dir:
			charge_counter = 0.0
			dodge_roll_duration_countdown = dodge_roll_duration
			DodgeRoll.emit(dir, dodge_roll_duration)
	
	
	if is_reloading:
		return
	
	if weapon_ammo.keys().is_empty():
		return
	
	if Input.is_action_just_pressed("reload"):
		start_reload()
	
	if weapon_ammo[current_weapon] <= 0 and Input.is_action_just_pressed("shoot"):
		start_reload()
	
	if Input.is_action_just_pressed("scroll_next"):
		prev_weapon()
	if Input.is_action_just_pressed("scroll_previous"):
		next_weapon()
	
	
	if current_weapon.type == GunData.GunType.CHARGE:
		if Input.is_action_pressed("shoot") and dodge_roll_duration_countdown <= 0.0:
			charge_counter += _delta
			gun_sprite.charging(current_weapon.bullet.bullet_color)
		else:
			if charge_counter > 0.0:
				charge_counter -= _delta
	else:
		charge_counter = 0.0
	
	shoot_input(_delta)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("roll"):
		if current_weapon.type == GunData.GunType.CHARGE:
			charge_counter = 0.0
			gun_sprite.stop_charging()
		roll_buffer_timer.start(roll_buffer_duration)
	
	if Input.is_action_just_pressed("shoot"):
		shoot_buffer_timer.start(shoot_buffer_duration)
	

func _set_camera_position() -> Vector2:
	var mouse_pos: Vector2 = get_local_mouse_position()
	var player_pos: Vector2 = owner.global_position
	
	if not GlobalData.dynamic_camera_aim:
		camera_controller.position_smoothing_speed = 40
		return player_pos
	
	if player_pos.distance_to(get_global_mouse_position()) < camera_aim_dead_zone:
		camera_controller.position_smoothing_speed = 10
		return player_pos
	
	camera_controller.position_smoothing_speed = 40
	
	var camera_pos: Vector2 = player_pos + mouse_pos * mouse_camera_pull_percent
	return camera_pos

func shoot_input(delta: float):
	if current_weapon == null:
		return
	if not weapon_ammo.has(current_weapon):
		return
	if weapon_ammo[current_weapon] <= 0:
		return
	
	if shoot_interval_countdown > 0.0:
		shoot_interval_countdown -= delta
	else:
		match current_weapon.type:
			GunData.GunType.TAP_TO_SHOOT:
				if shoot_buffer_timer.time_left:
					shoot_buffer_timer.stop()
					current_weapon.fire_burst(gun_sprite, get_global_mouse_position(), "Player")
					consume_ammo()
					shoot_interval_countdown = current_weapon.shoot_interval
			GunData.GunType.AUTO_FIRE:
				if Input.is_action_pressed("shoot"):
					current_weapon.fire_burst(gun_sprite, get_global_mouse_position(), "Player")
					consume_ammo()
					shoot_interval_countdown = current_weapon.shoot_interval
			GunData.GunType.CHARGE:
				if charge_counter >= current_weapon.charge_time:
					gun_sprite.charged(current_weapon.bullet.bullet_color)
					if Input.is_action_just_released("shoot"):
						charge_counter = 0.0
						gun_sprite.stop_charging()
						current_weapon.fire_burst(gun_sprite, get_global_mouse_position(), "Player")
						consume_ammo()
				else:
					if Input.is_action_just_released("shoot"):
						gun_sprite.stop_charging()
						

func next_weapon():
	if weapons.is_empty():
		return
	
	if current_weapon.type == GunData.GunType.CHARGE:
		charge_counter = 0.0
		gun_sprite.stop_charging()
	
	var curr_weapon_idx: int = weapons.find(current_weapon)
	current_weapon = weapons[posmod(curr_weapon_idx + 1, weapons.size())]

func prev_weapon():
	if weapons.is_empty():
		return
	
	if current_weapon.type == GunData.GunType.CHARGE:
		charge_counter = 0.0
		gun_sprite.stop_charging()
	
	var curr_weapon_idx: int = weapons.find(current_weapon)
	current_weapon = weapons[posmod(curr_weapon_idx - 1, weapons.size())]

func _on_damage_taken(_health: int):
	
	if current_weapon.type == GunData.GunType.CHARGE:
		charge_counter = 0.0
		gun_sprite.stop_charging()
	
	camera_controller.shake(7.0)
	ActivateImmunityFrames.emit(hit_iframe_duration)
	control_disabled = true
	MoveInput.emit(Vector2.ZERO)
	await get_tree().create_timer(hit_iframe_duration / 4.0).timeout
	control_disabled = false

func consume_ammo():
	if current_weapon == null:
		return
	if not weapon_ammo.has(current_weapon):
		return
	
	for i in current_weapon.bullets_per_shot:
		if weapon_ammo[current_weapon] > 0:
			weapon_ammo[current_weapon] -= 1
			AmmoUpdated.emit(current_weapon, weapon_ammo[current_weapon])
			await get_tree().create_timer(1.0 - current_weapon.burst_explosiveness).timeout
	
	if weapon_ammo[current_weapon] <= 0:
		AmmoDepleted.emit()

func add_new_gun(gun: GunData):
	if weapons.size() < MAX_GUNS:
		if not weapons.has(gun):
			weapons.append(gun)
			weapon_ammo[gun] = gun.magazine_size
			current_weapon = gun
	else:
		if pickup_scene:
			pickup_manager.spawn_gun_pickup(pickup_scene, current_weapon, owner.global_position)
		weapons.erase(current_weapon)
		weapon_ammo.erase(current_weapon)
		weapons.append(gun)
		weapon_ammo[gun] = gun.magazine_size
		current_weapon = gun
	
	AmmoUpdated.emit(current_weapon, weapon_ammo[current_weapon])
	GunsUpdated.emit(current_weapon, weapons)

func start_reload():
	if weapon_ammo[current_weapon] == current_weapon.magazine_size:
		return
	Reload.emit()
	is_reloading = true
	audio_manager.play_random_pitch(reload_sound)
	var tween = create_tween()
	tween.tween_method(
		reload_tween,
		weapon_ammo[current_weapon],
		current_weapon.magazine_size,
		current_weapon.reload_speed
	)
	tween.tween_callback(reload_finished)

func reload_tween(value: float):
	weapon_ammo[current_weapon] = value
	AmmoUpdated.emit(current_weapon, weapon_ammo[current_weapon])
	GunsUpdated.emit(current_weapon, weapons)

func reload_finished():
	is_reloading = false

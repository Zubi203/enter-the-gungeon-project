class_name PlayerUI
extends CanvasLayer

@export var damage_screen_effect: TextureRect
var damage_screen_tween: Tween

@export var health_bar: Range
@export var health_text: Label

@export var equipped_gun_sprites: Array[TextureRect]
@export var ammo_progress_bar: Range
@export var selected_gun_sprite: TextureRect

func _ready() -> void:
	setup.call_deferred()

func setup():
	for child in owner.get_children():
		if child is HealthComponent:
			child.DamageTaken.connect(_on_damage_taken)
			child.HealthChanged.connect(_update_health)
			_update_health(child.health, child.max_health)
		if child is PlayerController:
			child.AmmoUpdated.connect(_update_ammo_bar)
			child.GunsUpdated.connect(_update_equipped_guns)

func _on_damage_taken(_health: int):
	if damage_screen_effect == null:
		return
	
	if damage_screen_tween and damage_screen_tween.is_running():
		damage_screen_tween.kill()
	
	damage_screen_tween = create_tween()
	damage_screen_tween.tween_property(damage_screen_effect, "modulate:a", 1.0, 0.05)
	damage_screen_tween.tween_property(damage_screen_effect, "modulate:a", 0.0, 0.3)

func _update_health(current_health: int, max_health: int):
	if health_bar == null:
		return
	if health_text == null:
		return
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_text.text = str(current_health) + "/" + str(max_health)

func _update_ammo_bar(selected_gun: GunData, ammo: int):
	if selected_gun_sprite == null:
		return
	if ammo_progress_bar == null:
		return
	
	selected_gun_sprite.texture = selected_gun.highlighted_texture
	ammo_progress_bar.max_value = selected_gun.magazine_size
	ammo_progress_bar.value = ammo

func _update_equipped_guns(current_gun: GunData, equipped_guns: Array[GunData]):
	if equipped_guns.size() > equipped_gun_sprites.size():
		return
	
	for i in range(equipped_guns.size()):
		if equipped_guns[i] == current_gun:
			equipped_gun_sprites[i].texture = equipped_guns[i].highlighted_texture
		else:
			equipped_gun_sprites[i].texture = equipped_guns[i].texture

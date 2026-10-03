class_name GunPickup
extends Pickup

@export var gun_data: GunData


func setup(data: GunData):
	if data == null:
		return
	gun_data = data
	if sprite:
		sprite.texture = gun_data.texture

func _on_pickup(target: Node2D):
	if gun_data == null:
		return
	for child in target.get_children():
		if child is PlayerController:
			child.add_new_gun(gun_data)

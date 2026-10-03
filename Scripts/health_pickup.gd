class_name HealthPickup
extends Pickup

@export var heal_amount: int = 5

func _on_pickup(target: Node2D):
	for child in target.get_children():
		if child is HealthComponent:
			child.heal(heal_amount)

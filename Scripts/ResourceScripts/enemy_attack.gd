class_name EnemyAttack
extends Resource

@export var attack_sequence: Array[GunData] = []
@export var startup_delay: float = 0.0
@export var delay_between_attacks: float = 0.0
@export var concurrent_attacks: bool = false

func perform_attack(shooter: Node2D, aim_target: Vector2, group: String):
	
	var default_delay: float = delay_between_attacks
	await shooter.get_tree().create_timer(startup_delay).timeout
	for attack in attack_sequence:
		attack.fire_burst(shooter, aim_target, group)
		if not concurrent_attacks:
			default_delay = delay_between_attacks + (attack.bullets_per_shot * (1.0 - attack.burst_explosiveness))
		await shooter.get_tree().create_timer(default_delay).timeout

func get_attack_duration() -> float:
	var duration: float = startup_delay
	for move in attack_sequence:
		duration += (move.bullets_per_shot * (1.0 - move.burst_explosiveness)) + delay_between_attacks
	return duration
	

class_name SpeedOverLifetimeStrategy
extends BulletStrategy

@export var base_speed: float = 300
@export var speed_curve: Curve

func apply_strategy(bullet: BaseBullet):
	if speed_curve == null:
		bullet.current_speed = base_speed
	
	var lifetime_elapsed_percent: float = 1.0 - (bullet.lifetime_countdown / bullet.bullet_data.lifetime)
	bullet.current_speed = base_speed * speed_curve.sample(lifetime_elapsed_percent)

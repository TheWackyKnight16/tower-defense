class_name SuperChargedShot extends Effect

@export var shot_count:int = 4
@export var super_charged_pierce:int = 2
@export var super_charged_damage:float = 1.15
@export var super_charged_size:float = 1.5

var shots_fired:int = 0

func on_projectile_spawned(_turret, proj):
	shots_fired += 1
	if shots_fired >= shot_count:
		shots_fired = 0
		proj.max_pierce += super_charged_pierce
		proj.pierce = proj.max_pierce
		proj.damage *= super_charged_damage
		proj.size *= super_charged_size

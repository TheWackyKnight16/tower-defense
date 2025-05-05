class_name ExplosiveRounds extends Effect

@export var explosive_damage_modifier:float = 1.5
@export var explosive_range:float = 5.0
@export var projectile_speed_decrease:float = 0.5

func on_projectile_spawned(_turret, proj):
    proj.detection_range = explosive_range
    proj.speed *= projectile_speed_decrease

func on_projectile_hit(proj, _target):
    if proj.enemies_in_area.size() > 0:
        for enemy in proj.enemies_in_area:
            enemy.take_damage(proj.damage * explosive_damage_modifier)
class_name ImprovedRifling extends Effect

@export var extra_range:float = 5.0
@export var higher_crit_chance:float = 0.25

func on_projectile_spawned(turret, _proj):
    turret.critical_chance += higher_crit_chance

func on_slot(turret):
    turret.turret_range += extra_range

    turret.range_collision_shape.shape.radius = turret.turret_range
    turret.range_mesh_instance.mesh.radius = turret.turret_range


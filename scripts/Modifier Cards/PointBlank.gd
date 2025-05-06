class_name PointBlank extends Effect

@export var max_range_damage:float = 0.3
@export var min_range_damage:float = 2.0

var bonus_damage:float = 0.0
var ratio:float = 0.0

func on_projectile_spawned(_turret, proj):
    mode = Effect.MODE.MULTIPLICATIVE
    
    ratio = (_turret.distance_to_target) / pow(_turret.turret_range, 2)
    var curve_ratio = clamp(1.0 - ratio, 0.0, 1.0)
    bonus_damage = lerpf(max_range_damage, min_range_damage, curve_ratio)

    proj.damage *= bonus_damage
    print("Damage: ", proj.damage)
    print("Ratio: ", ratio)
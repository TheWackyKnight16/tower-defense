class_name ShotgunTurret extends Effect

@export_category("Sohtgun")
@export var pellets:int = 5
@export var spread:float = 10

@export_category("Turret")
@export var damage:float = 1.0
@export var turret_range:float = 20.0
@export var fire_rate:float = 1.0
@export var turn_speed:float = 1.0
@export var critical_chance:float = 0.0
@export var critical_damage:float = 1.5

@export_category("Projectile")
@export var pierce:int = 1
@export var projectile_speed:float = 100.0
@export var projectile_size:float = 0.25

func modify(stat_name: String, value: float) -> float:  
    match stat_name:
        "damage":
            value = damage
        "turret_range":
            value = turret_range
        "fire_rate":
            value = fire_rate
        "turn_speed":
            value = turn_speed
        "critical_chance":
            value = critical_chance
        "critical_damage":
            value = critical_damage
        "projectile_speed":
            value = projectile_speed
        "projectile_size":
            value = projectile_size
        "pellets":
            value = pellets
        "spread":
            value = spread
        "pierce":
            value = pierce
    return value
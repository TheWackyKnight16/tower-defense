extends Effect
class_name FireDamage

@export var extra_fire_damage:int = 1
@export var burn_chance:float = 0.25
@export var burn_damage:float = 2.0
@export var burn_duration:float = 3.0

func on_projectile_spawned(_turret, proj):
    proj.damage += extra_fire_damage
    proj.on_hit_callbacks.append(Callable(self, "apply_burn"))

func apply_burn(_proj, target):
    if randf() < burn_chance:
        target.apply_status("burn", burn_damage, burn_duration)

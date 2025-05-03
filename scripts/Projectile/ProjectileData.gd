class_name ProjectileData
extends Resource

@export var projectile_mesh:Mesh

@export var damage:int = 5
@export var speed:float = 10.0

@export var max_pierce:int = 1

@export var is_explosive:bool = false
@export var explosion_radius:float = 0.0
@export var explosive_damage:float = 0.0

@export var is_splitting:bool = false
@export var split_count:int = 0

@export var is_homing:bool = false
@export var homing_speed:float = 0.0

@export var is_teleporting:bool = false
@export var teleport_distance:float = 0.0

@export var applies_effect:bool = false
@export var effect_duration:float = 0.0
# effect data
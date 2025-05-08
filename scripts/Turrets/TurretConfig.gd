class_name TurretConfig extends Resource

@export_category("Turret")
@export var damage:float = 1.0
@export var turret_range:float = 40.0
@export var fire_rate:float = 1.0
@export var turn_speed:float = 1.0
@export var critical_chance:float = 0.0
@export var critical_damage:float = 1.5

@export_category("Projectile")
@export var projectile_scene:PackedScene
@export var pierce:int = 1
@export var projectile_speed:float = 100.0
@export var projectile_size:float = 0.5
@export var pellets:int = 1
@export var spread:float = 0
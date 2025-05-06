extends Node3D

var max_health:int = 0
var cur_health:float = 0.0
var regeneration_time:float = 0.0

var radius:float = 0.0

var collision_shape:CollisionShape3D = null
var mesh_instance:MeshInstance3D = null

var elapsed_time:float = 0.0

func _ready():
    collision_shape = $StaticBody3D/CollisionShape3D
    mesh_instance = $MeshInstance3D

    collision_shape.shape.radius = radius
    mesh_instance.mesh.radius = radius
    mesh_instance.mesh.height = radius

func _process(delta):
    if cur_health <= 0:
        elapsed_time += delta
        if elapsed_time >= regeneration_time:
            cur_health = max_health
            collision_shape.disabled = false

func take_damage(damage, _source = null):
    cur_health -= damage

    if cur_health <= 0:
        collision_shape.disabled = true
        elapsed_time = 0
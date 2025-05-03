extends Node3D

@export_category("Turret")
@export_enum("RayCast", "Projectile") var turret_type

enum TurretType {
    RayCast,
    Projectile
}

@export var turret_range:float = 20.0
@export var turret_speed:float = 0.5
@export var damage:int = 5

@export_category("Projectile")
@export var projectile_scene:PackedScene
@export var projectile_data:ProjectileData

var turret_firing_timer:float = 0.0
var enemies_in_range:Array[Node3D]

func _ready():
    add_to_group("turrets")

    $RangeArea/CollisionShape3D.shape.radius = turret_range
    $RangeArea/MeshInstance3D.mesh.radius = turret_range

func _process(_delta):
    if turret_type == TurretType.RayCast:
        ray_cast_fire(_delta)
    elif turret_type == TurretType.Projectile:
        projectile_fire(_delta)

func projectile_fire(delta, target: Node3D = null):
    if turret_firing_timer < turret_speed:
        turret_firing_timer += delta
        return
    
    if target == null:
        target = find_closest_enemy()
    if target == null:
        return

    var projectile_instance = projectile_scene.instantiate()
    projectile_instance.projectile_data = projectile_data
    projectile_instance.transform.origin = global_position + Vector3(0, 1, 0)
    projectile_instance.target_direction = (Vector3(target.global_position.x, 1, target.global_position .z) - Vector3(global_position.x, 1, global_position.z))
    projectile_instance.add_to_group("projectiles")
    get_tree().current_scene.add_child(projectile_instance)

    turret_firing_timer = 0.0

func ray_cast_fire(delta, target: Node3D = null):
    if turret_firing_timer < turret_speed:
        turret_firing_timer += delta
        return
    
    if target == null:
        target = find_closest_enemy()
    if target == null:
        return
    
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(Vector3(target.global_position.x, 1, target.global_position .z), Vector3(global_position.x, 1, global_position.z))
    var result = space_state.intersect_ray(query)
    if result.is_empty():
        return
    
    target.take_damage(damage)
    
    turret_firing_timer = 0.0

func find_closest_enemy() -> Node3D:
    if enemies_in_range.size() == 0:
        return null
    
    enemies_in_range.sort_custom(sort_enemies_by_distance)
    var closest_enemy = enemies_in_range[0]
    return closest_enemy

func sort_enemies_by_distance(a:Node3D, b:Node3D):
    return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position)

func _on_range_area_body_entered(body:Node3D):
    if body.is_in_group("enemies"):
        enemies_in_range.append(body)

func _on_range_area_body_exited(body:Node3D):
    if body.is_in_group("enemies"):
        enemies_in_range.erase(body)

func toggle_range_visibility(visibility:bool):
    $RangeArea/MeshInstance3D.visible = visibility
    
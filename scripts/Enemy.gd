class_name Enemy
extends CharacterBody3D

@export var max_health:int = 10
@export var speed:float = 10
@export var base_damage:int = 2
@export var attack_speed:float = 1

var cur_health:float = max_health
var target = null

var active_statuses:Dictionary = {}
var burn_damage:float = 0.0

var targets_in_range = []
var attack_timer:float = 0

var anim: AnimationPlayer

func _ready():
    add_to_group("enemies")

    anim = get_node("TempEnemy/AnimationPlayer")
    anim.play("ArmatureAction")

func _process(_delta):
    move_to_target()

    if targets_in_range.size() > 0:
        attack_timer += _delta
        if attack_timer >= attack_speed:
            attack_timer = 0
            attack()

    if "burn" in active_statuses:
        take_damage(burn_damage * _delta)
        #print("burning: ", cur_health)
    
    for key in active_statuses.keys():
        active_statuses[key] -= _delta
    var expired = active_statuses.keys().filter(func(k): return active_statuses[k] <= 0)
    for key in expired:
        active_statuses.erase(key)
        if key == "burn":
            burn_damage = 0

func attack():
    for t in targets_in_range:
        if t.has_method("take_damage"):
            t.take_damage(base_damage, self)
            #print("Enemy damage: ", base_damage, " on ", t)

func move_to_target():
    if target == null:
        target = find_closest_turret()
        if target == null:
            #queue_free()
            return
    
    var direction = (target.global_position - global_position).normalized()
    velocity = direction * speed
    move_and_slide()

    look_at(target.global_position)
    rotation.y += deg_to_rad(90)

func find_closest_turret():
    var turrets = get_tree().get_nodes_in_group("turrets")
    var closest_turret = null
    var closest_dist = 1000000

    for turret in turrets:
        var dist = global_position.distance_squared_to(turret.global_position)
        if dist < closest_dist:
            closest_dist = dist
            closest_turret = turret

    return closest_turret

func take_damage(taken_damage):
    cur_health -= taken_damage
    if cur_health <= 0:
        queue_free()

func apply_status(status_name, damage, duration):
    if status_name in active_statuses:
        return

    match status_name:
        "burn":
            add_status_timer(status_name, duration)
            burn_damage = damage

func add_status_timer(status_name, duration):
    active_statuses[status_name] = max(active_statuses.get(status_name, 0), duration)

func _on_attack_area_entered(body:Node3D):
    if body.is_in_group("turrets"):
        targets_in_range.append(body.get_parent())

func _on_attack_area_exited(body:Node3D):
    if body.is_in_group("turrets"):
        targets_in_range.erase(body.get_parent())

func _on_attack_area_area_exited(area:Area3D):
    if area.is_in_group("turrets"):
        targets_in_range.erase(area.get_parent())

func _on_attack_area_area_entered(area:Area3D):
    if area.is_in_group("turrets"):
        targets_in_range.append(area.get_parent())
